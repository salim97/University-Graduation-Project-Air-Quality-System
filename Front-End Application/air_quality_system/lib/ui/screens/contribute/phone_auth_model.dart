import 'package:air_quality_system/services/firebase_auth.dart';
import 'package:stacked/stacked.dart';
import 'package:air_quality_system/app/locator.dart';
import 'package:air_quality_system/ui/widgets/authentication/codeinput.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stacked_services/stacked_services.dart';

enum OTP_Status { sending_sms, sms_was_send, success, failed }

class PhoneAuthViewModel extends BaseViewModel {
  bool getPhoneNumberPage = false  ;
  final DialogService _dialogService = locator<DialogService>();
  final NavigationService _navigationService = locator<NavigationService>();
  final MyFirebaseAuthService _myFirebaseAuthService = locator<MyFirebaseAuthService>();

  OTP_Status _otpStatus = OTP_Status.sending_sms;
  OTP_Status get otpStatus => _otpStatus;
  set otpStatus(OTP_Status otpStatus) {
    _otpStatus = otpStatus;
    print(_otpStatus.toString());
    notifyListeners();
  }

  TextEditingController controller;
  void initState() async {
    // controller = TextEditingController();
    // controller.text = "";
    // verifyPhone();
    // notifyListeners();
  }
  String countryCode = "+213";
  String phoneNumber = "662253959";
  VoidCallback onVerificationSuccess;
  VoidCallback onVerificationFailure;

  String verificationId;
  String smsCode;

  Future<void> verifyPhone() async {
    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) async {
      this.verificationId = verId;
      otpStatus = OTP_Status.failed;
      await _dialogService.showDialog(
        title: "Time out",
        description: "Try again",
        dialogPlatform: DialogPlatform.Material,
      );
      _navigationService.popRepeated(1);
    };

    final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeSent]) {
      verificationId = verId;
      otpStatus = OTP_Status.sms_was_send;
      // openKeyboard();
      print("\nEnter the code sent to " + phoneNumber);
    };

    final PhoneVerificationCompleted verifiedSuccess = (AuthCredential auth) async {
      print("--------------------------------------------------------------");
      print(auth.toString());
return ;
      try {
        final FirebaseUser user = (await FirebaseAuth.instance.signInWithCredential(auth)).user;
        final FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
        assert(user.uid == currentUser.uid);
        // String message = '';
        if (user != null) {
          
          otpStatus = OTP_Status.success;
          controller.text = "******";
          notifyListeners();
          onVerificationSuccess();
        }
      } on PlatformException catch (exception) {
        print(exception);
        await _dialogService.showDialog(
          title: exception.code,
          description: exception.message,
          dialogPlatform: DialogPlatform.Material,
        );
        _navigationService.popRepeated(1);

      }

      //TODO: send auth to firebaseu auth service to be global
    };

    final PhoneVerificationFailed verfiFailed = (AuthException exception) async {
      print("--------------------------");
      print("Failed ${exception.message}");
      String description;
      // _addStatusMessage('${authException.message}');
      // _addStatus(PhoneAuthState.);
      // if (onFailed != null) onFailed();
      if (exception.message.contains('not authorized'))
        description = 'App not authorized';
      else if (exception.message.contains('network'))
        description = 'Please check your internet connection and try again';
      else
        description = exception.message;
      // description='Something has gone wrong, please try later ' ;
      // ;
      await _dialogService.showDialog(
        title: "Phone Auth Failed",
        description: description,
        dialogPlatform: DialogPlatform.Material,
      );
      _navigationService.popRepeated(1);
    };

    await FirebaseAuth.instance
        .verifyPhoneNumber(
            phoneNumber: countryCode + phoneNumber,
            timeout: const Duration(seconds: 15),
            codeAutoRetrievalTimeout: autoRetrieve,
            codeSent: smsCodeSent,
            verificationCompleted: verifiedSuccess,
            verificationFailed: verfiFailed)
        .catchError((error) {
      // if (onError != null) onError();
      // _addStatus(PhoneAuthState.Error);
      print(error.toString());
    });
    otpStatus = OTP_Status.sending_sms;
  }

  manualVerification(_smsCode) async {
    AuthCredential _authCredential = PhoneAuthProvider.getCredential(verificationId: verificationId, smsCode: _smsCode);
    try {
      AuthResult user = await FirebaseAuth.instance.signInWithCredential(_authCredential);
      print("Verification Successful");
      print(user.toString());
      otpStatus = OTP_Status.sending_sms;
      onVerificationSuccess();
    } on PlatformException catch (exception) {
      print(exception);
      // if(exception.code = "ERROR_INVALID_VERIFICATION_CODE")

      await _dialogService.showDialog(
        title: exception.code,
        description: exception.message,
        dialogPlatform: DialogPlatform.Material,
      );
      controller.text = "";
      // closeKeyboard();
      // openKeyboard();
    }
  }

  resendSMS() async {
    await _dialogService.showDialog(
      title: "Not Implemented yet",
      description: "Ncha'allah brabi :)",
      dialogPlatform: DialogPlatform.Material,
    );
    _navigationService.popRepeated(1);
  }
}
