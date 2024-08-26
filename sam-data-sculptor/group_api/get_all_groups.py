import boto3
from boto3.dynamodb.conditions import Attr
from os import getenv
import json

region_name = getenv('APP_REGION')
groups_table = boto3.resource('dynamodb', region_name=region_name).Table('ds_groups')

def lambda_handler(event, context):

    headers = event["headers"]

    # check that all needed data was provided
    if "email" not in headers or headers["email"] == "":
        return response(400, "email is required")
    
    groups = groups_table.scan(FilterExpression=Attr("admin_emails").contains(headers["email"]))

    if "Items" not in groups or len(groups["Items"]) == 0:
        return response(404, "No groups found")

    return response(200, groups["Items"])
    
def response(code, body):
    return {
        "statusCode": code,
        "headers": {
            "Content-Type": "application/json"
            },
        "body": json.dumps(body)
    }