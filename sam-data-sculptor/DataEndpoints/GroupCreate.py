import boto3
from boto3.dynamodb.conditions import Key
from os import getenv
from uuid import uuid4
import json
from datetime import datetime
 
region_name = getenv('APP_REGION')
json_table = boto3.resource('dynamodb', region_name=region_name ).Table('ds_user_json')
 
def lambda_handler(event, context):
    body = json.loads(event['body'])
    id = body['json_id']
    groupName = body['groupName']

    if not all([id, body, groupName]):
        return response(400, {"error":"Missing required fields"})
    

    json_data = json_table.get_item(Key={"json_id":id})["Item"]
    if json_data is None:
        response(404, "Data not found")

    json_data['groupName'] = groupName
    json_table.put_item(Item=json_data)

    
    return response(200, {"id": id})


def response(code, body):
    return {
        "statusCode": code,
        "headers": {
            "Content-Type": "application/json"
            },
        "body": json.dumps(body)
    }