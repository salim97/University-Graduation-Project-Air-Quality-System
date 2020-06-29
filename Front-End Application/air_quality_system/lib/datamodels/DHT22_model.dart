import 'sense_model.dart';

class DHT22 {
  Sense temperature;
  Sense humidity;

  fromJson(Map<String, dynamic> json) {
    if (json["DHT22"] == null) return;
    temperature = new Sense.fromJson(json["DHT22"]["Temperature"], "Temperature");
    humidity = new Sense.fromJson(json["DHT22"]["Humidity"], "Humidity");
  }

  List<Sense> toSensors() {
    List<Sense> tmp = new List<Sense>();
    tmp.add(temperature);
    tmp.add(humidity);
    return tmp;
  }
}
