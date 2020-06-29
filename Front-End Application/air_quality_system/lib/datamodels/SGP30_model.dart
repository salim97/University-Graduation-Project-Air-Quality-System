import 'sense_model.dart';

class SGP30 {
  Sense tvoc;
  Sense eCO2;
  String raw_H2, raw_Ethanol;

  fromJson(Map<String, dynamic> json) {
    if (json["SGP30"] == null) return;
    tvoc = new Sense.fromJson(json["SGP30"]["TVOC"], "TVOC");
    eCO2 = new Sense.fromJson(json["SGP30"]["eCO2"], "eCO2");
    raw_H2 = json["SGP30"]["Raw H2"]["value"].toString();
    raw_Ethanol = json["SGP30"]["Raw Ethanol"]["value"].toString();
  }

  List<Sense> toSensors() {
    List<Sense> tmp = new List<Sense>();
    tmp.add(tvoc);
    tmp.add(eCO2);
    return tmp;
  }
}
