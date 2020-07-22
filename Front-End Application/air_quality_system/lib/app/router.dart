// flutter pub run build_runner clean
// flutter pub run build_runner build --delete-conflicting-outputs

import 'package:air_quality_system/ui/screens/authentication/phone/phone_auth_view.dart';
import 'package:air_quality_system/ui/screens/authentication/unauth_view.dart';
import 'package:air_quality_system/ui/screens/home/home_view.dart';
import 'package:air_quality_system/ui/screens/localNetwork/localNetwork_view.dart';
import 'package:air_quality_system/ui/screens/localNetwork/scanNetwork_view.dart';

import 'package:auto_route/auto_route_annotations.dart';


@MaterialAutoRouter()
class $Router {
  @initial
  HomeView homeView;
  PhoneAuthView phoneAuthView;
  UnAuth unAuth;
  LocalNetworkView localNetworkView;
  ScanNetworkView scanNetworkView;
}


