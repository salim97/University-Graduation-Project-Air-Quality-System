// npm install --save firebase-admin 
// npm install firestore-export-import

'use strict';
const fs = require('fs');
const path = require('path');
const admin = require('firebase-admin');
// you need firebase admin sdk to be able to connecte into firestore DB
// https://console.firebase.google.com/u/0/project/pfe-air-quality/settings/serviceaccounts/adminsdk
const serviceAcount = require('./pfe-air-quality-firebase-adminsdk-6mmp3-893c99e074.json'); //

const { exit } = require('process');
admin.initializeApp({
    credential: admin.credential.cert(serviceAcount)
});

const db = admin.firestore();
const firestoreService = require('firestore-export-import');
// JSON To Firestore
const jsonToFirestore = async (fileName) => {
    try {
        console.log('Initialzing Firebase');
        await firestoreService.initializeApp(admin.credential.cert(serviceAcount),"https://pfe-air-quality.firebaseio.com");
        console.log('Firebase Initialized');

        await firestoreService.restore(fileName);
        console.log('Upload Success');
    }
    catch (error) {
        console.log(error);
    }
};


// importFirestoreDBtoLocalJSONfile('old_db2.json');
 readLocalJSONfile('old_db.json');
// exportLocalJSONfileToFirestore('new_db.json');
// jsonToFirestore("new_db.json");




function exportLocalJSONfileToFirestore(fileName) {
    fs.readFile(fileName, 'utf8', (err, jsonString) => {
        if (err) {
            console.log("File read failed:", err)
            return
        }
        var json = JSON.parse(jsonString);
        var record_count = 0;
        let batch = db.batch();
        let count = 0;
        // json.length
        // for (var key in json) {
        //     record_count++;
        //     batch.set(collection.doc(Math.random().toString(36).substring(2, 15)), datas.shift());
        //     if (++record_count >= 500 || !datas.length) {
        //         await batch.commit();
        //         batch = admin.firestore().batch();
        //         record_count = 0;
        //     }
        // }
        for (var key in json) {
            record_count++;
            // if( record_count > 5 ) break ;
            // sample++;
            // if (sample > 500) break;
            var attrName = key;
            var attrValue = json[key];
            batch.set(db.doc(attrName), attrValue).then((res) => {
                console.log("Document " + attrName + " successfully written!");
            }).catch((error) => {
                console.error("Error writing document: ", error);
            });
            // db.collection("Records").doc(attrName).set(attrValue).then((res) => {
            //     console.log("Document " + attrName + " successfully written!");
            // }).catch((error) => {
            //     console.error("Error writing document: ", error);
            // });

        }
        batch.commit();
        //  batch = admin.firestore().batch();



    });
}



function readLocalJSONfile(fileName) {
    // fs.writeFileSync(fileName, JSON.stringify(all_data,null,2));
    fs.readFile(fileName, 'utf8', (err, jsonString) => {
        if (err) {
            console.log("File read failed:", err)
            return
        }
        // console.log('File data:', jsonString) 
        var oldJSON = JSON.parse(jsonString);
        var newJSON = {};
        // var sample = 0;
        var record_count = 0;
        var record_error = 0;
        var record_deleted = 0;
        var record_salim = 0;
        var record_teen = 0;

        for (var key in oldJSON) {
            record_count++;
          
            // sample++;
            // if (sample > 500) break;
            var attrName = key;
            var attrValue = oldJSON[key];
            // console.log(attrName) ;
            // console.log(attrValue["GPS"]) ;
            try {
                newJSON[attrName] = {
                    "timestamp": attrValue["timestamp"],
                    "GPS": {
                        "latitude": attrValue["GPS"]["latitude"]["value"],
                        "longitude": attrValue["GPS"]["longitude"]["value"]
                    },
                    "Sensors": []
                }

                if (attrValue.hasOwnProperty('DHT11')) {
                    record_teen++;
                    newJSON[attrName]["uid"] = "L7tf0KusN9g2buXf21rQ46qmDRB3";
                    myObjToArray(attrValue, newJSON[attrName]["Sensors"], "DHT11");

                }
                if (attrValue.hasOwnProperty('DHT22')) {
                    record_salim++;
                    newJSON[attrName]["uid"] = "Lf7gh5IDYxZgOmUXKhtaHSk6j9y2";
                    myObjToArray(attrValue, newJSON[attrName]["Sensors"], "SGP30");
                    myObjToArray(attrValue, newJSON[attrName]["Sensors"], "MHZ19");
                    myObjToArray(attrValue, newJSON[attrName]["Sensors"], "MICS6814");
                    myObjToArray(attrValue, newJSON[attrName]["Sensors"], "BME680");
                    myObjToArray(attrValue, newJSON[attrName]["Sensors"], "DHT22");
                }

                if (newJSON[attrName]["Sensors"].length == 0) {
                    delete newJSON[attrName];
                    record_deleted++;
                }
                
            }
            catch (e) {
                // console.log("entering catch block");
                console.log("error with record id = " + attrName);
                record_error++;
                // console.log("leaving catch block");
            }

            // console.log(attrName) ;
            // console.log(attrValue) ;
        }
        console.log("record_count = ", record_count);
        console.log("record_error = ", record_error);
        console.log("record_deleted = ", record_deleted);
        console.log("record_salim = ", record_salim);
        console.log("record_teen = ", record_teen);
        return ;
        // console.log(JSON.stringify(newJSON, null, 4));
        var recordsJSON = {
            "Records" : []
        };
        for (var key in newJSON) {
            record_count++;
            // sample++;
            // if (sample > 500) break;
            var attrName = key;
            var attrValue = newJSON[key];
            recordsJSON["Records"].push(attrValue);
        }
        recordsJSON["Records"].push(newJSON[attrName]);
        fs.writeFileSync("new_db.json", JSON.stringify(recordsJSON, null, 2));
    })
}



