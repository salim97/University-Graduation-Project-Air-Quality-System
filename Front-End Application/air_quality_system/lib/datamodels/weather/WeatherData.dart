
import 'dart:convert';

import 'Condition.dart';


class WeatherData {
  String temperature;
  Condition condition;

  WeatherData(this.temperature, this.condition);

  static WeatherData fromJson(String json) {
    JsonDecoder decoder = new JsonDecoder();
    var map = decoder.convert(json);

    String description = map["weather"][0]["description"];
    int id = map["weather"][0]["id"];
    Condition condition = new Condition(id, description);

    double temperature = map["main"]["temp"].toDouble();

    return new WeatherData(temperature.toString(), condition);
  }

}

