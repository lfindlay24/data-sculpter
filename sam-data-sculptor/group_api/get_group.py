import boto3
from boto3.dynamodb.conditions import Attr
from os import getenv
import json

region_name = getenv('APP_REGION')
groups_table = boto3.resource('dynamodb', region_name=region_name).Table('ds_groups')

def lambda_handler(event, context):

    body = json.loads(event["body"])

    # check that all needed data was provided
    if "group_name" not in body:
        return response(400, "Group name is required")
    
    # check if the group exists
    groups = groups_table.scan(FilterExpression=Attr("group_name").eq(body["group_name"]))
    if "Items" not in groups or len(groups["Items"]) == 0:
        return response(404, "Group not found")
    
    group = groups["Items"][0]

    return response(200, group)
    
def response(status_code, message):
    return {
        "statusCode": status_code,
        "body": json.dumps(message)
    }