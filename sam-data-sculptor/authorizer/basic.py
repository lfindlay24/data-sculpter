import boto3
from boto3.dynamodb.conditions import Attr
from os import getenv
import re
import bcrypt
from base64 import b64decode
from bson import Binary

region_name = getenv('APP_REGION')
users_table = boto3.resource('dynamodb', region_name=region_name).Table('ds_users')

def lambda_handler(event, context):

    print(event)

    auth = "Deny"

    authorization = event["authorizationToken"]
    print(authorization)

    b64decoded = b64decode(authorization)

    print(b64decoded)

    matcher = re.match(br"^([^:]+):(.+)$", b64decoded)
    print(f"Email: {matcher.group(1)}, Password: {matcher.group(2)}")

    email = matcher.group(1).decode("utf-8")
    password = matcher.group(2).decode("utf-8")
    print(f"Email: {email}, Password: {password}")

    user = get_user(email)
    hashed_password = user["password"].decode("utf-8")
    print(hashed_password)
    # print(f"User_id: {user['user_id']}, Email: {user['email']}, Password: {user['password'].decode('utf-8')}")

    # if check_password(password, user["password"]):
    #     auth = "Allow"

    authResponse = {
        "principalId": f"abcd",
        "policyDocument": {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Action": "execute-api:Invoke",
                    "Effect": auth,
                    "Resource": event["methodArn"]
                }
            ]
        },
        "context": {
            "exampleKey": "exampleValue"
        }
    }

    return authResponse

def get_user(email):
    users = users_table.scan(FilterExpression=Attr("email").eq(email))
    if "Items" in users and len(users["Items"]) == 1:
        return users["Items"][0]
    
def check_password(password, hashed_password):
    return bcrypt.checkpw(password.encode('utf-8'), hashed_password.encode('utf-8'))
