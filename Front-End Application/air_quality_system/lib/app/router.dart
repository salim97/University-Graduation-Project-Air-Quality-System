import 'package:air_quality_system/ui/screens/authentication/phone/phone_auth_view.dart';
import 'package:air_quality_system/ui/screens/authentication/unauth_view.dart';
import 'package:air_quality_system/ui/screens/home/home_view.dart';
import 'package:air_quality_system/ui/screens/walkthrough.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


import 'package:auto_route/auto_route_annotations.dart';


@MaterialAutoRouter()
class $Router {
  @initial
  WalkThrough startupViewRoute;
  HomeView homeView;
  PhoneAuthView phoneAuthView;
  UnAuth unAuth;
}


