import 'dart:async';
import 'package:air_quality_system/app/locator.dart';
import 'package:air_quality_system/datamodels/localNetowrkDevice_datamodel.dart';
import 'package:air_quality_system/services/localNetworkEngine.dart';
import 'package:android_intent/android_intent.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wifi_configuration/wifi_configuration.dart';
import 'package:wifi_connector/wifi_connector.dart';
import 'package:wifi_flutter/wifi_flutter.dart';
import 'package:http/http.dart' as http;

// class HomeViewModel extends FutureViewModel<void> {
class DeviceSyncViewModel extends IndexTrackingViewModel {
  final DialogService _dialogService = locator<DialogService>();
  final NavigationService navigationService = locator<NavigationService>();
  final LocalNetworkEngineService _localNetworkEngine = locator<LocalNetworkEngineService>();

  // ServiceStatus serviceStatus = ServiceStatus.disabled;
  List<LocalNetworkDevice> devices = List<LocalNetworkDevice>();

  void initState() async {
    // _localNetworkEngine.init();
    // refreshIndicatorKey.currentState.show(atTop: false);
    // refreshIndicatorKey.currentState.show();
    notifyListeners();
  }

  final GlobalKey<LiquidPullToRefreshState> refreshIndicatorKey = GlobalKey<LiquidPullToRefreshState>();
  Future<void> onRefresh() async {
    final Connectivity _connectivity = Connectivity();
    StreamSubscription<ConnectivityResult> _connectivitySubscription;
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.wifi) {
      await _dialogService.showDialog(
        title: "WiFi is OFF",
        description: "can't scan network when Wifi is OFF, please connecte to your local wifi network ",
        dialogPlatform: DialogPlatform.Material,
      );
      return;
    }
    devices = await _localNetworkEngine.scanLocalNetwork(timeOutDuration: Duration(seconds: 1));

    if (devices.isEmpty) {
      await _dialogService.showDialog(
        title: "Not Found",
        description: "Couldn't find AQ device in your local network, make sure the device is powered ON",
        dialogPlatform: DialogPlatform.Material,
      );

      // await connectToAQDeviceAP();
    }

    notifyListeners();
  }

  String remoteAP = "AQ device config mode";
  connectToAQDeviceAP() async {
    bool configured = await checkIfConnectedToAQDeviceAP();
    String connectedToWifi = await WifiConfiguration.connectedToWifi();
    print(connectedToWifi);
    if (configured) return;
    bool existe = false;

    bool ok;
    // bool prompted =await  WifiFlutter.promptPermissions();
    // if(!prompted) {
    //   return ;
    // }
    Iterable<WifiNetwork> networks;
    try {
      networks = await WifiFlutter.scanNetworks();
    } catch (err) {
      await _dialogService.showDialog(
        title: "Error",
        description: "check if AQ device is power ON and if there is access point (WiFi) with name \"" +
            remoteAP +
            "\" try to connect into it manually and come back into app and scan again",
        dialogPlatform: DialogPlatform.Material,
      );
      return;
    }

    // bool existe = false;
    networks.forEach((element) {
      print(element.ssid);
      if (element.ssid == remoteAP) existe = true;
    });
    if (existe) {
      ok = await WifiConnector.connectToWifi(ssid: remoteAP);
      if (!ok) {
        await _dialogService.showDialog(
          title: "Issue",
          description: "Couldn't connecte to AQ Device WiFi, try to connect to open WiFi manually, WiFi name is \"" + remoteAP + "\" ",
          dialogPlatform: DialogPlatform.Material,
        );
        final AndroidIntent intent = AndroidIntent(action: 'android.settings.ACTION_WIFI_SETTINGS');
        await intent.launch();
        return;
      }
      int retry = 10;
      while (retry > 0) {
        await Future.delayed(const Duration(milliseconds: 400), () {});
        bool isConnected = await WifiConfiguration.isConnectedToWifi(remoteAP);
        if (isConnected) break;
        retry--;
      }

      checkIfConnectedToAQDeviceAP();
      // const url = 'http://192.168.31.1/wifi?';
      // if (await canLaunch(url)) {
      //   await launch(url);
      // } else {
      //   throw 'Could not launch $url';
      // }
//         http.Response r = await http.get('http://192.168.4.1/');
// // http://192.168.4.1/wifisave?s=idoomAdsl01&p=builder2019cpp
// //post user name koqsdfhpgmkbnjlvsdn
//         print("http response status code = " + r.statusCode.toString());

//       ok = await WifiConnector.connectToWifi(ssid: "AQ device config mode");
//       if (ok) {
//         // do something to wait for 2 seconds
//         await Future.delayed(const Duration(seconds: 4), () {});
//         http.Response r = await http.get('http://192.168.4.1/');
// // http://192.168.4.1/wifisave?s=idoomAdsl01&p=builder2019cpp
// //post user name koqsdfhpgmkbnjlvsdn
//         print("http response status code = " + r.statusCode.toString());
//       }
//     }

//     if (!ok) {}
    }
  }

  Future<bool> checkIfConnectedToAQDeviceAP() async {
    bool isConnected = await WifiConfiguration.isConnectedToWifi(remoteAP);
    if (isConnected) {
      // await _dialogService.showDialog(
      //   title: "Issue",
      //   description:
      //       "AQ Device needs WiFi name and password in order to be available in your local network, the password will be stored in AQ device and not in mobile app",
      //   dialogPlatform: DialogPlatform.Material,
      // );
      AndroidIntent intent = AndroidIntent(action: 'action_view', data: 'http://192.168.31.1/wifi?');
      await intent.launch();
    }
    return isConnected;
  }
  // syncWithDevice(index) async {
  //   print(devices.elementAt(index));

  //   ServiceStatus serviceStatus = await LocationPermissions().checkServiceStatus();

  //   while (serviceStatus == ServiceStatus.disabled) {
  //     await _dialogService.showDialog(
  //       title: "GPS Disabled",
  //       description: "enable GPS service",
  //       dialogPlatform: DialogPlatform.Material,
  //     );
  //     final AndroidIntent intent = new AndroidIntent(
  //       action: 'android.settings.LOCATION_SOURCE_SETTINGS',
  //     );
  //     await intent.launch();
  //     serviceStatus = await LocationPermissions().checkServiceStatus();
  //   }
  //   PermissionStatus permission = await LocationPermissions().requestPermissions();
  //   print(permission);
  //   if (permission == PermissionStatus.granted) {
  //     Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  //     final FirebaseUser currentUser = await FirebaseAuth.instance.currentUser();
  //     var json = jsonEncode({
  //       "command": "setData",
  //       "uid": currentUser.uid,
  //       "requestDateTime": DateTime.now().toString(),
  //       "GPS": {"latitude": position.latitude, "longitude": position.longitude, "altitude": position.altitude}
  //     });
  //     udpBroadcast(json);

  //     notifyListeners();
  //   } else {
  //     await _dialogService.showDialog(
  //       title: "GPS ERROR",
  //       description: "granted GPS access to set location of your ESP in map",
  //       dialogPlatform: DialogPlatform.Material,
  //     );
  //   }
  // }

}
