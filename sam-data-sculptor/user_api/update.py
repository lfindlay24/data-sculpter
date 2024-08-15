import boto3
from boto3.dynamodb.conditions import Key
from botocore.exceptions import ClientError
from os import getenv
import json
import bcrypt
from base64 import b64encode

region_name = getenv('APP_REGION')
users_table = boto3.resource('dynamodb', region_name=region_name).Table('ds_users')
sqs_client = boto3.client('sqs', region_name=region_name)
sqs_url = "https://sqs.us-east-2.amazonaws.com/339712966749/ds_message_queue.fifo"

def lambda_handler(event, context):

    if "body" not in event:
        return response(400, "no body found")
    
    body = json.loads(event["body"])
    if body is None or "email" not in body:
        return response(400, "no email found in body")
    
    email = body["email"]
    user = users_table.get_item(Key={"email": email})
    print(user)
    if "Item" not in user:
        return response(404, "user not found")
    
    user = user["Item"]

    if "temp_password" in user:
        hashed_password = user["temp_password"]
            
    else:
        hashed_password_bytes = bytes(user["password"])
        hashed_password = hashed_password_bytes.decode('utf-8')

    if not check_password(body["old_password"], hashed_password):
        return response(400, "incorrect old password")
    
    if "new_password" not in body:
        return response(400, "new password is required")
    
    user["password"] = salt_hash_password(body["new_password"])
    
    try:
        # Update the user, remove the temp_password field, and update the password field
        users_table.update_item(
            Key={'email': body['email']},
            UpdateExpression="REMOVE temp_password SET #pwd = :new_password",
            ExpressionAttributeNames={'#pwd': 'password'},
            ExpressionAttributeValues={':new_password': user["password"]},
            ReturnValues="UPDATED_NEW"
        )
    
    except ClientError as e:
        return {
            'statusCode': 400,
            'body': f"Error updating user: {e.response['Error']['Message']}"
        }

    stringtoencode = f"{body["email"]}:{body['new_password']}"
    encoded = b64encode(stringtoencode.encode('utf-8'))
    print(f"Encoded: {encoded}")

    message_response = send_message({
        "recipient": body["email"],
        "subject": "Password Changed",
        "message": "Your password has been successfully changed"
    })

    return response(200, {"Authorization": encoded.decode("utf-8"), "MessageResponse": message_response})

def salt_hash_password(password):
    encoded = password.encode('utf-8')
    salt = bcrypt.gensalt()
    hash = bcrypt.hashpw(encoded, salt)
    return hash

def check_password(password, hashed_password):
    return bcrypt.checkpw(password.encode('utf-8'), hashed_password.encode('utf-8'))

def send_message(message_body, message_group_id="emails"):
    try:
        message_response = sqs_client.send_message(
            QueueUrl=sqs_url,
            MessageBody=json.dumps(message_body),
            MessageAttributes={
                'Author': {
                    'DataType': 'String',
                    'StringValue': 'Email Request'
                }
            },
            MessageGroupId=message_group_id
        )
        return message_response
    except ClientError as e:
        print(f"Error sending message: {e}")
        return None

def response(code, body):

    return {
        "statusCode": code,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps(body)
    }