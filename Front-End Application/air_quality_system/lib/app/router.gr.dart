// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

import 'package:air_quality_system/ui/screens/contribute/scanNetwork_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:auto_route/auto_route.dart';
import 'package:air_quality_system/ui/screens/home/home_view.dart';
import 'package:air_quality_system/ui/screens/authentication/phone/phone_auth_view.dart';
import 'package:air_quality_system/ui/screens/authentication/unauth_view.dart';
import 'package:air_quality_system/ui/screens/localNetwork/localNetwork_view.dart';

abstract class Routes {
  static const homeView = '/';
  static const phoneAuthView = '/phone-auth-view';
  static const unAuth = '/un-auth';
  static const localNetworkView = '/local-network-view';
  static const scanNetworkView = '/scan-network-view';
  static const all = {
    homeView,
    phoneAuthView,
    unAuth,
    localNetworkView,
    scanNetworkView,
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
      case Routes.localNetworkView:
        return MaterialPageRoute<dynamic>(
          builder: (context) => LocalNetworkView(),
          settings: settings,
        );
      case Routes.scanNetworkView:
        return MaterialPageRoute<dynamic>(
          builder: (context) => ScanNetworkView(),
          settings: settings,
        );
      default:
        return unknownRoutePage(settings.name);
    }
  }
}
