import json
import boto3
import os
from boto3.dynamodb.conditions import Key
import logging


client = boto3.client('cognito-idp')

dynamodb = boto3.resource('dynamodb')
table_name = os.environ["USER_TABLE_NAME"]
table = dynamodb.Table(table_name)
enviroment = os.getenv('ENV')

def lambda_handler(event, context):
    logging.info(event)
    print({'event':event})
    try:
        if event['request'].get('challengeAnswer'):
            answer = event['request'].get('challengeAnswer')
        if event['request']['privateChallengeParameters']['answer'] == event['request']['challengeAnswer']:
            event['response']['answerCorrect'] = True
            sub = event['request']["userAttributes"]['sub']
            email = get_user_email(sub)
            delete_otp(table, email, answer)
        else:
            event['response']['answerCorrect'] = False
    
        print(event['response']['answerCorrect'])
    except Exception as e:
        logging.error(e)
    return event


def delete_otp(tablename, email, code):
    tablename.delete_item(
            Key={
            'pk': f'login_{email}',
            'sk': str(code),
            }
        )
    return "deleted successfully"
    
def get_user_email(sub):
    try:
        response = client.admin_get_user(
                                UserPoolId=get_pool_id(), 
                                Username=sub
                                )
        user = {attr.get("Name"): attr.get("Value") for attr in response["UserAttributes"]}
        user_email = user['email']
    except client.exceptions.UserNotFoundException as e:
        return "user not found"
    except Exception as e:
        return "user not found"
    return user_email
    
    
def get_pool_id():
    try:
        response = client.describe_user_pool(
                                UserPoolId=f'{enviroment}-noughttrapper-end_user-userpool'
                            )
        
        userpool = response['UserPool']
        
        operator_userpool_id = userpool['Id']
    except Exception as e:
        return "userpool not found"
    return operator_userpool_id