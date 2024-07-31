import boto3
from os import getenv
from uuid import uuid4
import json
import bcrypt
import time

region_name = getenv('APP_REGION')
users_table = boto3.resource('dynamodb', region_name=region_name).Table('ds_users')

def lambda_handler(event, context):

    body = json.loads(event["body"])

    print(f"Request body: {body}")

    if "email" not in body:
        return response(400, "Email is required")
    if "password" not in body:
        return response(400, "Password is required")

    user_id = str(uuid4())
    email = body["email"]
    
    hashing_start = time.time()
    password = salt_hash_password(body["password"])
    hashing_end = time.time()

    print(f"Hashing time: {hashing_end - hashing_start} seconds")
    print(f"Password: {password}")
    print(f"Email: {email}")
    print(f"User ID: {user_id}")

    dynamo_start = time.time()
    users_table.put_item(Item={
        "user_id": user_id,
        "email": email,
        "password": password
    })
    dynamo_end = time.time()

    print(f"DynamoDB put_item time: {dynamo_end - dynamo_start} seconds")

    return response(200, {"user_id": user_id})

def salt_hash_password(password):
    encoded = password.encode('utf-8')
    salt = bcrypt.gensalt(rounds=10)  # Adjust rounds for faster hashing
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