function myObjToArray(obj, array, sensorName) {
    if (sensorName == "DHT11" || sensorName == "DHT22") {
        array.push({
            "sensor": sensorName,
            "name": "Humidity",
            "value": obj[sensorName]["Humidity"]["value"],
            "metric": obj[sensorName]["Humidity"]["type"],
            "isCalibrated": obj[sensorName]["Humidity"]["isCalibrated"],
        });
        array.push({
            "sensor": sensorName,
            "name": "Temperature",
            "value": obj[sensorName]["Temperature"]["value"],
            "metric": obj[sensorName]["Temperature"]["type"],
            "isCalibrated": obj[sensorName]["Temperature"]["isCalibrated"],
        });
    }
    if (sensorName == "MICS6814") {
        array.push({
            "sensor": sensorName,
            "name": "NO2",
            "value": obj[sensorName]["NO2"]["value"],
            "metric": obj[sensorName]["NO2"]["type"],
            "isCalibrated": obj[sensorName]["NO2"]["isCalibrated"],
        });
        array.push({
            "sensor": sensorName,
            "name": "Temperature",
            "value": obj[sensorName]["CO"]["value"],
            "metric": obj[sensorName]["CO"]["type"],
            "isCalibrated": obj[sensorName]["CO"]["isCalibrated"],
        });
        array.push({
            "sensor": sensorName,
            "name": "Temperature",
            "value": obj[sensorName]["NH3"]["value"],
            "metric": obj[sensorName]["NH3"]["type"],
            "isCalibrated": obj[sensorName]["NH3"]["isCalibrated"],
        });
    }
    if (sensorName == "MHZ19") {
        array.push({
            "sensor": sensorName,
            "name": "Temperature",
            "value": obj[sensorName]["Temperature"]["value"],
            "metric": obj[sensorName]["Temperature"]["type"],
            "isCalibrated": obj[sensorName]["Temperature"]["isCalibrated"],
        });
        array.push({
            "sensor": sensorName,
            "name": "CO2",
            "value": obj[sensorName]["Unlimited CO2"]["value"],
            "metric": obj[sensorName]["Unlimited CO2"]["type"],
            "isCalibrated": obj[sensorName]["Unlimited CO2"]["isCalibrated"],
        });
        array.push({
            "sensor": sensorName,
            "name": "Raw CO2",
            "value": obj[sensorName]["Raw CO2"]["value"],
            "isCalibrated": false,
        });
    }
    if (sensorName == "SGP30") {
        array.push({
            "sensor": sensorName,
            "name": "eCO2",
            "value": obj[sensorName]["eCO2"]["value"],
            "metric": obj[sensorName]["eCO2"]["type"],
            "isCalibrated": obj[sensorName]["eCO2"]["isCalibrated"],
        });
        array.push({
            "sensor": sensorName,
            "name": "TVOC",
            "value": obj[sensorName]["TVOC"]["value"],
            "metric": obj[sensorName]["TVOC"]["type"],
            "isCalibrated": obj[sensorName]["TVOC"]["isCalibrated"],
        });
        array.push({
            "sensor": sensorName,
            "name": "Raw Ethanol",
            "value": obj[sensorName]["Raw Ethanol"]["value"],
            "isCalibrated": false,
        });
        array.push({
            "sensor": sensorName,
            "name": "Raw H2",
            "value": obj[sensorName]["Raw H2"]["value"],
            "isCalibrated": false,
        });
    }
    if (sensorName == "BME680") {
        array.push({
            "sensor": sensorName,
            "name": "Humidity",
            "value": obj[sensorName]["Humidity"]["value"],
            "metric": obj[sensorName]["Humidity"]["type"],
            "isCalibrated": obj[sensorName]["Humidity"]["isCalibrated"],
        });
        array.push({
            "sensor": sensorName,
            "name": "Pressure",
            "value": obj[sensorName]["Pressure"]["value"],
            "metric": obj[sensorName]["Pressure"]["type"],
            "isCalibrated": obj[sensorName]["Pressure"]["isCalibrated"],
        });
        array.push({
            "sensor": sensorName,
            "name": "Temperature",
            "value": obj[sensorName]["Temperature"]["value"],
            "metric": obj[sensorName]["Temperature"]["type"],
            "isCalibrated": obj[sensorName]["Temperature"]["isCalibrated"],
        });

    }
}

function importFirestoreDBtoLocalJSONfile(fileName) {
    db.collection("Records").orderBy("timestamp", "desc")
        .get()
        .then(function (querySnapshot) {

            var all_data = {};
            querySnapshot.forEach(function (doc) {
                all_data[doc.id] = doc.data();

            });
            console.log(all_data);
            console.log("all_data");
            fs.writeFileSync(fileName, JSON.stringify(all_data, null, 2));
            exit();
        })
        .catch(function (error) {
            console.log("Error getting documents: ", error);
        });
}


/*


const directoryPath = path.join('records');
//passsing directoryPath and callback function
fs.readdir(directoryPath, function (err, files) {
    //handling error
    if (err) {
        return console.log('Unable to scan directory: ' + err);
    }
    //listing all files using forEach
    files.forEach(function (file) {
        // Do whatever you want to do with the file
        let tmp = JSON.parse(file);
        console.log(tmp);
    });
});




fs.readFile('student.json', (err, data) => {
    if (err) throw err;
    let student = JSON.parse(data);
    console.log(student);
});

console.log('This is after the read call');

*/