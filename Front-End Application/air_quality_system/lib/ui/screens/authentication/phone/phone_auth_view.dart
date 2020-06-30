import 'package:air_quality_system/app/router.gr.dart';
import 'package:air_quality_system/ui/widgets/custom_text_form_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';



import 'phone_otp_view.dart';

class PhoneAuthView extends StatelessWidget {
  final phoneNumberController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        backgroundColor: _theme.scaffoldBackgroundColor,
        automaticallyImplyLeading: false,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        actions: <Widget>[
          GestureDetector(
            onTap: () {
              // Navigator.of(context).pushReplacementNamed(PhoneRegisterRoute);
              Navigator.of(context).pushReplacementNamed(Routes.phoneAuthView);
            },
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 25.0),
              child: Text(
                "Sign Up",
                style: TextStyle(
                  color: _theme.primaryColor,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.only(left: 15.0, right: 15.0, bottom: 15.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Text(
                      "What is your phone number?",
                      style: _theme.textTheme.title.merge(
                        TextStyle(fontSize: 30.0),
                      ),
                    ),
                  ),
                  Text(
                    "Tap \"Get Started\" to get an SMS confirmation to help you use TOGYAN FOOD. We would like to get your phone number.\nSupported phone numbers :\n05XX XX XX XX \n06XX XX XX XX \n07XX XX XX XX  ",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Expanded(
                    child: CustomTextFormField(
                      hintText: "Country Code",
                      controller: phoneNumberController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                    ),
                  )
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 45.0,
              child: FlatButton(
                color: _theme.primaryColor,
                child: Text(
                  "GET STARTED",
                  style: _theme.textTheme.body1.merge(
                    TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                onPressed: () async {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PhoneOTPView(
                                countryCode: "+213",
                                // phoneNumber: "666795827",
                                phoneNumber: "662253959",
                                onVerificationFailure: () {
                                  print("khra");
                                },
                                onVerificationSuccess: () {
                                  Navigator.of(context).pop();
                                  print("nice");
                                },
                              )));
                  return;
                  print(phoneNumberController.text);
                  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
                  final PhoneVerificationCompleted verificationCompleted =
                      (AuthCredential phoneAuthCredential) {
                    _firebaseAuth
                        .signInWithCredential(phoneAuthCredential)
                        .then((AuthResult value) {
                      if (value.user != null) {
                        // Handle loogged in state
                        print(value.user.phoneNumber);
                        // NAVIGATE TO HOME PAGE
                      } else {
                        showToast(
                            "Error validating OTP, try again", Colors.red);
                      }
                    }).catchError((error) {
                      showToast("Try again in sometime", Colors.red);
                    });
                  };
                  final PhoneVerificationFailed verificationFailed =
                      (AuthException authException) {
                    showToast(authException.message, Colors.red);
                    // setState(() {
                    //   isCodeSent = false;
                    // });
                  };

                  final PhoneCodeSent codeSent =
                      (String verificationId, [int forceResendingToken]) async {
                    // setState(() {
                    //   _verificationId = verificationId;
                    // });
                  };
                  final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
                      (String verificationId) {
                    // setState(() {
                    //   _verificationId = verificationId;
                    // });
                  };

                  // TODO: Change country code

                  await _firebaseAuth.verifyPhoneNumber(
                      phoneNumber: "+213${phoneNumberController.text}",
                      timeout: const Duration(seconds: 60),
                      verificationCompleted: verificationCompleted,
                      verificationFailed: verificationFailed,
                      codeSent: codeSent,
                      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  void showToast(message, Color color) {
    print(message);
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 2,
        backgroundColor: color,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}
