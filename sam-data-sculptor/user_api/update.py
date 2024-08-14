import boto3
from boto3.dynamodb.conditions import Key
from os import getenv
import json
import bcrypt
from base64 import b64encode

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
    
    user = user["Item"]

    hashed_password_bytes = bytes(user["password"])
    hashed_password = hashed_password_bytes.decode('utf-8')

    if not check_password(body["old_password"], hashed_password):
        return response(400, "incorrect old password")
    
    if "new_password" not in body:
        return response(400, "new password is required")
    
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