// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:auto_route/auto_route.dart';
import 'package:air_quality_system/ui/screens/walkthrough.dart';
import 'package:air_quality_system/ui/screens/home/home_view.dart';
import 'package:air_quality_system/ui/screens/authentication/phone/phone_auth_view.dart';
import 'package:air_quality_system/ui/screens/authentication/unauth_view.dart';

abstract class Routes {
  static const startupViewRoute = '/';
  static const homeView = '/home-view';
  static const phoneAuthView = '/phone-auth-view';
  static const unAuth = '/un-auth';
  static const all = {
    startupViewRoute,
    homeView,
    phoneAuthView,
    unAuth,
  };
}

class Router extends RouterBase {
  @override
  Set<String> get allRoutes => Routes.all;

  @Deprecated('call ExtendedNavigator.ofRouter<Router>() directly')
  static ExtendedNavigatorState get navigator =>
      ExtendedNavigator.ofRouter<Router>();

  @override
  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.startupViewRoute:
        return MaterialPageRoute<dynamic>(
          builder: (context) => WalkThrough(),
          settings: settings,
        );
      case Routes.homeView:
        return MaterialPageRoute<dynamic>(
          builder: (context) => HomeView(),
          settings: settings,
        );
      case Routes.phoneAuthView:
        return MaterialPageRoute<dynamic>(
          builder: (context) => PhoneAuthView(),
          settings: settings,
        );
      case Routes.unAuth:
        return MaterialPageRoute<dynamic>(
          builder: (context) => UnAuth(),
          settings: settings,
        );
      default:
        return unknownRoutePage(settings.name);
    }
  }
}
