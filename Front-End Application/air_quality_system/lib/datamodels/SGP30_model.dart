import 'all_sensors_model.dart';

class SGP30 {
  Sensor tvoc;
  Sensor eCO2;
  String raw_H2, raw_Ethanol;

  fromJson(Map<String, dynamic> json) {
    if (json["SGP30"] == null) return;
    tvoc = new Sensor.fromJson(json["SGP30"]["TVOC"]);
    eCO2 = new Sensor.fromJson(json["SGP30"]["eCO2"]);
    raw_H2 = json["SGP30"]["Raw H2"]["value"].toString();
    raw_Ethanol = json["SGP30"]["Raw Ethanol"]["value"].toString();
  }
}
