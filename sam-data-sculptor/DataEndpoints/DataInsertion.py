import boto3
from boto3.dynamodb.conditions import Key
from os import getenv
from uuid import uuid4
import json
from datetime import datetime
 
region_name = getenv('APP_REGION')
json_table = boto3.resource('dynamodb', region_name=region_name ).Table('ds_user_json')
 
def lambda_handler(event, context):
    # make a separate table with its own ID and a user ID
    jsonId = str(uuid4())
    body = json.loads(event['body'])
    email = body['email']
    content = body['content']

    if not all([jsonId, body, email]):
        return response(400, {"error":"Missing required fields"})
    
    try:
        json_table.put_item(Item={
            'json_id': jsonId,
            'email': email,
            'content': content
        })
    except Exception as e:
        return response(500, {"error": str(e)})
    
    return response(200, {"id": jsonId})


def response(code, body):
    return {
        "statusCode": code,
        "headers": {
            "Content-Type": "application/json"
            },
        "body": json.dumps(body)
    }