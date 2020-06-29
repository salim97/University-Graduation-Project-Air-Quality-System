import 'dart:io';
import 'package:air_quality_system/datamodels/BME680_model.dart';
import 'package:air_quality_system/datamodels/DHT22_model.dart';
import 'package:air_quality_system/datamodels/Device.dart';
import 'package:air_quality_system/datamodels/MHZ19_model.dart';
import 'package:air_quality_system/datamodels/MICS6814_model.dart';
import 'package:air_quality_system/datamodels/SGP30_model.dart';
import 'package:stacked/stacked.dart';
import 'dart:convert';

// class HomeViewModel extends FutureViewModel<void> {
class LocalNetworkViewModel extends BaseViewModel {
  List<Device> devices = new List<Device>();
  // @override
  void initState() async {
    print("=================== initState ");
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 9876)
        .then((RawDatagramSocket socket) {
      print('Datagram socket ready to receive');
      print('${socket.address.address}:${socket.port}');
      socket.listen((RawSocketEvent e) {
        Datagram d = socket.receive();
        if (d == null) return;
        String message = new String.fromCharCodes(d.data).trim();
        message = message.replaceAll("Â", "");
        print('Datagram from ${d.address.address}:${d.port}: ${message}');
        Map<String, dynamic> _json = json.decode(message);

        DHT22 dht22 = new DHT22();
        MICS6814 mics6814 = new MICS6814();
        SGP30 sgp30 = new SGP30();
        MHZ19 mhz19 = new MHZ19();
        BME680 bme680 = new BME680();

        dht22.fromJson(_json);
        mics6814.fromJson(_json);
        sgp30.fromJson(_json);
        mhz19.fromJson(_json);
        bme680.fromJson(_json);

        if (devices.isEmpty) {
          devices.add(Device(name: "DHT22", sensors: dht22.toSensors()));
          devices.add(Device(name: "MICS6814", sensors: mics6814.toSensors()));
          devices.add(Device(name: "SGP30", sensors: sgp30.toSensors()));
          devices.add(Device(name: "MHZ19", sensors: mhz19.toSensors()));
          devices.add(Device(name: "BME680", sensors: bme680.toSensors()));
        } else {
          devices.where((device) => device.name == "DHT22").forEach((element) {
            element.sensors = dht22.toSensors();
            element.setCurrentTime();
          });

          devices
              .where((device) => device.name == "MICS6814")
              .forEach((element) {
            element.sensors = mics6814.toSensors();
            element.setCurrentTime();
          });

          devices.where((device) => device.name == "SGP30").forEach((element) {
            element.sensors = sgp30.toSensors();
            element.setCurrentTime();
          });

          devices.where((device) => device.name == "MHZ19").forEach((element) {
            element.sensors = mhz19.toSensors();
            element.setCurrentTime();
          });

          devices.where((device) => device.name == "BME680").forEach((element) {
            element.sensors = bme680.toSensors();
            element.setCurrentTime();
          });
        }

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
}
