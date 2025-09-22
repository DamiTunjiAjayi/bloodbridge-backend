import json
import boto3 
from boto3.dynamodb.conditions import Key, Attr
import logging

logging.basicConfig(format='%(asctime)s %(message)s', datefmt='%m/%d/%Y %I:%M:%S %p')


def lambda_handler(event, context):
    logging.info(event)
    try:
        if (len(event["request"]["session"]) > 0 and event["request"]["session"][-1]["challengeName"] != "CUSTOM_CHALLENGE"):
            event["response"]["issueTokens"] = False
            event["response"]["failAuthentication"] = True
        elif (len(event["request"]["session"]) >= 3 and event["request"]["session"][-1]["challengeResult"] is False):
            event["response"]["issueTokens"] = False
            event["response"]["failAuthentication"] = True
        elif (len(event["request"]["session"]) > 0 and event["request"]["session"][-1]["challengeResult"] is True):
            event["response"]["issueTokens"] = True
            event["response"]["failAuthentication"] = False
        else:
            event["response"]["issueTokens"] = False
            event["response"]["failAuthentication"] = False
            event["response"]["challengeName"] = "CUSTOM_CHALLENGE"
    except Exception as e:
        logging.error(e)
    return event
    