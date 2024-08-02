import boto3
from boto3.dynamodb.conditions import Attr
from os import getenv
import json
import bcrypt
from base64 import b64encode

region_name = getenv('APP_REGION')
users_table = boto3.resource('dynamodb', region_name=region_name).Table('ds_users')

def lambda_handler(event, context):
    
    body = json.loads(event["body"])

    if "email" not in body:
        return response(400, "Email is required")
    
    users = users_table.scan(FilterExpression=Attr("email").eq(body["email"]))
    if "Items" not in users and len(users["Items"]) <= 0:
        return response(400, "No user found with that email")
    
    if "password" not in body:
        return response(400, "Password is required")
    
    hashed_password_bytes = bytes(users["Items"][0]["password"])
    hashed_password = hashed_password_bytes.decode('utf-8')

    if not check_password(body["password"], hashed_password):
        return response(400, "Incorrect password")
    
    stringtoencode = f"{body['email']}:{body['password']}"
    encoded = b64encode(stringtoencode.encode('utf-8'))
    return response(200, {"Authorization": encoded.decode("utf-8")})
    
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