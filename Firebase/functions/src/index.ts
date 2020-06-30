// to compile ts file into js file
// npm run build 
// npm install --save express body-parser firebase-functions-helper
// firebase deploy --only functions
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as firebaseHelper from 'firebase-functions-helper/dist';
import * as express from 'express';
import * as bodyParser from "body-parser";

admin.initializeApp(functions.config().firebase);
const db = admin.firestore();

const app = express();
const main = express();

main.use(bodyParser.json());
main.use(bodyParser.urlencoded({ extended: false }));
main.use('/api/v1', app);

const contactsCollection = 'contacts';
export const webApi = functions.https.onRequest(main);

// interface Contact {
//     firstName: String
//     lastName: String
//     email: String
// }
// exports.sendWelcomeEmail = functions.auth.user().onCreate((user) => {
//     const email = user.email; // The email of the user.
//     const displayName = user.displayName; // The display name of the user.
//     const phone = user.phoneNumber; // The email of the user.

//     console.log(email);
//     console.log(displayName);
//     console.log(phone);
//     console.log(user.toJSON());
//     // const newDoc = await firebaseHelper.firestore
//      firebaseHelper.firestore
//             .createNewDocument(db, usersCollection, user.toJSON()).then(doc => console.log(doc));
// });

export const accountCreate = functions.auth.user().onCreate(async (user) => {
    console.log(user.toJSON());
    if (user.phoneNumber == null) {
        console.log("User Phone Number is empty!");
        return;
    }
    
    await firebaseHelper.firestore
        .createDocumentWithID(db, "Users", user.uid, JSON.parse(JSON.stringify(user))).then(doc => console.log(doc));
});

// // exports.sendCouponOnPurchase = functions.analytics.event('login').onLog((event) => {
// export const loginEvent = functions.analytics.event('login').onLog((event) => {
//     // const user = event.user;
//     // const uid = user?.userId; // The user ID set via the setUserId API.
//     console.log(event) ;

//   });

app.post('/postData', async (req, res) => {
    try {
        console.log(req.body);

        // let dateTime = new Date().toLocaleString();
        var date = new Date();
        var timestamp = date.getTime();
        // console.log(timestamp);
        req.body["timestamp"] = timestamp;

        // const newDoc = await firebaseHelper.firestore
        await firebaseHelper.firestore
            .createNewDocument(db, contactsCollection, req.body).then(doc => console.log(doc));
        res.status(201).send(`data inserted ${req.body["timestamp"]}`);
    } catch (error) {
        res.status(400).send(`Error inserting data`)
    }
})

/* // Add new contact
app.post('/contacts', async (req, res) => {
    try {
        const contact: Contact = {
            firstName: req.body['firstName'],
            lastName: req.body['lastName'],
            email: req.body['email']
        }

        const newDoc = await firebaseHelper.firestore
            .createNewDocument(db, contactsCollection, contact).then(doc => console.log(doc));
        res.status(201).send(`Created a new contact: ${newDoc}`);
    } catch (error) {
        res.status(400).send(`Contact should only contains firstName, lastName and email!!!`)
    }        
})

// Update new contact
app.patch('/contacts/:contactId', async (req, res) => {
    const updatedDoc = await firebaseHelper.firestore
        .updateDocument(db, contactsCollection, req.params.contactId, req.body);
    res.status(204).send(`Update a new contact: ${updatedDoc}`);
})

// View a contact
app.get('/contacts/:contactId', (req, res) => {
    firebaseHelper.firestore
        .getDocument(db, contactsCollection, req.params.contactId)
        .then(doc => res.status(200).send(doc))
        .catch(error => res.status(400).send(`Cannot get contact: ${error}`));
})

// View all contacts
app.get('/contacts', (req, res) => {
    firebaseHelper.firestore
        .backup(db, contactsCollection)
        .then(data => res.status(200).send(data))
        .catch(error => res.status(400).send(`Cannot get contacts: ${error}`));
firebaseHelper.firebase
    .getAllUsers()    
    .then(users => console.log(users));
    // res.send("Hello from Firebase!");
})

// Delete a contact 
app.delete('/contacts/:contactId', async (req, res) => {
    const deletedContact = await firebaseHelper.firestore
        .deleteDocument(db, contactsCollection, req.params.contactId);
    res.status(204).send(`Contact is deleted: ${deletedContact}`);
}) */

export { app };
// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//
// export const helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });
