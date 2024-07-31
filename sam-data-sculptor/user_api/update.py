import boto3
from boto3.dynamodb.conditions import Key
from os import getenv
import json
import bcrypt

region_name = getenv('APP_REGION')
users_table = boto3.resource('dynamodb', region_name=region_name).Table('Users')

def lambda_handler(event, context):
    
    body = json.loads(event["body"])

    if "pathParameters" not in event:
        return response(400, "no path parameters found")
    
    path = event["pathParameters"]
    if path is None or "userId" not in path:
        return response(400, "no user id found in path")
    
    user_id = path["userId"]
    user = users_table.get_item(Key={"user_id": user_id})
    if user is None:
        return response(404, "user not found")

def salt_hash_password(password):
    encoded = password.encode('utf-8')
    salt = bcrypt.gensalt()
    hash = bcrypt.hashpw(encoded, salt)
    return hash

def response(code, body):

    return {
        "statusCode": code,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps(body)
    }