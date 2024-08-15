const AWS = require('aws-sdk');
const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
    host: 'smtp.ethereal.email',
    port: 587,
    auth: {
        user: 'dock.medhurst@ethereal.email',
        pass: 'TscdVG1GRxnAg9JeKz'
    }
});

async function sendEmail(email, subject, body) {
    console.log('Email:', email);
    console.log('Subject:', subject);
    console.log('Body:', body);
    
    try {
        const info = await transporter.sendMail({
            from: '"Data Sculptor" <dock.medhurst@ethereal.email>',
            to: email,
            subject: subject,
            text: body
        });
        console.log('Message sent:', info.messageId);
    } catch (error) {
        console.error('Error sending email:', error);
    }
}

function response(statusCode, message) {
    return {
        statusCode: statusCode,
        body: JSON.stringify(message)
    };
}

module.exports.handler = async (event) => {

    console.log('Event:', event)
    
    if (!event['Records']) {
        return response(400, 'Invalid request');
    }

    for (let record of event['Records']) {
        let body = JSON.parse(record['body']);
        if (!body.recipient || !body.subject || !body.message) {
            return response(400, 'Invalid request');
        }
        await sendEmail(body.recipient, body.subject, body.message);
        return response(200, 'Email sent');
    }
};