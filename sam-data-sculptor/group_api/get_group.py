import boto3
from boto3.dynamodb.conditions import Attr
from os import getenv
import json

region_name = getenv('APP_REGION')
groups_table = boto3.resource('dynamodb', region_name=region_name).Table('ds_groups')

def lambda_handler(event, context):

    path = event["pathParameters"]

    if path is None or "group_name" not in path:
        return response(400, "Group name is required")
    
    group_name = path["group_name"]
    
    # check if the group exists
    groups = groups_table.scan(FilterExpression=Attr("group_name").eq(group_name))
    if "Items" not in groups or len(groups["Items"]) == 0:
        return response(404, "Group not found")
    
    group = groups["Items"][0]

    return response(200, group)
    
def response(code, body):
    return {
        "statusCode": code,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps(body)
    }