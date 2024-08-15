import boto3
from boto3.dynamodb.conditions import Attr
from botocore.exceptions import ClientError
from os import getenv
import json
import bcrypt
import time
from base64 import b64encode

region_name = getenv('APP_REGION')
users_table = boto3.resource('dynamodb', region_name=region_name).Table('ds_users')
sqs_client = boto3.client('sqs', region_name=region_name)
sqs_url = "https://sqs.us-east-2.amazonaws.com/339712966749/ds_message_queue.fifo"

def lambda_handler(event, context):

    body = json.loads(event["body"])

    print(f"Request body: {body}")

    if "email" not in body:
        return response(400, "Email is required")
    
    users = users_table.scan(FilterExpression=Attr("email").eq(body["email"]))
    if "Items" in users and len(users["Items"]) > 0:
        return response(400, "Email already exists")
    
    if "password" not in body:
        return response(400, "Password is required")

    email = body["email"]
    
    hashing_start = time.time()
    hashed_password = salt_hash_password(body["password"])
    hashing_end = time.time()

    print(f"Hashing time: {hashing_end - hashing_start} seconds")
    print(f"Password: {hashed_password}")
    print(f"Email: {email}")

    dynamo_start = time.time()
    users_table.put_item(Item={
        "email": email,
        "password": hashed_password
    })
    dynamo_end = time.time()

    print(f"DynamoDB put_item time: {dynamo_end - dynamo_start} seconds")

    stringtoencode = f"{email}:{body['password']}"
    encoded = b64encode(stringtoencode.encode('utf-8'))
    print(f"Encoded: {encoded}")

    print(send_message({
        "recipient": body["email"], 
        "subject": "Welcome to Data Sculptor",
        "message": "Welcome to Data Sculptor! You have successfully created an account."
    }))


    return response(200, {"Authorization": encoded.decode("utf-8")})

def salt_hash_password(password):
    encoded = password.encode('utf-8')
    salt = bcrypt.gensalt()  # Adjust rounds for faster hashing
    hash = bcrypt.hashpw(encoded, salt)
    return hash

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
