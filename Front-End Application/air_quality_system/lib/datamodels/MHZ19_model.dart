import 'all_sensors_model.dart';

class MHZ19 {
  Sensor temperature;
  Sensor co2;
  String raw_CO2;

  fromJson(Map<String, dynamic> json) {
    if (json["MHZ19"] == null) return;
    temperature = new Sensor.fromJson(json["MHZ19"]["Temperature"]);
    co2 = new Sensor.fromJson(json["MHZ19"]["Unlimited CO2"]);
    raw_CO2 = json["MHZ19"]["Raw CO2"]["value"].toString();
  }
}
