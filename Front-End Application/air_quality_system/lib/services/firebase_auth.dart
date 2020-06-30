import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

import 'package:injectable/injectable.dart';

/// The service responsible for networking requests
// @lazySingleton
class MyFirebaseAuth {
  FirebaseUser _firebaseUser = null;
  get firebaseUser => _firebaseUser;
  set firebaseUser(FirebaseUser value) {
    _firebaseUser = value;
  }

  bool _isUserConnectedToFirebase = false;
  get isUserConnectedToFirebase => (_firebaseUser != null);
  set isUserConnectedToFirebase(bool value) {
    _isUserConnectedToFirebase = value;
    // notifyListeners();
  }

  Future signIn() async {
    // GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    // GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
    // AuthCredential credential = GoogleAuthProvider.getCredential(
    //     accessToken: googleSignInAuthentication.accessToken, idToken: googleSignInAuthentication.idToken);
    // AuthResult authResult = await firebaseAuth.signInWithCredential(credential);

    // firebaseUser = authResult.user;

    // notifyListeners();
  }

  Future signInAnonymously() async {
    print("=================== signInAnonymously ");
await FirebaseAuth.instance.signOut();
    try {
      AuthResult authResult = await FirebaseAuth.instance.signInAnonymously();
      firebaseUser = authResult.user;
      print(firebaseUser.toString());
    } catch (e) {
      print("=================== catch (e) { ");
      print(e); // TODO: show dialog with error
    }
    // notifyListeners();
  }
}
