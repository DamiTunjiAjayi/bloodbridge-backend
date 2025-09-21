import boto3
import hmac
import hashlib
import base64
import os
import sys
from srptools import SRPContext
from utils import resp, db, logger, admin_get_user
from jsonschema import validate, exceptions
from os.path import dirname
from boto3.dynamodb.conditions import Key, Attr
import json
from json import load
from uuid import uuid4
import random
import time

from os import getenv

client = boto3.client('cognito-idp')

POOL_ID = getenv("POOL_ID")
CLIENT_ID = getenv("CLIENT_ID")
CLIENT_SECRET = getenv("CLIENT_SECRET")


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
    status_code = 400
    logger.info(event)
    try:
        body = event['body'] if 'body' in event and event['body'] is not None else event
        accessToken = event["headers"].get("Authorization")
        
        if not accessToken:
            status_code = 400
            resp["message"] = "accessToken is required User must be signed in"
            return callback_response(status_code)

        new_password = body.get("new_password")
        old_password = body.get("old_password")
        
        with open('change_password.json') as f:
            schema = load(f)
      
        payload = validate_payload(body, schema)
        status_code = 400
        if payload['is_invalid']:
          resp['message'] = "invalid payload"
          return callback_response(status_code)
        
        response = client.change_password(
            PreviousPassword=old_password,
            ProposedPassword=new_password,
            AccessToken=accessToken
        )
        
        status_code = 200
        resp["error"] = False
        resp["success"] = True
        resp["message"] = "password changed successfully"
    # except client.exceptions.NotAuthorizedException as e:
    #     logger.error(e)
    #     resp["message"] = str(e).split('(')[1].split(')')[0]
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
    except client.exceptions.UserNotFoundException as e:
        status_code = 400
        logger.error(e)
        resp['error'] = True
        resp['success'] = False
        resp['message'] =  "User not found"
        resp['data'] = None
        return callback_response(status_code)
    except Exception as e:
        status_code = 500
        logger.error(e)
        resp["message"] = "something went wrong"
    return callback_response(status_code)

def callback_response(code):
    return {
    'statusCode': code,
    'body': resp
  }
  
  
def validate_payload(body, schema):
  response = { 'is_invalid': False, 'e': {} }
  try:
    validate(instance=body, schema=schema)
  except exceptions.ValidationError as err:
    response['is_invalid'] = True
    response['e']['error'] =  'INVALID_PAYLOAD'
    response['e']['message'] =  err.message
    logger.error("Exception: {}".format(err), exc_info=sys.exc_info())
  return response
  