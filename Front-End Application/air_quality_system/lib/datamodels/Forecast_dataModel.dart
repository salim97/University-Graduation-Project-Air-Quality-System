import 'dart:convert';


class ForecastDataModel {
  List<ForecastWeatherDataModel> forecastList;

  ForecastDataModel(this.forecastList);

  static ForecastDataModel fromJson(String json) {
    try {
      JsonDecoder decoder = new JsonDecoder();
      var map = decoder.convert(json);

      var list = map["list"];
      List<ForecastWeatherDataModel> forecast = [];

      for (var weatherMap in list) {
        forecast.add(ForecastWeatherDataModel._fromJson(weatherMap));
      }

      return new ForecastDataModel(forecast);
    } catch (e) {
      return null;
    }
  }
}

class ForecastWeatherDataModel {
  String temperature;
  ConditionDataModel condition;
  DateTime dateTime;

  double pressure;
  double humidity;
  double wind;
  //Wind, rain, etc.

  ForecastWeatherDataModel(this.temperature, this.condition, this.dateTime, this.pressure, this.humidity, this.wind);

  static ForecastWeatherDataModel _fromJson(Map<String, dynamic> map) {
    String description = map["weather"][0]["description"];
    int conditionId = map["weather"][0]["id"];
    ConditionDataModel condition = new ConditionDataModel(conditionId, description);

    double temperature = map["main"]["temp"].toDouble();
    double humidity = map["main"]["humidity"].toDouble();
    double pressure = map["main"]["pressure"].toDouble();
    double wind = map["wind"]["speed"].toDouble();
    int epochTimeMs = map["dt"] * 1000;
    DateTime dateTime = new DateTime.fromMillisecondsSinceEpoch(epochTimeMs);

    return new ForecastWeatherDataModel(temperature.toStringAsFixed(1), condition, dateTime, pressure, humidity, wind);
  }
}


class ConditionDataModel {
  int id;
  String description;

  ConditionDataModel(this.id, this.description);

  String getAssetString() {
    if (id >= 200 && id <= 299)
      return "assets/img/d7s.png";
    else if (id >= 300 && id <= 399)
      return "assets/img/d6s.png";
    else if (id >= 500 && id <= 599)
      return "assets/img/d5s.png";
    else if (id >= 600 && id <= 699)
      return "assets/img/d8s.png";
    else if (id >= 700 && id <= 799)
      return "assets/img/d9s.png";
    else if (id >= 300 && id <= 399)
      return "assets/img/d6s.png";
    else if (id == 800)
      return "assets/img/temperature.png";
    else if (id == 801)
      return "assets/img/d2s.png";
    else if (id == 802)
      return "assets/img/d3s.png";
    else if (id == 803 || id == 804)
      return "assets/img/d4s.png";

    print("Unknown condition ${id}");
    return "assets/img/n1s.png";
  }
}