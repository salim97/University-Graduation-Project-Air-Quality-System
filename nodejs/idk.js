'use strict';
const fs = require('fs');
const path = require('path');
const admin = require('firebase-admin');
const serviceAcount = require('./pfe-air-quality-firebase-adminsdk-6mmp3-893c99e074.json');
admin.initializeApp({


    credential: admin.credential.cert(serviceAcount)

});

const db = admin.firestore();

db.collection("contacts").orderBy("timestamp", "desc")
   .get()
    .then(function (querySnapshot) {

        
        querySnapshot.forEach(function (doc) {
            // doc.data() is never undefined for query doc snapshots
            console.log(doc.id, " => ", doc.data());

            let data = JSON.stringify(doc.data());
            fs.writeFileSync('.json', data);
            console.log("file created successfully");

        });
    })
    .catch(function (error) {
        console.log("Error getting documents: ", error);
    });

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