// flutter pub run build_runner build
// flutter pub global run dcdg -o abc
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stacked_services/stacked_services.dart';
import 'app/locator.dart';
import 'app/router.gr.dart';
import 'ui/screens/authentication/phone/phone_auth_view.dart';
import 'ui/screens/authentication/unauth_view.dart';
import 'ui/screens/home/home_view.dart';
import 'ui/screens/localNetwork/localNetwork_view.dart';
import 'ui/styles/theme_data.dart';

void main() {

  setupLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: Router().onGenerateRoute,
      navigatorKey: locator<NavigationService>().navigatorKey,
      theme: ThemeScheme.light(),
      // initialRoute: Routes.startupViewRoute,
      home: HomeView(),
    );
  }
}
