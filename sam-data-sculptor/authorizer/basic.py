import json

def lambda_handler(event, context):

    if event['authorizationToken'] == "abc123":
        auth = "Allow"
    else:
        auth = "Deny"

    authResponse = {}
    authResponse['principalId'] = 'abc123'
    authResponse['policyDocument'] = {
        'Version': '2012-10-17',
        'Statement': [
            {
                'Action': 'execute-api:Invoke',
                'Effect': auth,
                'Resource': ["arn:aws:execute-api:us-east-2:339712966749:b2a94j15zg/*/*"]
            }
        ]
    }

    return authResponse