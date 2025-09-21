import boto3
import hmac
import hashlib
import base64
import os
from utils import logger, resp
from json import load
import sys
from jsonschema import validate, exceptions

POOL_ID = os.environ["POOL_ID"]
CLIENT_ID = os.environ["CLIENT_ID"]
CLIENT_SECRET = os.environ["CLIENT_SECRET"]
client = boto3.client('cognito-idp')


def get_secret_hash_individual(username):
    msg = username + CLIENT_ID
    dig = hmac.new(
        str(CLIENT_SECRET).encode('utf-8'),
        msg=str(msg).encode('utf-8'),
        digestmod=hashlib.sha256
    ).digest()
    d2 = base64.b64encode(dig).decode()
    return d2


def lambda_handler(event, _):
    status_code = 400
    logger.info(event)
    try:
        body = event['body'] if 'body' in event and event['body'] is not None else event
        
        with open('confirm_forgot_password.json') as f:
            schema = load(f)
      
        payload = validate_payload(body, schema)
        status_code = 400
        if payload['is_invalid']:
          resp['message'] = "invalid payload"
          return callback_response(status_code)
        
        secret_hash = get_secret_hash_individual(body["email"])

        client.confirm_forgot_password(
            ClientId=CLIENT_ID,
            SecretHash=secret_hash,
            Username=body["email"],
            ConfirmationCode=body["code"],
            Password=body["password"]
        )
        email = body["email"]
        message_details = "Your password reset was successful"
        status_code = 200
        resp["error"] = False
        resp["success"] = True
        resp["message"] = "password reset successful"
        
    except client.exceptions.InvalidPasswordException as e:
        logger.error(e)
        response_string = str(e)
        resp["message"] = "Password must have uppercase, lowercase and special characters and be up to 8 characters"
    except client.exceptions.NotAuthorizedException as e:
        logger.error(e)
        response_string = str(e)
        resp["message"] = response_string.split(":", 1)[-1].strip()
    except client.exceptions.LimitExceededException as e:
        logger.error(e)
        resp["message"] = "Attempt Limit Exceeded"
    except client.exceptions.UserNotConfirmedException as e:
        logger.error(e)
        response_string = str(e)
        resp["message"] = response_string.split(":", 1)[-1].strip()
    except client.exceptions.UserNotFoundException as e:
        logger.error(e)
        response_string = str(e)
        resp["message"] = response_string.split(":", 1)[-1].strip()
    except client.exceptions.ExpiredCodeException as e:
        logger.error(e)
        response_string = str(e)
        resp["message"] = response_string.split(":", 1)[-1].strip()
    except client.exceptions.CodeMismatchException as e:
        logger.error(e)
        response_string = str(e)
        resp["message"] = response_string.split(":", 1)[-1].strip()
    except Exception as e:
        status_code = 400
        logger.error(e)
        resp["message"] = "Something went wrong"
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