// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:auto_route/auto_route.dart';
import 'package:air_quality_system/ui/screens/home/home_view.dart';
import 'package:air_quality_system/ui/screens/authentication/unauth_view.dart';
import 'package:air_quality_system/ui/screens/localNetwork/localNetwork_view.dart';
import 'package:air_quality_system/ui/screens/localNetwork/scanNetwork_view.dart';
import 'package:air_quality_system/ui/screens/contribute/esptouch/esp_touch_view.dart';
import 'package:air_quality_system/ui/screens/contribute/contribute_view.dart';
import 'package:air_quality_system/ui/screens/contribute/map_picker_view.dart';
import 'package:air_quality_system/ui/screens/authentication/phone/phone_auth_view.dart';

abstract class Routes {
  static const homeView = '/';
  static const unAuth = '/un-auth';
  static const localNetworkView = '/local-network-view';
  static const scanNetworkView = '/scan-network-view';
  static const esptouchView = '/esptouch-view';
  static const contributeView = '/contribute-view';
  static const mapPickerView = '/map-picker-view';
  static const phoneAuthView = '/phone-auth-view';
  static const all = {
    homeView,
    unAuth,
    localNetworkView,
    scanNetworkView,
    esptouchView,
    contributeView,
    mapPickerView,
    phoneAuthView,
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
    final args = settings.arguments;
    switch (settings.name) {
      case Routes.homeView:
        return MaterialPageRoute<dynamic>(
          builder: (context) => HomeView(),
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
      case Routes.esptouchView:
        return MaterialPageRoute<dynamic>(
          builder: (context) => ESPTouchView(),
          settings: settings,
        );
      case Routes.contributeView:
        if (hasInvalidArgs<ContributeViewArguments>(args)) {
          return misTypedArgsRoute<ContributeViewArguments>(args);
        }
        final typedArgs =
            args as ContributeViewArguments ?? ContributeViewArguments();
        return MaterialPageRoute<dynamic>(
          builder: (context) => ContributeView(key: typedArgs.key),
          settings: settings,
        );
      case Routes.mapPickerView:
        if (hasInvalidArgs<MapPickerViewArguments>(args)) {
          return misTypedArgsRoute<MapPickerViewArguments>(args);
        }
        final typedArgs =
            args as MapPickerViewArguments ?? MapPickerViewArguments();
        return MaterialPageRoute<dynamic>(
          builder: (context) => MapPickerView(key: typedArgs.key),
          settings: settings,
        );
      case Routes.phoneAuthView:
        return MaterialPageRoute<dynamic>(
          builder: (context) => PhoneAuthView(),
          settings: settings,
        );
      default:
        return unknownRoutePage(settings.name);
    }
  }
}

// *************************************************************************
// Arguments holder classes
// **************************************************************************

//ContributeView arguments holder class
class ContributeViewArguments {
  final Key key;
  ContributeViewArguments({this.key});
}

//MapPickerView arguments holder class
class MapPickerViewArguments {
  final Key key;
  MapPickerViewArguments({this.key});
}
