import 'all_sensors_model.dart';

class DHT22 {
  Sensor temperature;
  Sensor humidity;

  fromJson(Map<String, dynamic> json) {
    if(json["DHT22"] == null ) return;
    temperature = new Sensor.fromJson(json["DHT22"]["Temperature"]);
    humidity = new Sensor.fromJson(json["DHT22"]["Humidity"]);
  }
}
