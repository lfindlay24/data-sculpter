import boto3
from boto3.dynamodb.conditions import Attr
from botocore.exceptions import ClientError
from os import getenv
import json

region_name = getenv('APP_REGION')
groups_table = boto3.resource('dynamodb', region_name=region_name).Table('ds_groups')
sqs_client = boto3.client('sqs', region_name=region_name)
sqs_url = getenv('SQS_URL')

def lambda_handler(event, context):
    
    body = json.loads(event["body"])

    print(f"Request body: {body}")

    if "group_name" not in body:
        return response(400, "Group name is required")
    
    if "admin_email" not in body:
        return response(400, "Admin email is required")
    
    groups = groups_table.scan(FilterExpression=Attr("group_name").eq(body["group_name"]))

    if "Items" in groups and len(groups["Items"]) > 0:
        return response(400, "Group name already exists")
    
    group_name = body["group_name"]
    admin_email = [body["admin_email"]]
    user_emails = [body["admin_email"]]

    groups_table.put_item(Item={
        "group_name": group_name,
        "admin_emails": admin_email,
        "user_emails": user_emails
    })

    print(send_message({
        "recipient": body["admin_email"],
        "subject": "You have created a group",
        "message": f"You have successfully created a group named {group_name}"
    }))

    return response(200, "Group created successfully")
    
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
        "body": json.dumps(body)
    }