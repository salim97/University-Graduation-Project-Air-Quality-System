import 'DHT22_model.dart';
import 'GPS_model.dart';
import 'MHZ19_model.dart';
import 'MICS6814_model.dart';
import 'SGP30_model.dart';
import 'BME680_model.dart';

class Sensor{
  String value;
  String type;
  bool isCalibrated;
}

class All_Sensors{
  DHT22 dht22;
  MICS6814 mics6814;
  SGP30 sgp30;
  MHZ19 mhz19;
  BME680 bme680;
  GPS gps;
}

