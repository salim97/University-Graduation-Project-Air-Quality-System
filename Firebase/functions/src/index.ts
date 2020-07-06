// to compile ts file into js file
// npm run build 
// npm install --save express body-parser firebase-functions-helper
// npm install express body-parser jsonschema
// firebase deploy --only functions

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as firebaseHelper from 'firebase-functions-helper/dist';

var jsonValidator = require('jsonschema').Validator;
var validator = new jsonValidator();

// https://jsonschema.net/home
var recordSchema = {
    "type": "object",
    "title": "The root schema",
    "description": "The root schema comprises the entire JSON document.",
    "default": {},
    "examples": [
        {
            "uid": "789312354",
            "GPS": {
                "latitude": 5.5,
                "longitude": 10.5
            },
            "Sensors": [
                {
                    "name": "DHT22",
                    "value": "27.5",
                    "metric": "C°",
                    "isCalibrated": true
                }
            ]
        }
    ],
    "required": [
        "uid",
        "GPS",
        "Sensors"
    ],
    "additionalProperties": true,
    "properties": {
        "uid": {
            "$id": "#/properties/uid",
            "type": "string",
            "title": "The uid schema",
            "description": "An explanation about the purpose of this instance.",
            "default": "",
            "examples": [
                "789312354"
            ]
        },
        "GPS": {
            "$id": "#/properties/GPS",
            "type": "object",
            "title": "The GPS schema",
            "description": "An explanation about the purpose of this instance.",
            "default": {},
            "examples": [
                {
                    "latitude": 5.5,
                    "longitude": 10.5
                }
            ],
            "required": [
                "latitude",
                "longitude"
            ],
            "additionalProperties": true,
            "properties": {
                "latitude": {
                    "$id": "#/properties/GPS/properties/latitude",
                    "type": "number",
                    "title": "The latitude schema",
                    "description": "An explanation about the purpose of this instance.",
                    "default": 0.0,
                    "examples": [
                        5.5
                    ]
                },
                "longitude": {
                    "$id": "#/properties/GPS/properties/longitude",
                    "type": "number",
                    "title": "The longitude schema",
                    "description": "An explanation about the purpose of this instance.",
                    "default": 0.0,
                    "examples": [
                        10.5
                    ]
                }
            }
        },
        "Sensors": {
            "$id": "#/properties/Sensors",
            "type": "array",
            "title": "The Sensors schema",
            "description": "An explanation about the purpose of this instance.",
            "default": [],
            "examples": [
                [
                    {
                        "name": "DHT22",
                        "value": "27.5",
                        "metric": "C°",
                        "isCalibrated": true
                    }
                ]
            ],
            "additionalItems": true,
            "items": {
                "anyOf": [
                    {
                        "$id": "#/properties/Sensors/items/anyOf/0",
                        "type": "object",
                        "title": "The first anyOf schema",
                        "description": "An explanation about the purpose of this instance.",
                        "default": {},
                        "examples": [
                            {
                                "name": "DHT22",
                                "value": "27.5",
                                "metric": "C°",
                                "isCalibrated": true
                            }
                        ],
                        "required": [
                            "name",
                            "value",
                            // "metric",
                            "isCalibrated"
                        ],
                        "additionalProperties": true,
                        "properties": {
                            "name": {
                                "$id": "#/properties/Sensors/items/anyOf/0/properties/name",
                                "type": "string",
                                "title": "The name schema",
                                "description": "An explanation about the purpose of this instance.",
                                "default": "",
                                "examples": [
                                    "DHT22"
                                ]
                            },
                            "value": {
                                "$id": "#/properties/Sensors/items/anyOf/0/properties/value",
                                "type":  ["number", "string"],
                                "title": "The value schema",
                                "description": "An explanation about the purpose of this instance.",
                                "default": "",
                                "examples": [
                                    "27.5"
                                ]
                            },
                            "metric": {
                                "$id": "#/properties/Sensors/items/anyOf/0/properties/metric",
                                "type": "string",
                                "title": "The metric schema",
                                "description": "An explanation about the purpose of this instance.",
                                "default": "",
                                "examples": [
                                    "C°"
                                ]
                            },
                            "isCalibrated": {
                                "$id": "#/properties/Sensors/items/anyOf/0/properties/isCalibrated",
                                "type": "boolean",
                                "title": "The isCalibrated schema",
                                "description": "An explanation about the purpose of this instance.",
                                "default": false,
                                "examples": [
                                    true
                                ]
                            }
                        }
                    }
                ],
                "$id": "#/properties/Sensors/items"
            }
        }
    }
};


admin.initializeApp(functions.config().firebase);
const db = admin.firestore();


const recordsCollection = "Records";
const usersCollection = "Users";

export const accountCreate = functions.auth.user().onCreate(async (user) => {
    console.log(user.toJSON());
    if (user.phoneNumber == null) {
        console.log("User Phone Number is empty!");
        return;
    }

    await firebaseHelper.firestore
        .createDocumentWithID(db, usersCollection, user.uid, JSON.parse(JSON.stringify(user))).then(doc => console.log(doc));
});

export const addRecord = functions.https.onRequest(async (req, res) => {
    if (req.method != "POST") {
        res.status(401).send("Accept POST Request only");
        return;
    }

    if (req.get('Content-Type') != 'application/json') {
        res.status(401).send('Invalid header format, (application/json)');
        return;
    }

    try {
        validator.validate(req.body, recordSchema, {
            throwError: true
        });
    } catch (error) {
        res.status(401).end('Invalid body format: ' + error.message);
        return;
    }

    try {
        console.log(req.body);

        // let dateTime = new Date().toLocaleString();
        const date = new Date();
        const timestamp = date.getTime();
        // console.log(timestamp);
        req.body["timestamp"] = timestamp;

        // const newDoc = await firebaseHelper.firestore
        await firebaseHelper.firestore
            .createNewDocument(db, recordsCollection, req.body).then(doc => console.log(doc));
        res.status(201).send(`data inserted ${req.body["timestamp"]}`);
    } catch (error) {
        res.status(400).send(`Error inserting data`)
    }
});


export const currentTimeStamp = functions.https.onRequest(async (req, res) => {
    const date = new Date();
    const timestamp = date.getTime();
    // console.log(timestamp);
    res.status(201).send({ "timestamp": timestamp });
});


