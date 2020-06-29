import 'sense_model.dart';

class MICS6814 {
  Sense no2;
  Sense nh3;
  Sense co;

  fromJson(Map<String, dynamic> json) {
    if (json["MICS6814"] == null) return;
    no2 = new Sense.fromJson(json["MICS6814"]["NO2"], "NO2");
    nh3 = new Sense.fromJson(json["MICS6814"]["NH3"], "NH3");
    co = new Sense.fromJson(json["MICS6814"]["CO"], "CO");
  }

  List<Sense> toSensors() {
    List<Sense> tmp = new List<Sense>();
    tmp.add(no2);
    tmp.add(nh3);
    tmp.add(co);
    return tmp;
  }

}
