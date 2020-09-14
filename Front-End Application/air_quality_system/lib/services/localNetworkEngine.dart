import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:air_quality_system/datamodels/localNetowrkDevice_datamodel.dart';
import 'package:get_ip/get_ip.dart';

class LocalNetworkEngineService {
  List<LocalNetworkDevice> devices = List<LocalNetworkDevice>();
  RawDatagramSocket socket;
  String phoneIPaddress;

  _init() async {
    phoneIPaddress = await GetIp.ipAddress;
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 9876).then((RawDatagramSocket socket) {
      print('Datagram socket ready to receive');
      print('${socket.address.address}:${socket.port}');
      socket.broadcastEnabled = true;
      this.socket = socket;
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
          LocalNetworkDevice lnd = LocalNetworkDevice.fromJson(_json);
          devices.removeWhere((device) => device.ip == lnd.ip); // remove non existing sensors
          devices.add(lnd);
        }
        // else {
        //   devices.fromJson(_json);
        //   devices.removeNULLmetric();
        // }
      });
    });
  }

  scanLocalNetwork({timeOutDuration: const Duration(seconds: 1)}) {
    _init();
    var scanCommand = jsonEncode({
      "command": "scanNetwork",
    });

    Timer timerPeriodic ;
    Completer<List<LocalNetworkDevice>> _scanCompleter = new Completer();
    Timer(timeOutDuration, () {
      timerPeriodic.cancel();
      socket.close();
      _scanCompleter.complete(devices);
    });


    timerPeriodic =Timer.periodic(Duration(milliseconds: 100), (Timer t) {
      devices.clear();
      udpBroadcast(scanCommand);
    });

    return _scanCompleter.future;
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
