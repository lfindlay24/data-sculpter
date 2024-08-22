import boto3
from boto3.dynamodb.conditions import Key
from os import getenv
from uuid import uuid4
import json
 
region_name = getenv('APP_REGION')
json_table = boto3.resource('dynamodb', region_name=region_name ).Table('ds_user_json')
 
def lambda_handler(event, context):
 
    body = json.loads(event['body'])
    id = body['json_id']
    content = body["content"]

    if "id" is not event or id is None:
        response(400, "Id is required")
 
    json_data = json_table.get_item(Key={"json_id":id})["Item"]
    if json_data is None:
        response(404, "Performance not found")
    if content is not None:
        json_data['content'] = content

 
    json_table.put_item(Item=json_data)
    return response(200, json_data)
 
 
def response(code, body):
    return {
        "statusCode": code,
        "headers": {
            "Content-Type": "application/json"
            },
        "body": json.dumps(body)
    }