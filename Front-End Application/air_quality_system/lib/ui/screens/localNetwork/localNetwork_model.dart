import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:air_quality_system/datamodels/device_dataModel.dart';
import 'package:air_quality_system/datamodels/sensor_datamodel.dart';
import 'package:get_ip/get_ip.dart';
import 'package:stacked/stacked.dart';
import 'dart:convert';

// class HomeViewModel extends FutureViewModel<void> {
class LocalNetworkViewModel extends BaseViewModel {
  DeviceDataModel devices = new DeviceDataModel();
  RawDatagramSocket socket;
  String phoneIPaddress;
  // @override
  void initState() async {
    print("=================== initState ");
    // const oneSec = const Duration(seconds: 1);
    // new Timer.periodic(oneSec, (Timer t) {
    //   print("timeout");
    //   int newValue = Random().nextInt(100);
    //   //     devices.sensors.add(SensorDataModel(
    //   //   sensorName: "DHT22",
    //   //   value: newValue.toString(),
    //   //   metric: "°C",
    //   //   metricName: "Calibrated",
    //   //  ));
    //   devices.sensors[0].values.add(newValue.toString());
    //   if(devices.sensors[0].values.length > 20 ) devices.sensors[0].values.removeAt(0);
      
    //   notifyListeners();
    // });
    // devices.sensors.add(SensorDataModel(
    //     sensorName: "DHT22",
    //     value: "27.5",
    //     metric: "°C",
    //     metricName: "Temperature",
    //     values: ["27.5"]
    //    ));
    // devices.sensors.add(SensorDataModel(sensorName: "DHT22", value: "80", metric: "%", metricName: "Humidity"));
    // devices.sensors.add(SensorDataModel(sensorName: "DHT22", value: "27.5", metric: "°C", metricName: "Temperature"));
    // devices.sensors.add(SensorDataModel(sensorName: "DHT22", value: "27.5", metric: "°C", metricName: "Calibrated"));
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
        String message = new String.fromCharCodes(d.data).trim();
        message = message.replaceAll("Â", "");
        print('Datagram from ${d.address.address}:${d.port}: ${message}');
        if (!isJSON(message)) return;
        Map<String, dynamic> _json = json.decode(message);
        if (phoneIPaddress == d.address.address) return;

        devices.fromJson(_json);
        devices.removeNULLmetric();
        notifyListeners();
      });
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
    // String ipAddress = await GetIp.ipAddress;

    List<String> split = phoneIPaddress.split(".");
    split[3] = "255";
    String boradcastAddress = split[0] + "." + split[1] + "." + split[2] + "." + split[3];
    print(boradcastAddress);
    // socket.send('<refresh>'.codeUnits, InternetAddress.anyIPv4, 9876);
    var json = jsonEncode({
      "command": "getData",
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
