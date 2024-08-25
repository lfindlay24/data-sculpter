import boto3
from boto3.dynamodb.conditions import Attr
from os import getenv
import json
import bcrypt

region_name = getenv('APP_REGION')
groups_table = boto3.resource('dynamodb', region_name=region_name).Table('ds_groups')
users_table = boto3.resource('dynamodb', region_name=region_name).Table('ds_users')
sqs_client = boto3.client('sqs', region_name=region_name)
sqs_url = getenv('SQS_URL')

def lambda_handler(event, context):

    body = json.loads(event["body"])

    # check that all needed data was provided
    if "group_name" not in body:
        return response(400, "Group name is required")
    
    if "admin_email" not in body:
        return response(400, "Admin email is required")
    
    if "admin_password" not in body:
        return response(400, "Admin password is required")
    
    # check if the group exists
    groups = groups_table.scan(FilterExpression=Attr("group_name").eq(body["group_name"]))
    if "Items" not in groups or len(groups["Items"]) == 0:
        return response(400, "Group does not exist")
    group = groups["Items"][0]

    # check if the admin is the admin of the group
    if body["admin_email"] not in group["admin_emails"]:
        return response(403, "You are not the admin of this group")
    
    # check if the admin exists and if the password is correct
    admin = users_table.scan(FilterExpression=Attr("email").eq(body["admin_email"]))
    if "Items" not in admin or len(admin["Items"]) == 0:
        return response(400, "Admin does not exist")
    admin = admin["Items"][0]

    hashed_password_bytes = bytes(admin["password"])
    hashed_password = hashed_password_bytes.decode('utf-8')
    if not check_password(body["admin_password"], hashed_password):
        return response(400, "Incorrect admin password")
    
    # send email to admin
    send_message({
        "recipient": body["admin_email"],
        "subject": "Group deleted",
        "message": f"You have successfully deleted the group {body['group_name']}"
    })

    # delete the group
    groups_table.delete_item(Key={"group_name": body["group_name"]})

def check_password(password, hashed_password):
    return bcrypt.checkpw(password.encode('utf-8'), hashed_password.encode('utf-8'))

def send_message(message):
    return sqs_client.send_message(
        QueueUrl=sqs_url,
        MessageBody=json.dumps(message)
    )

def response(status_code, message):
    return {
        "statusCode": status_code,
        "body": json.dumps(message)
    }