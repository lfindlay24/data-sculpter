import boto3
from boto3.dynamodb.conditions import Key
from os import getenv
from uuid import uuid4
import json
from datetime import datetime
 
region_name = getenv('APP_REGION')
performances_table = boto3.resource('dynamodb', region_name=region_name ).Table('')
 
 
def lambda_handler(event, context):
    bucket_name = event['Records'][0]['s3']['bucket']['name']
    file_key = event['Records'][0]['s3']['bucket']['key']

    s3 = boto3.client('s3')

    response = s3.get_object(Bucket=bucket_name, Key=file_key)
    file_content = response['Body'].read().decode('utf-8')

    body = json.loads(file_content)

    print(body)

def response(code, body):
    return {
        "statusCode": code,
        "headers": {
            "Content-Type": "application/json"
            },
        "body": json.dumps(body)
    }