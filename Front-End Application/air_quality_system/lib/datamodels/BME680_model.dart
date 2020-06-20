import 'all_sensors_model.dart';

class BME680 {
  Sensor temperature;
  Sensor pressure;
  Sensor humidity;
  Sensor altitude;
  // Sensor gas;

  fromJson(Map<String, dynamic> json) {
    if (json["BME680"] == null) return;
    temperature = new Sensor.fromJson(json["BME680"]["Temperature"]);
    humidity = new Sensor.fromJson(json["BME680"]["Humidity"]);
    pressure = new Sensor.fromJson(json["BME680"]["Pressure"]);
    altitude = new Sensor.fromJson(json["BME680"]["Approx. Altitude"]);
    // gas = new Sensor.fromJson(json["BME680"]["Gas"]);
  }
}
