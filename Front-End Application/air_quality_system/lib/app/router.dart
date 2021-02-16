// flutter pub run build_runner clean
// flutter pub run build_runner build --delete-conflicting-outputs

import 'package:air_quality_system/ui/screens/authentication/phone/phone_auth_view.dart';
import 'package:air_quality_system/ui/screens/authentication/unauth_view.dart';
import 'package:air_quality_system/ui/screens/contribute/device_sync_view.dart';
import 'package:air_quality_system/ui/screens/contribute/map_picker_view.dart';
import 'package:air_quality_system/ui/screens/home/home_view.dart';
import 'package:air_quality_system/ui/screens/localNetwork/localNetwork_view.dart';
import 'package:air_quality_system/ui/screens/localNetwork/scanNetwork_view.dart';
import 'package:air_quality_system/ui/screens/contribute/esptouch/esp_touch_view.dart';
import 'package:air_quality_system/ui/screens/contribute/contribute_view.dart';

import 'package:auto_route/auto_route_annotations.dart';

@MaterialAutoRouter()
class $Router {
  @initial
  HomeView homeView;
  UnAuth unAuth;
  LocalNetworkView localNetworkView;
  ScanNetworkView scanNetworkView;
  ESPTouchView esptouchView;
  ContributeView contributeView;
  MapPickerView mapPickerView;
  PhoneAuthView phoneAuthView;
  DeviceSyncView deviceSyncView;
}
