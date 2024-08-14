import boto3
from boto3.dynamodb.conditions import Key
from os import getenv
import json

region_name = getenv('APP_REGION')
users_table = boto3.resource('dynamodb', region_name=region_name).Table('ds_users')

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

    return response(200, "User deleted")

def response(code, body):
    return {
        "statusCode": code,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": body
    }