import 'package:firebase/firebase_io.dart';

void main() {
  var credential = ... // Retrieve auth credential
  var fbClient = new FirebaseClient(credential); // FirebaseClient.anonymous() is also available
  
  var path = ... // Full path to your database location with .json appended
  
  // GET
  var response = await fbClient.get(path);
  
  // DELETE
  // await fbClient.delete(path);
  
  // ...
}

void main() {


  var firebaseConfig = {
    apiKey: "AIzaSyBnq90W3alvvy6imupfZopaFpBjHWSytWo",
    authDomain: "pfe-air-quality.firebaseapp.com",
    databaseURL: "https://pfe-air-quality.firebaseio.com",
    projectId: "pfe-air-quality",
    storageBucket: "pfe-air-quality.appspot.com",
    messagingSenderId: "356995025213",
    appId: "1:356995025213:web:488ac6643dc43f6d805d54",
    measurementId: "G-WE58PYNWQY"
  };

  fs.Firestore store = firestore();
  fs.CollectionReference ref = store.collection('Users');

  ref.onSnapshot.listen((querySnapshot) {
    querySnapshot.docChanges().forEach((change) {
      if (change.type == "added") {
        // Do something with change.doc
      }
    });
  });
}
