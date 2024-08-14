import boto3
from boto3.dynamodb.conditions import Key
from os import getenv
import json
from base64 import b64decode

region_name = getenv('APP_REGION')
users_table = boto3.resource('dynamodb', region_name=region_name).Table('ds_users')

def lambda_handler(event, context):

    print(event)

    if "pathParameters" not in event:
        return response(400, "no path parameters found")
    
    path = event["pathParameters"]
    if path is None or "userId" not in path:
        return response(400, "no user id found in path")
    
    user_id = path["userId"]
    user = users_table.get_item(Key={"user_id": user_id})

    if "Item" not in user:
        return response(404, "user not found")
    
    return_User = {}
    return_User["user_id"] = user["Item"]["user_id"]
    return_User["email"] = user["Item"]["email"]
    hashed_password_bytes = bytes(user["Item"]["password"])
    hashed_password = hashed_password_bytes.decode('utf-8')
    return_User["password"] = hashed_password
    
    return response(200, return_User)

def response(code, body):
    return {
        "statusCode": code,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps(body)
   }