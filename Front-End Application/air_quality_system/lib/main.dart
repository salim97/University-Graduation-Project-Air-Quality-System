// flutter pub run build_runner build
// flutter pub global run dcdg -o abc
import 'dart:io';

import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stacked_services/stacked_services.dart';
import 'app/locator.dart';
import 'app/router.gr.dart';
import 'ui/screens/authentication/phone/phone_auth_view.dart';
import 'ui/screens/authentication/unauth_view.dart';
import 'ui/screens/home/home_view.dart';
import 'ui/screens/localNetwork/localNetwork_view.dart';
import 'ui/screens/localNetwork/scanNetwork_view.dart';
import 'ui/styles/theme_data.dart';

void setupDialogUi() {
  var dialogService = locator<DialogService>();

  dialogService.registerCustomDialogUi((context, dialogRequest) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                dialogRequest.title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                dialogRequest.description,
                style: TextStyle(
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: () => dialogService.completeDialog(DialogResponse()),
                child: Container(
                  child: dialogRequest.showIconInMainButton ? Icon(Icons.check_circle) : Text(dialogRequest.mainButtonTitle),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              )
            ],
          ),
        ),
      ));
}

void main() {
  setupLocator();
  setupDialogUi();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: Router().onGenerateRoute,
      navigatorKey: locator<NavigationService>().navigatorKey,     
       theme: ThemeData(
        dividerColor: Color(0xFFECEDF1),
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        primaryColor: Color(0xFFF93963),
        accentColor: Colors.cyan[600],
        fontFamily: 'Montserrat',
        textTheme: TextTheme(
          headline: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          title: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
          subtitle: TextStyle(fontSize: 16),
          body1: TextStyle(fontSize: 14.0, fontFamily: 'Montserrat'),
          display1: TextStyle(
              fontSize: 14.0, fontFamily: 'Montserrat1', color: Colors.white),
          display2: TextStyle(
              fontSize: 14.0, fontFamily: 'Montserrat', color: Colors.black54),
        ),
      ),
      // theme: ThemeScheme.light(),
      // initialRoute: Routes.startupViewRoute,
      home: FeatureDiscovery(
          recordStepsInSharedPreferences: false,
          child: HomeView()),
    );
  }
}
