// flutter pub run build_runner build
// flutter pub global run dcdg -o abc
import 'dart:io';

import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';
import 'app/locator.dart';
import 'app/router.gr.dart'  ;
import 'ui/screens/contribute/contribute_view.dart';
import 'ui/screens/contribute/device_sync_view.dart';
import 'ui/screens/contribute/esptouch/esp_touch_view.dart';
import 'ui/screens/contribute/map_picker_view.dart';
import 'ui/screens/home/home_view.dart';
import 'ui/screens/localNetwork/localNetwork_view.dart';

void setupDialogUi() {
  var dialogService = locator<DialogService>();

  dialogService.registerCustomDialogUi((context, dialogRequest) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(2),
          height: MediaQuery.of(context).size.height * 0.8,
          // width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.90), borderRadius: BorderRadius.all(Radius.circular(36)), boxShadow: [
            BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.3), blurRadius: 36),
          ]),
          child: dialogRequest.customData as Widget,
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
        primaryColor: Colors.blue, //Color(0xFFF93963),
        accentColor: Colors.cyan[600],
        fontFamily: 'Montserrat',
        textTheme: TextTheme(
          headline: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          title: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
          subtitle: TextStyle(fontSize: 16),
          body1: TextStyle(fontSize: 14.0, fontFamily: 'Montserrat'),
          display1: TextStyle(fontSize: 14.0, fontFamily: 'Montserrat1', color: Colors.white),
          display2: TextStyle(fontSize: 14.0, fontFamily: 'Montserrat', color: Colors.black54),
        ),
      ),
      // theme: ThemeScheme.light(),
      // initialRoute: Routes.startupViewRoute,
      // home: FeatureDiscovery(recordStepsInSharedPreferences: false, child: HomeView()),
       home: LocalNetworkView(),
    );
  }
}

