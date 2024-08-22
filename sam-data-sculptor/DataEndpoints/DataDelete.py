import boto3
from boto3.dynamodb.conditions import Key
from os import getenv
from uuid import uuid4
import json
 
region_name = getenv('APP_REGION')
json_table = boto3.resource('dynamodb', region_name=region_name ).Table('ds_user_json')
 
 
def lambda_handler(event, context):
    if "pathParameters" not in event:    
        return response(400, {"error": "no path params"})
   
    path = event["pathParameters"]
   
    if path is None or "id" not in path:
        return response(400, "no id found")
   
    id = path["id"]   
   
    output = json_table.delete_item(Key={"json_id":id})
   
    return response(200, output)
    
def response(code, body):
    return {
        "statusCode": code,
        "headers": {
            "Content-Type": "application/json"
            },
        "body": json.dumps(body)
    }