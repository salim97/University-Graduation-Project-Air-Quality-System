import 'sense_model.dart';

class MHZ19 {
  Sense temperature;
  Sense co2;
  String raw_CO2;

  fromJson(Map<String, dynamic> json) {
    if (json["MHZ19"] == null) return;
    temperature =
        new Sense.fromJson(json["MHZ19"]["Temperature"], "Temperature");
    co2 = new Sense.fromJson(json["MHZ19"]["Unlimited CO2"], "CO2");
    raw_CO2 = json["MHZ19"]["Raw CO2"]["value"].toString();
  }

  List<Sense> toSensors() {
    List<Sense> tmp = new List<Sense>();
    tmp.add(temperature);
    tmp.add(co2);
    return tmp;
  }
}
