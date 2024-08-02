import boto3
from boto3.dynamodb.conditions import Key
from os import getenv

region_name = getenv('APP_REGION')
users_table = boto3.resource('dynamodb', region_name=region_name).Table('ds_users')

def lambda_handler(event, context):

    if "pathParameters" not in event:
        return response(400, "no path parameters found")
    
    path = event["pathParameters"]
    if path is None or "userId" not in path:
        return response(400, "no user id found in path")
    
    user_id = path["userId"]
    user = users_table.get_item(Key={"user_id": user_id})
    print(user)
    if "Item" not in user:
        return response(404, "user not found")
    
    users_table.delete_item(Key={"user_id": user_id})

    return response(200, "User deleted")

def response(code, body):
    return {
        "statusCode": code,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": body
    }