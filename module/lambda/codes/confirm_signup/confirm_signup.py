import boto3
import hmac
import hashlib
import base64
import os
from utils import logger, resp, db
POOL_ID = os.environ["POOL_ID"]
CLIENT_ID = os.environ["CLIENT_ID"]
CLIENT_SECRET = os.environ["CLIENT_SECRET"]
client = boto3.client('cognito-idp')

def get_secret_hash(username, client_id, client_secret):
    msg = username + client_id
    dig = hmac.new(
        str(client_secret).encode('utf-8'),
        msg=str(msg).encode('utf-8'),
        digestmod=hashlib.sha256
    ).digest()
    d2 = base64.b64encode(dig).decode()
    return d2


def lambda_handler(event, context):
    print(event)
    try:
        
        body = event['body'] if 'body' in event and event['body'] is not None else event
        user_name = body["email"]
        code = body["code"]
        
        
        secret_hash = get_secret_hash(user_name, CLIENT_ID, CLIENT_SECRET)
        response = client.confirm_sign_up(
            ClientId=CLIENT_ID,
            SecretHash=secret_hash,
            Username=user_name,
            ConfirmationCode=code,
            ForceAliasCreation=False
        )
    
        # if response:
        #     return "account confirmed successfully"
        status_code = 200
        resp["error"] = False
        resp["success"] = True
        resp["message"] = "account confirmed successfully"
    except Exception as e:
        status_code = 500
        logger.error(e)
        resp["message"] = "something went wrong"
        resp["error"] = True
        resp["success"] = False
    return callback_response(status_code)
    

def callback_response(code):
  return {
         'statusCode': code,
         'body': resp
     }
