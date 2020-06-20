import 'all_sensors_model.dart';

class MICS6814 {
  Sensor no2;
  Sensor nh3;
  Sensor co;

  fromJson(Map<String, dynamic> json) {
    if (json["MICS6814"] == null) return;
    no2 = new Sensor.fromJson(json["MICS6814"]["NO2"]);
    nh3 = new Sensor.fromJson(json["MICS6814"]["NH3"]);
    co = new Sensor.fromJson(json["MICS6814"]["CO"]);
  }
}
