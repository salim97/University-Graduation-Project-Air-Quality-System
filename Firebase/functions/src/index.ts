// to compile ts file into js file
// npm run build 
// install dependency
// npm install --save express body-parser firebase-functions-helper
// npm install express body-parser jsonschema
// deploy to firebase
// firebase deploy --only functions
// npm install cors
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
// https://github.com/dalenguyen/firebase-functions-helper/blob/master/docs/firestore.md
import * as firebaseHelper from 'firebase-functions-helper/dist';

// const cors = require('cors')({origin: true});

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
                        "sensor": "DHT22",
                        "name": "Temperature",
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
                        "title": "error in sensors schema format",
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
                            "sensor",
                            "name",
                            "value",
                            // "metric",
                            "isCalibrated"
                        ],
                        "additionalProperties": true,
                        "properties": {
                            "sensor": {
                                "$id": "#/properties/Sensors/items/anyOf/0/properties/sensor",
                                "type": "string",
                                "title": "The sensor schema",
                                "description": "An explanation about the purpose of this instance.",
                                "default": "",
                                "examples": [
                                    "DHT22"
                                ]
                            },
                            "name": {
                                "$id": "#/properties/Sensors/items/anyOf/0/properties/name",
                                "type": "string",
                                "title": "The name schema",
                                "description": "An explanation about the purpose of this instance.",
                                "default": "",
                                "examples": [
                                    "Temperature"
                                ]
                            },
                            "value": {
                                "$id": "#/properties/Sensors/items/anyOf/0/properties/value",
                                "type": ["number", "string"],
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
const wirteLimiteRate = (10 * 60) * 1000; // in ms
const enableWirteLimiteRate = false;

export const accountCreate = functions.auth.user().onCreate(async (user) => {
    console.log(user.toJSON());
    if (user.phoneNumber == null) {
        console.log("User Phone Number is empty!");
        return;
    }
    const date = new Date();
    var timestamp = date.getTime();
    timestamp = timestamp - wirteLimiteRate;
    var data = JSON.parse(JSON.stringify(user));
    data["lastRecordTimeStamp"] = timestamp;
    await firebaseHelper.firestore
        .createDocumentWithID(db, usersCollection, user.uid, data).then(doc => console.log(doc));
});

export const addRecord = functions.https.onRequest(async (req, res) => {
    // 1) check if request is POST
    // 2) check if request body is json
    // 3) check if request body json is valid
    // 5) check if request body uid (user id) existe in user collection
    // 6) check delay between current date and last time user write data, if delay between allowed or not


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
        const _uid = req.body["uid"];
        // let dateTime = new Date().toLocaleString();
        const date = new Date();
        const timestamp = date.getTime();
        // console.log(timestamp);
        req.body["timestamp"] = timestamp;
        if (req.body["Sensors"].length == 0) res.status(400).send("Sensors array is empty ");
        var userExists = false;
        var user_lastRecordTimeStamp = 0;
        await firebaseHelper.firestore
            .checkDocumentExists(db, usersCollection, _uid)
            .then(result => {
                // Boolean value of the result 
                console.log("checkDocumentExists " + usersCollection + " / " + _uid); // will return true or false
                console.log(result.exists); // will return true or false
                userExists = result.exists;
                if (userExists) {
                    user_lastRecordTimeStamp = result.data["lastRecordTimeStamp"];
                }
                // If the document exist, you can get the document content 
                // console.log(JSON.stringify(result.data)); // return an object of or document
            });
        if (!userExists) {
            res.status(400).send("User with uid = " + _uid + " doesn't exists ");
            return;
        }
        if (enableWirteLimiteRate)
            if (user_lastRecordTimeStamp + wirteLimiteRate > timestamp) {
                var replyMSG = "you can't write data to DB until ";
                replyMSG += new Date(user_lastRecordTimeStamp + wirteLimiteRate).toUTCString();

                var delayBetween = user_lastRecordTimeStamp + wirteLimiteRate - timestamp;
                var date2 = new Date(delayBetween);
                // Hours part from the timestamp
                var hours = date2.getHours();
                // Minutes part from the timestamp
                var minutes = "0" + date2.getMinutes();
                // Seconds part from the timestamp
                var seconds = "0" + date2.getSeconds();
                // Will display time in 10:30:23 format
                var formattedTime = hours + ':' + minutes.substr(-2) + ':' + seconds.substr(-2);
                replyMSG += " ( you need to wait " + formattedTime + " to be able to write ) "

                res.status(400).send(replyMSG);
                return;
            }


        // await firebaseHelper.firestore
        // .getDocument(db, usersCollection, _uid)
        // .then(doc => console.log(doc));



        //update user last time data was inserted
        await firebaseHelper.firestore
            .updateDocument(db, usersCollection, _uid, { "lastRecordTimeStamp": timestamp });
        // write data
        await firebaseHelper.firestore
            .createNewDocument(db, recordsCollection, req.body).then(doc => console.log(doc));

        res.status(201).send("data inserted at " + date.toUTCString());
    } catch (error) {
        res.status(400).send(`Error inserting data`)
    }
});

export const getLast10minRecords = functions.https.onRequest(async (req, res) => {

    if (req.method != "GET") {
        res.status(401).send("Accept GET Request only");
        return;
    }

    const date = new Date();
    const timestamp = date.getTime();

    // Search for data ( <, <=, ==, >, or >= )
    const queryArray = [['timestamp', '>', timestamp - wirteLimiteRate]];
    const orderBy = ['timestamp', 'desc'];

    await firebaseHelper.firestore
        .queryData(db, recordsCollection, queryArray, orderBy)
        .then(docs => {
            res.status(201).set('Access-Control-Allow-Origin', '*').send(docs);;
        });



});

export const currentTimeStamp = functions.https.onRequest(async (req, res) => {
    const date = new Date();
    const timestamp = date.getTime();
    // console.log(timestamp);
    res.status(201).send({ "timestamp": timestamp });
});



