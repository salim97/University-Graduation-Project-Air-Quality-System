import 'package:air_quality_system/datamodels/Forecast_dataModel.dart';
import 'package:http/http.dart' as http;

import 'dart:async';

class RestAPI {
  static RestAPI _instance;

  static RestAPI getInstance() {
    if (_instance == null) {
      _instance = new RestAPI();
    }
    return _instance;
  }


  Future<ForecastDataModel> getForecast() async {
    http.Response response;
    try {
      response = await http.get(Uri.encodeFull(Endpoints.FORECAST_BY_CITY_ID), headers: {"Accept": "application/json"});
    } catch (e) {
      return Future.error(e.toString());
    }

    ForecastDataModel forecastData = ForecastDataModel.fromJson(response.body);
    if (forecastData == null) return Future.error(response.body);
    return forecastData;
  }
}
//2485920
const city_id = "2485920"; // check http://bulk.openweathermap.org/sample/city.list.json.gz
const city_Lat = "35.6987";
const city_Long = "0.6349";
const api_key = "3ca751027abb6d6a232c9e9d87d22a7a";

class Endpoints {
  static const _ENDPOINT = "http://api.openweathermap.org/data/2.5";
  // static const WEATHER = _ENDPOINT + "/weather?lat="+city_Lat+"&lon="+city_Long+"&APPID="+api_key+"&units=metric";
  static const WEATHER_BY_CITY_ID = _ENDPOINT + "/weather?id=" + city_id + "&APPID=" + api_key + "&units=metric";
  // static const FORECAST = _ENDPOINT + "/forecast?lat="+city_Lat+"&lon="+city_Long+"&APPID="+api_key+"&units=metric";
  static const FORECAST_BY_CITY_ID = _ENDPOINT + "/forecast?id=" + city_id + "&APPID=" + api_key + "&units=metric";
}
