import os
import boto3
import requests
import json

ENV = os.environ["ENV"]
BUCKET_NAME = os.environ["BUCKET_NAME"]
RESEND_API_KEY = os.environ["RESEND_API_KEY"]

# Initialize S3 client
s3 = boto3.resource('s3')


def lambda_handler(event, context):
    print("Received event:", json.dumps(event))

    # username = event.get('userName', '')
    email = event['request']['userAttributes'].get('email', '')
    username = event['request']['userAttributes'].get('name', '')
    # code = event['request'].get('codeParameter')
    # if code == None:
    # meta_data = event['request'].get('clientMetadata')
    # if meta_data:
    #     code = meta_data.get("codeParameter")
    # else:
    
    code = event['request'].get('codeParameter')
        
    link = event['request'].get('linkParameter')
    name = event['request']['userAttributes'].get('name', email)
    # url_env = f"app.{ENV}.wishub.com" if ENV != 'prod' else "app.wishub.com"
    
    # url_env = "wishub.com"
    url_env = "https://wishub-frontend-ypfo.vercel.app/"
    


    # Determine the email template and subject based on the trigger
    if event['triggerSource'] in ["CustomMessage_SignUp", "CustomMessage_AdminCreateUser"]:
        subject = "[wishub] Registration Email Verification"
        template_path = "email_templates/signup.html"
    elif event['triggerSource'] == "CustomMessage_ForgotPassword":
        subject = "[wishub] Request to reset your password"
        template_path = "email_templates/forgot_password.html"
    elif event['triggerSource'] == "CustomMessage_UpdateUserAttribute":
        subject = "Validate your new email"
        template_content = f"""
        Hi <b>{username}</b>!<br>
        Click <a href='https://wishub.com/confirm-email-change?code={code}'>here</a> 
        to validate your new email.
        """
    elif event['triggerSource'] == "CustomMessage_ResendCode":
        subject = "[wishub] Request for signup confirmation code"
        template_path = "email_templates/email_otp.html"
    else:
        print("Unknown triggerSource. Exiting.")
        return event

    # Read email template if needed
    if event['triggerSource'] != "CustomMessage_UpdateUserAttribute":
        template_content = read_template(BUCKET_NAME, template_path)
        template_content = add_data({
            "name": name,
            "code": code,
            "link": link,
            "url_env": url_env,
            "email_link": email,
            "username": name
        }, template_content)


    # Send email via Resend
    send_email_via_resend(email, subject, template_content)

    return event


def read_template(bucketname, keyname):
    obj = s3.Object(bucketname, keyname)
    body = obj.get()['Body'].read().decode("utf-8")
    return body


def add_data(variables, template):
    for key, value in variables.items():
        print(f"okaaa, {key} and {value}")
        
        template = template.replace(f"{{{{{key}}}}}", str(value))
        # print(f"the template {template}")
        
    return template

def send_email_via_resend(to_email, subject, content):
    url = "https://api.resend.com/emails"
    headers = {
        "Authorization": f"Bearer {RESEND_API_KEY}",
        "Content-Type": "application/json"
    }
    payload = {
        "from": "info@m4ace.com",  # Must match a verified domain in Resend
        "to": [to_email],
        "subject": subject,
        "html": content
    }

    response = requests.post(url, headers=headers, json=payload)
    print("Resend API Response:", response.status_code, response.text)

    if response.status_code != 200:
        raise Exception(f"Failed to send email: {response.text}")
