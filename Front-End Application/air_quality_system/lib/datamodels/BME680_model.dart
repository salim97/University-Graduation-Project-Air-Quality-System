import 'sense_model.dart';

class BME680 {
  Sense temperature;
  Sense pressure;
  Sense humidity;
  Sense altitude;
  // Sensor gas;

  fromJson(Map<String, dynamic> json) {
    if (json["BME680"] == null) return;
    temperature =
        new Sense.fromJson(json["BME680"]["Temperature"], "Temperature");
    humidity = new Sense.fromJson(json["BME680"]["Humidity"], "Humidity");
    pressure = new Sense.fromJson(json["BME680"]["Pressure"], "Pressure");
    altitude = new Sense.fromJson(
        json["BME680"]["Approx. Altitude"], "Approx. Altitude");
    // gas = new Sensor.fromJson(json["BME680"]["Gas"]);
  }

  List<Sense> toSensors() {
    List<Sense> tmp = new List<Sense>();
    tmp.add(temperature);
    tmp.add(humidity);
    tmp.add(pressure);
    tmp.add(altitude);
    return tmp;
  }
}
