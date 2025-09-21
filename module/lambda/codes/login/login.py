import boto3
import hmac
import hashlib
import base64
import os
import sys
from srptools import SRPContext
from utils import resp, contx, db, logger, get_user_id, callback_response
from jsonschema import validate, exceptions
from os.path import dirname
from boto3.dynamodb.conditions import Key, Attr
import json
from json import load
from uuid import uuid4
import random
from datetime import datetime, timezone

POOL_ID = os.environ["POOL_ID"]
CLIENT_ID = os.environ["CLIENT_ID"]
CLIENT_SECRET = os.environ["CLIENT_SECRET"]

client = boto3.client('cognito-idp')
table_name = os.getenv('USER_TABLE_NAME')
table = db.Table(table_name)


def generate_srp(username, password):
    context = SRPContext(username, password)
    username, password_verifier, salt = context.get_user_data_triplet()
    prime = context.prime
    gen = context.generator
    return gen


def get_secret_hash_individual(username):
    msg = username + CLIENT_ID
    dig = hmac.new(str(CLIENT_SECRET).encode('utf-8'),
                   msg=str(msg).encode('utf-8'), digestmod=hashlib.sha256).digest()
    d2 = base64.b64encode(dig).decode()
    return d2


def lambda_handler(event, context):
    try:
        body = event['body'] if 'body' in event and event['body'] is not None else event
        logger.info(f"Current UTC time: {datetime.now(timezone.utc).isoformat()}")
        contx.info("Data Received: {}".format(event))

        with open('login.json') as f:
            schema = load(f)

        payload = validate_payload(body, schema)
        status_code = 400
        if payload['is_invalid']:
            resp['message'] = "invalid payload"
            return callback_response(status_code)

        username = body.get("email")
        password = body.get("password")
        secret_hash = get_secret_hash_individual(username)
        
        auth_response = client.initiate_auth(
                ClientId=CLIENT_ID,
                AuthFlow='USER_PASSWORD_AUTH',
                AuthParameters={
                    'USERNAME': username,
                    'SECRET_HASH': secret_hash,
                    'PASSWORD': password
                }
            )
        logger.info(f"login response, {auth_response}")

        if "AuthenticationResult" not in auth_response:
            resp['error'] = True
            resp['success'] = False
            resp['message'] = "Authentication failed or challenge required"
            resp['data'] = None
            status_code = 400
            return callback_response(status_code)
        
        access_token = auth_response["AuthenticationResult"]["AccessToken"]
        user_id = get_user_id(client, access_token)

        # Udate user's online status
        update_expression = "set #online_status = :online_status"
        expression_attribute_names = {
            "#online_status": "online_status"
        }
        expression_attribute_values = {
            ":online_status": True
        }
        response = table.update_item(
            Key={"pk": "user", "sk": f"user_{user_id}"},
            UpdateExpression=update_expression,
            ExpressionAttributeNames=expression_attribute_names,
            ExpressionAttributeValues=expression_attribute_values
        )

        # Fetch user details from DynamoDB
        user_query = table.get_item(
            Key={
                'pk': 'user',
                'sk': f'user_{user_id}'
            }
        )
        details = user_query.get('Item', {})
        user_data = {
            'userId': details.get('sk'),
            'name': details.get('name', ''),
            'display_name': details.get('display_name', ''),
            'email': details.get('email', ''),
            'bio': details.get('bio', ''),
            'role': details.get('role', ''),
            #'availability_status': details.get('availability_status', 'offline'),
            'online_status': details.get('online_status'),
            #'credentials': [],
            #'topics': details.get('topics', []),
        }

        resp['message'] = "login sucess"
        resp['data'] = {
            "id_token": auth_response["AuthenticationResult"]["IdToken"],
            "refresh_token": auth_response["AuthenticationResult"]["RefreshToken"],
            "access_token": auth_response["AuthenticationResult"]["AccessToken"],
            "expires_in": auth_response["AuthenticationResult"]["ExpiresIn"],
            "token_type": auth_response["AuthenticationResult"]["TokenType"],
            "user": user_data
        }
            
        resp['error'] = False
        resp['success'] = True
        status_code = 200
        return callback_response(status_code)
    except client.exceptions.UserNotFoundException as e:
        status_code = 400
        resp['error'] = True
        resp['success'] = False
        resp['message'] =  "user with provided email not found"
        resp['data'] = None
        return callback_response(status_code)
    except client.exceptions.UserNotConfirmedException as e:
        status_code = 400
        resp['error'] = True
        resp['success'] = False
        resp['message'] =  "kindly confirm your account first"
        resp['data'] = None
        return callback_response(status_code)
    except client.exceptions.InvalidParameterException as e:
        status_code = 400
        resp['error'] = True
        resp['success'] = False
        resp['message'] =  "invalid details provided"
        resp['data'] = None
        return callback_response(status_code)
    except client.exceptions.NotAuthorizedException as e:
        status_code = 400
        resp['error'] = True
        resp['success'] = False
        resp['message'] =  "Incorrect username or password"
        resp['data'] = None
        return callback_response(status_code)
    except Exception as err:
        contx.error("Exception: {}".format(err), exc_info=sys.exc_info())
        status_code = 400
        resp['error'] = True
        resp['success'] = False
        resp['message'] = 'something went wrong'
        resp['data'] = None
        return callback_response(status_code)


def callback_response(code):
    return {
        'statusCode': code,
        'body': resp
    }

def validate_payload(body, schema):
    response = {'is_invalid': False, 'e': {}}
    try:
        validate(instance=body, schema=schema)
    except exceptions.ValidationError as err:
        response['is_invalid'] = True
        response['e']['error'] = 'INVALID_PAYLOAD'
        response['e']['message'] = err.message
        contx.error("Exception: {}".format(err), exc_info=sys.exc_info())
    return response


def update_login_attribute(tablename, user_id):
    try:
        item = tablename.query(
            KeyConditionExpression=Key('pk').eq("user") & Key('sk').eq(user_id)
        ).get('Items')[0]
        status = item.get('status')
        if status == 'pending' or status == 'inactive':
            item['status'] = 'active' 
        item.update({'last_login': int(time())})  
        if item.get('login_count', 0):
           item['login_count'] += 1
        tablename.put_item(Item=item)
    except Exception as e:
        contx.error(e)