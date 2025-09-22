import boto3
import hmac
import hashlib
import base64
import os
from utils import logger, resp, db, callback_response

POOL_ID = os.environ["POOL_ID"]
CLIENT_ID = os.environ["CLIENT_ID"]
CLIENT_SECRET = os.environ["CLIENT_SECRET"]

client = boto3.client('cognito-idp')


def get_secret_hash_individual(username):
    msg = username + CLIENT_ID
    dig = hmac.new(str(CLIENT_SECRET).encode('utf-8'),
        msg=str(msg).encode('utf-8'), digestmod=hashlib.sha256).digest()
    d2 = base64.b64encode(dig).decode()
    return d2


def lambda_handler(event, _):
    status_code = 400
    logger.info(event)
    
    try:
        body = event['body'] if 'body' in event and event['body'] is not None else event
        username = body["email"]
        secret_hash = get_secret_hash_individual(username)
        
        client.resend_confirmation_code(
            ClientId=CLIENT_ID,
            SecretHash=secret_hash,
            Username=username
        )
        status_code = 200
        resp["error"] = False
        resp["success"] = True
        resp["message"] = "code sent successful"
        return callback_response(status_code)
    
    except client.exceptions.UserNotFoundException as e:
        logger.error(e)
        status_code = 404
        resp["error"] = True
        resp["success"] = False
        resp["message"] = "User not found"
        return callback_response(status_code)
    except Exception as e:
        status_code = 500
        logger.error(e)
        resp["message"] = "something went wrong"
        return callback_response(status_code)