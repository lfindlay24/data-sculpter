import boto3
from boto3.dynamodb.conditions import Key
from os import getenv
import json
import bcrypt
from base64 import b64encode

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
    print(user)
    if "Item" not in None:
        return response(404, "user not found")
    
    user = user["Item"]

    if not check_password(body["old_password"], user["password"]):
        return response(400, "incorrect old password")
    
    if "email" in body:
        user["email"] = body["email"]
    if "new_password" in body:
        user["password"] = salt_hash_password(body["new_password"])
    
    users_table.put_item(Item=user)

    stringtoencode = f"{body["email"]}:{body['new_password']}"
    encoded = b64encode(stringtoencode.encode('utf-8'))
    print(f"Encoded: {encoded}")

    return response(200, {"Authorization": encoded.decode("utf-8")})

def salt_hash_password(password):
    encoded = password.encode('utf-8')
    salt = bcrypt.gensalt()
    hash = bcrypt.hashpw(encoded, salt)
    return hash

def check_password(password, hashed_password):
    return bcrypt.checkpw(password.encode('utf-8'), hashed_password.encode('utf-8'))

def response(code, body):

    return {
        "statusCode": code,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps(body)
    }