import 'package:air_quality_system/app/router.gr.dart';
import 'package:air_quality_system/ui/styles/colors.dart';
import 'package:flutter/material.dart';

class UnAuth extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                child: Image.asset("assets/images/bg.png"),
                decoration: BoxDecoration(),
              ),
            ),
            Container(
              padding: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              height: 250.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: FlatButton(
                          color: _theme.primaryColor,
                          child: Text(
                            "LOGIN",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          onPressed: () {
                            // final NavigationService _navigationService = locator<NavigationService>();
                            // _navigationService.navigateTo(Routes.homeViewRoute);
                            Navigator.of(context).pushNamed(Routes.phoneAuthView);
                          },
                        ),
                      ),
                      SizedBox(width: 40.0),
                      Expanded(
                        child: FlatButton(
                          color: facebookColor,
                          child: Text(
                            "REGISTER",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pushNamed(Routes.phoneAuthView);
                          },
                        ),
                      )
                    ],
                  ),
                  // SizedBox(
                  //   height: 15.0,
                  // ),
                  // Row(
                  //   children: <Widget>[
                  //     Expanded(
                  //       child: Divider(
                  //         color: dbasicGreyColor,
                  //       ),
                  //     ),
                  //     Container(
                  //       child: Text(
                  //         "Or connect with social",
                  //       ),
                  //       padding: EdgeInsets.symmetric(
                  //         horizontal: 15.0,
                  //       ),
                  //     ),
                  //     Expanded(
                  //       child: Divider(
                  //         color: dbasicGreyColor,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // Container(
                  //   margin: EdgeInsets.only(top: 15.0),
                  //   padding: EdgeInsets.symmetric(
                  //     horizontal: 15.0,
                  //   ),
                  //   height: 45.0,
                  //   decoration: BoxDecoration(
                  //     color: facebookColor,
                  //     borderRadius: BorderRadius.circular(6.0),
                  //   ),
                  //   child: Row(
                  //     children: <Widget>[
                  //       Icon(
                  //         FontAwesomeIcons.facebookSquare,
                  //         color: Colors.white,
                  //       ),
                  //       Expanded(
                  //         child: Text(
                  //           "Login with Facebook",
                  //           textAlign: TextAlign.center,
                  //           style: TextStyle(
                  //             color: Colors.white,
                  //             fontWeight: FontWeight.w600,
                  //           ),
                  //         ),
                  //       )
                  //     ],
                  //   ),
                  // ),
                  // Container(
                  //   margin: EdgeInsets.only(top: 15.0),
                  //   padding: EdgeInsets.symmetric(
                  //     horizontal: 15.0,
                  //   ),
                  //   height: 45.0,
                  //   decoration: BoxDecoration(
                  //     border: Border.all(color: _theme.primaryColor),
                  //     borderRadius: BorderRadius.circular(6.0),
                  //   ),
                  //   child: Row(
                  //     children: <Widget>[
                  //       Icon(
                  //         FontAwesomeIcons.google,
                  //         color: _theme.primaryColor,
                  //       ),
                  //       Expanded(
                  //         child: Text(
                  //           "Login with Google",
                  //           textAlign: TextAlign.center,
                  //           style: TextStyle(
                  //             color: _theme.primaryColor,
                  //             fontWeight: FontWeight.w600,
                  //           ),
                  //         ),
                  //       )
                  //     ],
                  //   ),
                  // )
                
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
