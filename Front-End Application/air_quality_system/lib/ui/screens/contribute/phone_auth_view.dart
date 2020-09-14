import 'package:air_quality_system/app/router.gr.dart';
import 'package:air_quality_system/ui/screens/contribute/phone_auth_model.dart';
import 'package:air_quality_system/ui/widgets/authentication/codeinput.dart';
import 'package:air_quality_system/ui/widgets/authentication/countrydropdown.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';

class PhoneAuthView extends StatefulWidget {
  @override
  _PhoneAuthViewState createState() => _PhoneAuthViewState();
}

class _PhoneAuthViewState extends State<PhoneAuthView> {
  var _txtNumber = TextEditingController();
  String _txtNumberHint = "05078596252";

  @override
  void initState() {
    super.initState();
    // _txtNumber.text = "662253959";
    // _txtNumber.addListener(() {
    //   setState(() {
    //     _txtNumberHint = _txtNumber.text;
    //     print("Text Number Value: ${_txtNumber.text}");
    //   });
    // });
    myFocusNode = FocusNode();
    // Future.delayed(Duration(seconds: 2), () {
    //   openKeyboard();
    // });
  }

  FocusNode myFocusNode;

  openKeyboard() {
    if (context == null) return;
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
    return ViewModelBuilder<PhoneAuthViewModel>.reactive(
      builder: (context, model, child) => getPhoneNumber(model),
      viewModelBuilder: () => PhoneAuthViewModel(),
      onModelReady: (model) => model.initState(),
    );
  }
  double _paddingPhoneNumber = 12.0;
  Widget getPhoneNumber(model) {
    return Column(
      children: <Widget>[
        Padding(
          padding:  EdgeInsets.all(_paddingPhoneNumber),
          child: Text("Enter your phone number", textAlign: TextAlign.center, style: Theme.of(context).textTheme.title),
        ),
        Padding(
          padding:  EdgeInsets.only(left: _paddingPhoneNumber, right: _paddingPhoneNumber, bottom: 36.0),
          child: Text("Make sure you can receive SMS to this number so that we can send you a code",
              textAlign: TextAlign.center, style: Theme.of(context).textTheme.subtitle),
        ),
        Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 24.0, bottom: 8.0, left: _paddingPhoneNumber, right: _paddingPhoneNumber),
              child: TextFormField(
                // controller: _txtNumber,
                textAlign: TextAlign.left,
                keyboardType: TextInputType.phone,
                // maxLength: 9,
                decoration: InputDecoration(
                  fillColor: Theme.of(context).dividerColor,
                  hintStyle: Theme.of(context).textTheme.subtitle,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  ),
                  filled: true,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            Padding(
              padding:  EdgeInsets.only(top: 36.0, bottom: 8.0, left: _paddingPhoneNumber+12.0, right: _paddingPhoneNumber),
              child: CountryPickerDropdown(
                initialValue: 'dz',
                itemBuilder: _buildDropdownItem,
                onValuePicked: (Country country) {
                  print("${country.name}");
                },
              ),
            ),
            Padding(
              padding:  EdgeInsets.only(top: 24.0, bottom: 8.0, left: _paddingPhoneNumber + 150.0, right: _paddingPhoneNumber),
              child: TextField(
                controller: _txtNumber,
                maxLength: 9,
                textAlign: TextAlign.left,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    icon: Icon(
                      FontAwesomeIcons.timesCircle,
                      color: Theme.of(context).accentColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _txtNumber.text = "";
                      });
                      print("clear textnumber icon pressed.");
                    },
                  ),
                  hintText: "XXXXXXXXX",
                  hintStyle: Theme.of(context).textTheme.display2,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  ),
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 24.0, left: 24.0, right: 24.0),
          child: Container(
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.center,
            child: new Row(
              children: <Widget>[
                new Expanded(
                  child: new FlatButton(
                    shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(4.0),
                    ),
                    color: Color(0xFFF93963),
                    onPressed: () {
                      showModalBottomSheet(
                          isScrollControlled: true,
                          context: context,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
                          ),
                          builder: (context) => Container(
                                color: Colors.white,
                                child: Padding(
                                  padding: MediaQuery.of(context).viewInsets,
                                  child: getOTPcode(model),
                                ),
                              ));

                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => PhoneOTPView(
                      //               countryCode: "+213",
                      //               // phoneNumber: "666795827",
                      //               // phoneNumber: "662253959",
                      //               phoneNumber: _txtNumber.text,
                      //               onVerificationFailure: () {
                      //                 print("khra");
                      //               },
                      //               onVerificationSuccess: () async {
                      //                 Navigator.of(context).pop();
                      //                 final FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
                      //                 // showToast("Welcome " + currentUser.phoneNumber, Colors.green);
                      //                 // await currentUser.delete();
                      //                 print("Welcome " + currentUser.phoneNumber);
                      //                 Navigator.of(context).pushReplacementNamed(Routes.scanNetworkView);
                      //               },
                      //             )));
                    },
                    child: new Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 15.0,
                        horizontal: 10.0,
                      ),
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Expanded(
                            child: Text(
                              "Continue",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget getOTPcode(PhoneAuthViewModel model) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            "Activate your account",
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 4.0, right: 16.0),
          child: Text(
            "Enter the code you received via SMS",
            style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.normal),
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
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "The code was sent to (${model.countryCode})${model.phoneNumber} it should arrive withing the next minute ",
          ),
        ),
      ],
    );
  }
}

Widget codeStatus(model) {
  if (model.otpStatus == OTP_Status.sending_sms) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Sending SMS ......",
          style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold, color: Colors.red),
          textAlign: TextAlign.center,
        ),
        CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.red))
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

Widget _buildDropdownItem(Country country) => Row(
      children: <Widget>[
        CountryPickerUtils.getDefaultFlagImage(country),
        SizedBox(
          width: 8.0,
        ),
        Text(
          "+${country.phoneCode}(${country.isoCode})",
          style: TextStyle(fontSize: 14),
        ),
      ],
    );

// void socialBottomSheet(context) {
//   showModalBottomSheet(
//       context: context,
//       builder: (BuildContext bc) {
//         return SocialBottomSheet();
//       });
// }
