import 'DHT22_model.dart';
import 'GPS_model.dart';
import 'MHZ19_model.dart';
import 'MICS6814_model.dart';
import 'SGP30_model.dart';
import 'BME680_model.dart';

class Sensor {
  String value;
  String type;
  bool isCalibrated;
 
  Sensor({this.value, this.type, this.isCalibrated});

  factory Sensor.fromJson(Map<dynamic, dynamic> json) {
    return Sensor()
      ..value = json['value'].toString() // rak nektha hna ... TODO: check type and then convert
      ..type = json['type'] as String
      ..isCalibrated = json['isCalibrated'] as bool;
  }
}

class All_Sensors {
  DHT22 dht22 = new DHT22();
  MICS6814 mics6814 = new MICS6814();
  SGP30 sgp30 = new SGP30();
  MHZ19 mhz19 = new MHZ19();
  BME680 bme680 = new BME680();
  GPS gps = new GPS();
  int timestamp;
}
