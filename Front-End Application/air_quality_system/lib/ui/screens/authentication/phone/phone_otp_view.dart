library phone_auth_simple;

import 'package:air_quality_system/app/locator.dart';
import 'package:air_quality_system/ui/widgets/authentication/codeinput.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'phone_otp_model.dart';

class PhoneOTPView extends StatefulWidget {
  final String countryCode;
  final String phoneNumber;
  final VoidCallback onVerificationSuccess;
  final VoidCallback onVerificationFailure;
  Color progressIndicatorColor = Colors.red;
  Widget appBar = AppBar(
    title: Text("Enter OTP"),
    backgroundColor: Colors.red,
  );

  PhoneOTPView(
      {@required this.countryCode,
      @required this.phoneNumber,
      @required this.onVerificationSuccess,
      @required this.onVerificationFailure,
      this.appBar,
      this.progressIndicatorColor});

  @override
  _PhoneOTPViewState createState() => _PhoneOTPViewState();
}

class _PhoneOTPViewState extends State<PhoneOTPView> {
  FocusNode myFocusNode;

  @override
  void initState() {
    super.initState();
    myFocusNode = FocusNode();
    Future.delayed(Duration(seconds: 2), () {
      openKeyboard();
    });
  }

  openKeyboard() {
    if(context == null) return ;
    final focusScope = FocusScope.of(context);
    focusScope.requestFocus(FocusNode());
    Future.delayed(
      Duration.zero,
      () => focusScope.requestFocus(myFocusNode),
    );
  }

  closeKeyboard() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PhoneOTPViewModel>.reactive(
      builder: (context, model, child) => Scaffold(
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 96.0),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      "Verifying your number!",
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 4.0, right: 16.0),
                    child: Text(
                      "Please type the verification code sent to",
                      style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.normal),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 30.0, top: 2.0, right: 30.0),
                    child: Text(
                      "${widget.countryCode} ${widget.phoneNumber}",
                      style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold, color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Image(
                      image: AssetImage('assets/images/otp-icon.png'),
                      height: 120.0,
                      width: 120.0,
                    ),
                  ),
                  Padding(padding: const EdgeInsets.only(top: 5.0, bottom: 15.0), child: codeStatus(model)),
                  Container(
                    padding: EdgeInsets.only(bottom: 10.0),
                    child: CodeInput(
                      length: 6,
                      keyboardType: TextInputType.number,
                      controller: model.controller,
                      builder: CodeInputBuilders.darkCircle(),
                      focusNode: myFocusNode,
                      onFilled: (value) async {
                        print('Your input is $value.');
                        closeKeyboard();
                        model.manualVerification(value);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      "Didn't you received any code?",
                    ),
                  ),
                  GestureDetector(
                    onTap: model.resendSMS,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        "Resend new code",
                        style: TextStyle(
                          fontSize: 19,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      viewModelBuilder: () => PhoneOTPViewModel(
        countryCode: widget.countryCode,
        phoneNumber: widget.phoneNumber,
        onVerificationSuccess: widget.onVerificationSuccess,
        onVerificationFailure: widget.onVerificationFailure,
      ),
      onModelReady: (model) =>
          model.initState(), // TODO: khrebch fiha apre, prc initstate ta3 fluter w hadi custom je pense pas 3andhom meme behavior
    );
  }

  Widget codeStatus(model) {
    if (model.otpStatus == OTP_Status.sending_sms) {
      return Column(
        children: [
          Text(
            "Sending SMS ......",
            style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold, color: Colors.red),
            textAlign: TextAlign.center,
          ),
          CircularProgressIndicator(
              valueColor:
                  new AlwaysStoppedAnimation<Color>(widget.progressIndicatorColor == null ? Colors.red : widget.progressIndicatorColor))
        ],
      );
    }
    if (model.otpStatus == OTP_Status.sms_was_send) {
      return Text(
        "SMS code Sent",
        style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold, color: Colors.green),
        textAlign: TextAlign.center,
      );
    }
    if (model.otpStatus == OTP_Status.sms_was_send) {
      return Image(
        image: AssetImage('assets/images/success.png'),
        height: 60.0,
        width: 60.0,
      );
    }
    if (model.otpStatus == OTP_Status.failed) {
      return Image(
        image: AssetImage('assets/images/delete.png'),
        height: 60.0,
        width: 60.0,
      );
    }
    return Container();
  }
}
