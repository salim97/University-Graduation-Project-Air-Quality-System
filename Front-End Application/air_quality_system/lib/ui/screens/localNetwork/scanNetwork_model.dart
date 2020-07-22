import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:air_quality_system/app/locator.dart';
import 'package:air_quality_system/datamodels/device_dataModel.dart';
import 'package:air_quality_system/datamodels/esp_network_log_datamodel.dart';
import 'package:air_quality_system/datamodels/localNetowrkDevice_datamodel.dart';
import 'package:air_quality_system/datamodels/sensor_datamodel.dart';
import 'package:android_intent/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_ip/get_ip.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:stacked/stacked.dart';
import 'dart:convert';

import 'package:stacked_services/stacked_services.dart';

// class HomeViewModel extends FutureViewModel<void> {
class ScanNetworkViewModel extends IndexTrackingViewModel {
  final DialogService _dialogService = locator<DialogService>();

  // ServiceStatus serviceStatus = ServiceStatus.disabled;
  List<LocalNetworkDevice> devices = List<LocalNetworkDevice>();
  RawDatagramSocket socket;
  String phoneIPaddress;
  void initState() async {
    // LocationPermissions().checkServiceStatus().then((ServiceStatus serviceStatus) {
    //   print(serviceStatus);
    //   this.serviceStatus = serviceStatus;
    //   notifyListeners();
    // });

    phoneIPaddress = await GetIp.ipAddress;
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 9876).then((RawDatagramSocket socket) {
      print('Datagram socket ready to receive');
      print('${socket.address.address}:${socket.port}');
      socket.broadcastEnabled = true;
      this.socket = socket;
      notifyListeners();
      socket.listen((RawSocketEvent e) {
        Datagram d = socket.receive();
        if (d == null) return;
        if (phoneIPaddress == d.address.address) return;

        String message = new String.fromCharCodes(d.data).trim();
        message = message.replaceAll("Â", "");
        print('Datagram from ${d.address.address}:${d.port}: ${message}');
        if (!isJSON(message)) return;
        Map<String, dynamic> _json = json.decode(message);
        if (LocalNetworkDevice.isJSONvalide(_json)) {
          devices.insert(0, LocalNetworkDevice.fromJson(_json));
        }
        // else {
        //   devices.fromJson(_json);
        //   devices.removeNULLmetric();
        // }
        notifyListeners();
      });
    });
    refreshIndicatorKey.currentState.show(atTop: false);
    notifyListeners();
  }

  final GlobalKey<LiquidPullToRefreshState> refreshIndicatorKey = GlobalKey<LiquidPullToRefreshState>();
  Future<void> onRefresh() async {
    final Completer<void> completer = Completer<void>();
    Timer(const Duration(seconds: 1), () {
      // print(refreshIndicatorKey.currentContext);
      // devices.add(new LocalNetworkDevice(name: "esp32"));
      notifyListeners();
      completer.complete();
    });
    var json = jsonEncode({
      "command": "scanNetwork",
    });
    devices.clear();
    udpBroadcast(json);
    return completer.future;
  }

  syncWithDevice(index) async {
    print(devices.elementAt(index));

    ServiceStatus serviceStatus = await LocationPermissions().checkServiceStatus();

    while (serviceStatus == ServiceStatus.disabled) {
      await _dialogService.showDialog(
        title: "GPS Disabled",
        description: "enable GPS service",
        dialogPlatform: DialogPlatform.Material,
      );
      final AndroidIntent intent = new AndroidIntent(
        action: 'android.settings.LOCATION_SOURCE_SETTINGS',
      );
      await intent.launch();
      serviceStatus = await LocationPermissions().checkServiceStatus();
    }
    PermissionStatus permission = await LocationPermissions().requestPermissions();
    print(permission);
    if (permission == PermissionStatus.granted) {
      Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      var json = jsonEncode({
        "command": "setData",
        "uid": "Lf7gh5IDYxZgOmUXKhtaHSk6j9y2",
        "requestDateTime": DateTime.now().toString(),
        "GPS": {"latitude": position.latitude, "longitude": position.longitude, "altitude": position.altitude}
      });
      udpBroadcast(json);
    } else {
      await _dialogService.showDialog(
        title: "GPS ERROR",
        description: "granted GPS access to set location of your ESP in map",
        dialogPlatform: DialogPlatform.Material,
      );
    }
  }

  udpBroadcast(json) {
    // String ipAddress = await GetIp.ipAddress;
    List<String> split = phoneIPaddress.split(".");
    split[3] = "255";
    String boradcastAddress = split[0] + "." + split[1] + "." + split[2] + "." + split[3];
    print(boradcastAddress);
    // socket.send('<refresh>'.codeUnits, InternetAddress.anyIPv4, 9876);
    socket.send(json.codeUnits, InternetAddress(boradcastAddress), 9876);
  }

  bool isJSON(String msg) {
    bool decodeSucceeded = false;
    try {
      var x = json.decode(msg) as Map<String, dynamic>;
      decodeSucceeded = true;
    } on FormatException catch (e) {
      print('The provided string is not valid JSON');
    }
    print('Decoding succeeded: $decodeSucceeded');
    return decodeSucceeded;
  }
}
