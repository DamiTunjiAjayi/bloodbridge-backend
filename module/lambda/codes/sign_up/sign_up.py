import json
from json import load
import boto3
import bcrypt
import uuid
import random
from os import getenv
from datetime import datetime, timedelta
from utils import resp, callback_response, validate_payload, logger
from boto3.dynamodb.conditions import Key, Attr
from jsonschema import validate, exceptions
import sys
import hmac
import hashlib
import base64
from datetime import timezone, datetime

dynamodb = boto3.resource('dynamodb')
ses = boto3.client('ses')
table_name = getenv('USER_TABLE_NAME')
table = dynamodb.Table(table_name)
env = getenv('ENV')
client = boto3.client('cognito-idp')

POOL_ID = getenv('POOL_ID')
CLIENT_ID = getenv('CLIENT_ID')
CLIENT_SECRET = getenv('CLIENT_SECRET')
SENDER_EMAIL = getenv('INFO_EMAIL')
ACCOUNT_ID = getenv('ACCOUNT_ID')

def lambda_handler(event, context):
    body = event['body'] if 'body' in event and event['body'] is not None else event
    logger.info(event)
    logger.info(body)
    logger.info(f"Current UTC time: {datetime.now(timezone.utc).isoformat()}")

    try:
            
        with open("sign_up.json") as f:
            schema = load(f)
    
        payload_validation = validate_payload(body, schema)
        if payload_validation['is_invalid']:
            status_code = 400
            resp['message'] = "Invalid payload"
            resp['details'] = payload_validation['errors']
            return callback_response(status_code)
        
        email = body.get("email")
        password = body.get("password")
        
        attributes = [
            {
                'Name': "email",
                'Value': email
            }  
        ]
       
    
        secret_hash = get_secret_hash_individual(email)
        
        sub = save_to_cognito(attributes, email, password, secret_hash)
        
        details = {}
        details['pk'] =  "user"
        details['sk'] = f"user_{sub}"
        details['email'] = email        
        details['created_at'] = int(datetime.now(timezone.utc).timestamp())
        details['updated_at'] = int(datetime.now(timezone.utc).timestamp())
        print(details)

        table.put_item( Item=details )
        
        status_code = 200
        resp["error"] = False
        resp["success"] = True
        resp["message"] = "successfully signed up"
    except client.exceptions.InvalidPasswordException as e:
        logger.error(e)
        status_code = 400
        resp['error'] = True
        resp['success'] = False
        resp['message'] =  "kindly use a stronger password it must include a symbol, number and a uppercase character "
        resp['data'] = None
        return callback_response(status_code)
    except client.exceptions.NotAuthorizedException as e:
        status_code = 400
        logger.error(e)
        resp['error'] = True
        resp['success'] = False
        resp['message'] =  "you are not authorised to perform this action"
        resp['data'] = None
        return callback_response(status_code)
    except client.exceptions.InvalidParameterException as e:
        status_code = 400
        logger.error(e)
        resp['error'] = True
        resp['success'] = False
        resp['message'] =  "invalid details provided"
        resp['data'] = None
        return callback_response(status_code)
    except client.exceptions.UsernameExistsException as e:
        status_code = 400
        logger.error(e)
        resp['error'] = True
        resp['success'] = False
        resp['message'] =  "user with this email already exist"
        resp['data'] = None
        return callback_response(status_code)
    except client.exceptions.CodeDeliveryFailureException as e:
        status_code = 400
        logger.error(e)
        resp['error'] = True
        resp['success'] = False
        resp['message'] =  "we are having difficulties sending a confirmation code to your email"
        resp['data'] = None
        return callback_response(status_code)
    except Exception as e:
        status_code = 500
        logger.error(e)
        logger.error(e)
        resp["message"] = "something went wrong"
        resp["error"] = True
        resp["success"] = False
    return callback_response(status_code)
    
    
def get_secret_hash_individual(username):
    msg = username + CLIENT_ID
    dig = hmac.new(str(CLIENT_SECRET).encode('utf-8'),
                   msg=str(msg).encode('utf-8'), digestmod=hashlib.sha256).digest()
    d2 = base64.b64encode(dig).decode()
    return d2

    
def save_to_cognito(attributes, email, password, secret_hash):
    logger.info(attributes)
    response = client.sign_up(
                    ClientId=CLIENT_ID,
                    SecretHash=secret_hash,
                    Username=email,
                    UserAttributes= attributes,
                    Password=password,
                    ValidationData=[
                        {
                            'Name': 'email',
                            'Value': email
                        },
                    ],
                    ClientMetadata={
                                'userName': email,
                                "codeParameter": password
                            }
                )
    print(response)
    user_sub = response['UserSub']
    return user_sub
    




    