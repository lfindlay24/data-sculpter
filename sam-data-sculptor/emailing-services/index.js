const AWS = require('aws-sdk');
const dynamodb = new AWS.DynamoDB.DocumentClient();
const nodemailer = require('nodemailer');
const bcrypt = require('bcryptjs');

const saltRounds = 12;

const transporter = nodemailer.createTransport({
    host: 'smtp.ethereal.email',
    port: 587,
    auth: {
        user: 'dock.medhurst@ethereal.email',
        pass: 'TscdVG1GRxnAg9JeKz'
    }
});

async function sendEmail(email, password) {
    const info = await transporter.sendMail({
        from: '"Data Sculptor" <dock.medhurst@ethereal.email>',
        to: email,
        subject: 'Temporary Password',
        text: 'Your temporary password is ' + password
    });
}
  
function response(statusCode, message) {
    return {
        statusCode: statusCode,
        body: JSON.stringify(message)
    };
}

async function updateUser(email, password) {
    let params = {
        TableName: 'ds_users',
        Key: {
            email: email
        },
        UpdateExpression: 'set #temp_password = :p',
        ExpressionAttributeNames: {
            '#temp_password': 'temp_password'
        },
        ExpressionAttributeValues: {
            ':p': password
        },
        ReturnValues: 'UPDATED_NEW'
    };
    return await dynamodb.update(params).promise();
}

module.exports.handler = async (event) => {
    if (!event.body) {
        return response(400, 'Invalid request');
    }
    let body = JSON.parse(event.body);
    if (!body.email) {
        return response(400, 'Invalid request');
    }
    let password = Math.random().toString(36).slice(-8);
    sendEmail(body.email, password);

    let encodedPassword = encodeURIComponent(password);
    let hashedPassword = await bcrypt.hash(encodedPassword, saltRounds);
    // ...
    await updateUser(body.email, hashedPassword);
    return response(200, 'Email sent');
};