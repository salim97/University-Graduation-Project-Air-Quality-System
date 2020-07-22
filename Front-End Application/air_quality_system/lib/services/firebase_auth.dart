import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

import 'package:injectable/injectable.dart';

/// The service responsible for networking requests
// @lazySingleton
class MyFirebaseAuthService {
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

  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _verificationId;
  int _forceResendingToken;
  // Example code of how to verify phone number
  Future verifyPhoneNumber(
      {@required String phoneNumber,
      @required VoidCallback onVerificationCompleted,
      @required Function(AuthException authException) onVerificationFailed,
      @required VoidCallback onCodeSent,
      @required VoidCallback onCodeAutoRetrievalTimeout}) async {
    final PhoneVerificationCompleted verificationCompleted = (AuthCredential phoneAuthCredential) {
      _auth.signInWithCredential(phoneAuthCredential);
      onVerificationCompleted();
    };

    final PhoneVerificationFailed verificationFailed = (AuthException authException) {
      onVerificationFailed(authException);
    };

    final PhoneCodeSent codeSent = (String verificationId, [int forceResendingToken]) async {
      _verificationId = verificationId;
      _forceResendingToken = forceResendingToken;
      onCodeSent();
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout = (String verificationId) {
      _verificationId = verificationId;
      onCodeAutoRetrievalTimeout();
    };

    await _auth
        .verifyPhoneNumber(
            phoneNumber: phoneNumber,
            timeout: const Duration(seconds: 5),
            verificationCompleted: verificationCompleted,
            verificationFailed: verificationFailed,
            codeSent: codeSent,
            codeAutoRetrievalTimeout: codeAutoRetrievalTimeout)
        .catchError((error) {
      print(error.toString());
      Future.error(error);
    });
  }

  // Example code of how to sign in with phone.
  Future<bool> signInWithPhoneNumber({smsCode}) async {
    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: _verificationId,
      smsCode: smsCode.text,
    );
    try {
      final FirebaseUser user = (await _auth.signInWithCredential(credential)).user;
      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.uid == currentUser.uid);
      // String message = '';
      if (user != null) {
        return true;
        // message = 'Successfully signed in, uid: ' + user.uid;
      } else {
        return false;
        // message = 'Sign in failed';
      }
    } on PlatformException catch (exception) {
      print(exception);
      return Future.error(exception);
    }
  }

  // Future<void> resendSMScode()
  // {
  //   // _forceResendingToken
  //   _auth.verifyPhoneNumber(
  //     forceResendingToken: _forceResendingToken, codeSent: (a, [forceResendingToken]) {
  //       forceResendingToken = b;
  //     });
  // }

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
