import boto3
from boto3.dynamodb.conditions import Key
from boto3.dynamodb.conditions import Attr
from decimal import Decimal
from os import getenv
from uuid import uuid4
import json
from datetime import datetime
 
region_name = getenv('APP_REGION')
json_table = boto3.resource('dynamodb', region_name=region_name ).Table('ds_user_json')
 
def lambda_handler(event, context):
    # make a separate table with its own ID and a user ID
    email = event['headers']['email']

    if not all([email]):
        return response(400, {"error":"Missing Email header"})
    
    try:
        user_content = json_table.scan(FilterExpression=Attr("email").eq(email))
    except Exception as e:
        return response(500, {"error": str(e)})
    
    return response(200, user_content)

def response(code, body):
    return {
        "statusCode": code,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps(body, cls=DecimalEncoder) 
    }

#Taken from chatGPT
class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Decimal):
            return str(obj)  
        return super(DecimalEncoder, self).default(obj)