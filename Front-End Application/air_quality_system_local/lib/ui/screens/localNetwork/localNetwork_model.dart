import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:air_quality_system_local/datamodels/device_dataModel.dart';
import 'package:air_quality_system_local/datamodels/esp_network_log_datamodel.dart';
import 'package:air_quality_system_local/datamodels/localNetowrkDevice_datamodel.dart';
import 'package:get_ip/get_ip.dart';
import 'package:stacked/stacked.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// class HomeViewModel extends FutureViewModel<void> {
class LocalNetworkViewModel extends IndexTrackingViewModel {
  DeviceDataModel devices = new DeviceDataModel();
  List<ESPNetworkLogDataModel> logs = new List<ESPNetworkLogDataModel>();

  List<LocalNetworkDevice> local_network_devices = List<LocalNetworkDevice>();

  RawDatagramSocket socket;
  String phoneIPaddress;
  // @override
  void initState() async {
    print("=================== initState ");

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
          local_network_devices.insert(0, LocalNetworkDevice.fromJson(_json));
        }

        // Map<String, dynamic> _json = json.decode(message);
        // ESPNetworkLogDataModel _eSPNetworkLogDataModel;
        // if (ESPNetworkLogDataModel.isJSONvalide(_json)) {
        //   logs.insert(0, ESPNetworkLogDataModel.fromJson(_json));
        // } else {
        //   devices.fromJson(_json);
        //   devices.removeNULLmetric();
        // }

        notifyListeners();
      });
    });


    Timer.periodic(Duration(seconds: 5), (Timer t) {
      //scanNetwork();
      refresh();
    });
    notifyListeners();
  }

  @override
  void onError(error) {
    // error thrown above will be sent here
    // We can show a dialog, set the error message to show on the UI
    // the UI will be rebuilt after this is called so you can set properties.
  }

  refresh() async {
    scanNetwork();
    if (local_network_devices.isNotEmpty) {
      http.Response response;
      try {
        response = await http.get(Uri.encodeFull("http://"+local_network_devices.first.ip + "/sensors"));
      } catch (e) {
        return Future.error(e.toString());
      }
        String message = response.body.replaceAll("Â", "");

      Map<String, dynamic> _json = json.decode(message);
      devices.fromJson(_json);
      devices.removeNULLmetric();
    }
  }

  scanNetwork() async {
    // String ipAddress = await GetIp.ipAddress;

    List<String> split = phoneIPaddress.split(".");
    split[3] = "255";
    String boradcastAddress = split[0] + "." + split[1] + "." + split[2] + "." + split[3];
    print(boradcastAddress);
    // socket.send('<refresh>'.codeUnits, InternetAddress.anyIPv4, 9876);
    var json = jsonEncode({
      "command": "scanNetwork",
    });
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
