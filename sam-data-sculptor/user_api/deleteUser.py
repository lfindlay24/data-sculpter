import boto3
from boto3.dynamodb.conditions import Key
from botocore.exceptions import ClientError
from os import getenv
import json

region_name = getenv('APP_REGION')
users_table = boto3.resource('dynamodb', region_name=region_name).Table('ds_users')
sqs_client = boto3.client('sqs', region_name=region_name)
sqs_url = getenv('SQS_URL')

def lambda_handler(event, context):

    if "body" not in event:
        return response(400, "no body found")
    
    body = json.loads(event["body"])
    if body is None or "email" not in body:
        return response(400, "no email found in body")
    
    email = body["email"]
    user = users_table.get_item(Key={"email": email})
    print(user)
    if "Item" not in user:
        return response(404, "user not found")
    
    users_table.delete_item(Key={"email": email})

    print(send_message({
        "recipient": body["email"], 
        "subject": "You have deleted your account.",
        "message": "You have deleted your Data Sculptor account. Sorry to see you go.:("
    }))

    return response(200, "User deleted")

def send_message(message_body, message_group_id="emails"):
    try:
        message_response = sqs_client.send_message(
            QueueUrl=sqs_url,
            MessageBody=json.dumps(message_body),
            MessageAttributes={
                'Author': {
                    'DataType': 'String',
                    'StringValue': 'Email Request'
                }
            },
            MessageGroupId=message_group_id
        )
        return message_response
    except ClientError as e:
        print(f"Error sending message: {e}")
        return None

def response(code, body):
    return {
        "statusCode": code,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": body
    }