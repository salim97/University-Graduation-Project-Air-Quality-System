import 'package:air_quality_system/app/router.gr.dart';
import 'package:air_quality_system/ui/widgets/authentication/countrydropdown.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'phone_otp_view.dart';

class PhoneAuthView extends StatefulWidget {
  @override
  _PhoneAuthViewState createState() => _PhoneAuthViewState();
}

class _PhoneAuthViewState extends State<PhoneAuthView> {
  var _txtNumber = TextEditingController();
  String _txtNumberHint = "05078596252";

  @override
  void initState() {
    _txtNumber.text = "662253959";
    // _txtNumber.addListener(() {
    //   setState(() {
    //     _txtNumberHint = _txtNumber.text;
    //     print("Text Number Value: ${_txtNumber.text}");
    //   });
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 96.0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text("What is your phone number?", textAlign: TextAlign.center, style: Theme.of(context).textTheme.title),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 36.0),
                  child: Text("We will send an SMS with a code to your phone number",
                      textAlign: TextAlign.center, style: Theme.of(context).textTheme.subtitle),
                ),
                Stack(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 24.0, bottom: 8.0, left: 24.0, right: 24.0),
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
                      padding: const EdgeInsets.only(top: 36.0, bottom: 8.0, left: 36.0, right: 24.0),
                      child: CountryPickerDropdown(
                        initialValue: 'dz',
                        itemBuilder: _buildDropdownItem,
                        onValuePicked: (Country country) {
                          print("${country.name}");
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0, left: 184.0, right: 24.0),
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
                          hintText: "I  Number",
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
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PhoneOTPView(
                                            countryCode: "+213",
                                            // phoneNumber: "666795827",
                                            // phoneNumber: "662253959",
                                            phoneNumber: _txtNumber.text,
                                            onVerificationFailure: () {
                                              print("khra");
                                            },
                                            onVerificationSuccess: () async {
                                              Navigator.of(context).pop();
                                              final FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
                                              // showToast("Welcome " + currentUser.phoneNumber, Colors.green);
                                              // await currentUser.delete();
                                              print("Welcome " + currentUser.phoneNumber);
                                              Navigator.of(context).pushReplacementNamed(Routes.scanNetworkView);
                                            },
                                          )));
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
                                      "Next",
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
            ),
          ),
        ),
      ),
    );
  }
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
