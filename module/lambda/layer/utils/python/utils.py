import boto3
import json
import logging
import hmac
import hashlib
import html
import base64
from jsonschema import validate, exceptions
import sys
from os import getenv
from uuid import uuid4
from datetime import datetime
from time import time
from datetime import datetime, timezone, timedelta

from boto3.dynamodb.conditions import Key, Attr 

client_idp = boto3.client('cognito-idp')

db = boto3.resource("dynamodb")

if logging.getLogger().hasHandlers():
    logging.getLogger().setLevel(logging.INFO)
else:
    logging.basicConfig(level=logging.INFO)

logger = logging.getLogger()
contx = logging.getLogger()


def admin_get_user(cognito_client, user_pool_id, username):
    response = cognito_client.admin_get_user(
        UserPoolId=user_pool_id,
        Username=username
    )
    data = {
        attr.get('Name'): attr.get("Value") for attr in response["UserAttributes"]
    }
    return data

resp = {
    "error": True,
    "success": False,
    "message": "Something went wrong",
    "data": None
}

def get_secret_hash_individual(username, CLIENT_ID, CLIENT_SECRET):
    msg = username + CLIENT_ID
    dig = hmac.new(str(CLIENT_SECRET).encode('utf-8'), 
        msg = str(msg).encode('utf-8'), digestmod=hashlib.sha256).digest()
    d2 = base64.b64encode(dig).decode()
    return d2

def validate_payload(body, schema):
  response = { 'is_invalid': False, 'e': {} }
  try:
    validate(instance=body, schema=schema)
  except exceptions.ValidationError as err:
    response['is_invalid'] = True
    response['e']['error'] =  'INVALID_PAYLOAD'
    response['e']['message'] =  err.message
    contx.error("Exception: {}".format(err), exc_info=sys.exc_info())
  return response

def callbackRespondWithSimpleMessage(code, message):
  return {
    'statusCode': code,
    'message': message
  }
  
def callbackRespondWithJsonBody(code, body):
  return {
    'statusCode': code,
    'body': body
  }

def callback_response(code):
  return {
         'statusCode': code,
         'body': resp
     }

def get_user_id(cognito_client,access_token):
  auth_header = cognito_client.get_user(
            AccessToken = access_token
        )
  user = {attr.get("Name"): attr.get("Value") for attr in auth_header["UserAttributes"]}
  user_id = user['sub']
  return user_id

def get_user_details(cognito_client,access_token):
  auth_header = cognito_client.get_user(
            AccessToken = access_token
        )
  user = {attr.get("Name"): attr.get("Value") for attr in auth_header["UserAttributes"]}
  
  return user
  
def update_user_details(cognito_client,access_token,attributes):
  auth_header = cognito_client.update_user_attributes(
            UserAttributes=attributes,
            AccessToken = access_token
        )
  return 'done'

def admin_update_user_attr(pool_id, username, attributes):
  client_idp.admin_update_user_attributes(
            UserPoolId=pool_id,
            Username=username,
            UserAttributes=attributes
        )
  return 'done'

log_data = {
    "user_id": None,
    "activity_description": None,
    "status": None,
    "role": None,
    "type": None
}

def activity_log(event, log_data, table_name):
    """
      log user activity to the database
      
      :param event: event data received from lambda
      :param log_data: data to be logged to the table it contains
      [user_id, activity_description, role: user role, type: type of activity,
      status: status of the activity either success or error]
      :table_name: the name of the log table
      :return: activity logged
    """
    
    db = boto3.resource("dynamodb")
    log_table = db.Table(table_name)
    activity = {}
    user_id = log_data.get("user_id")
    # identity = event['requestContext']['identity']
    
    if 'body' in event and len(event['body']) == 0:
      body = event.get('queryStringParameters', {})
    else:
      body = event.get('body', {})

    activity['event_data'] = body
    activity['user_agent'] = event['user-agent']
    activity['sourceIp'] = event['source-ip']
    activity['path'] = event['resource-path']
    activity_description = log_data.get('activity_description')
    log_id = str(uuid4())
    created_at = int(time())
    status = log_data.get("status")
    log = {
        "pk": "log",
        "sk": f"{user_id}_{log_id}",
        'activity': activity,
        "description": activity_description,
        "role": log_data.get("role"),
        "type": log_data.get("type"),
        "status": status,
        "created_at": created_at
        }
    response = log_table.put_item(
      Item = log
    )
    print('activity_log respnse', response)
    return 'activity logged'

def get_current_time ():
    timezone_offset = timedelta(hours=1)
    desired_timezone = timezone(timezone_offset)
    current_time_utc = datetime.now(timezone.utc)
    current_time_desired = current_time_utc.astimezone(desired_timezone)
    unix_timestamp = int(current_time_desired.timestamp())
    return unix_timestamp
  
def read_template(bucketname, keyname):
    s3 = boto3.resource('s3')
    obj = s3.Object(bucketname, keyname)
    body = obj.get()['Body'].read()
    body = body.decode("utf-8")
    return body

def add_data(variables={}, code=""):
    print({"variables": variables})
    for variable in variables:
        print('the variable', variable)
        code = code.replace("{{"+str(variable)+"}}", variables[variable])
    return code

def send_user_email(sender, receiver, topic, template):
  client = boto3.client('ses')
  response = client.send_email(
                    Source=sender,
                    Destination={
                    'ToAddresses': receiver
                },
                    Message={
                        'Subject': {
                            'Data': topic,
                            'Charset': 'UTF-8',
                        },
                        'Body': {
                            'Html': {
                                'Charset': 'UTF-8',
                                'Data': template
                            }
                        }
                    }
                )
  return 'done'
  