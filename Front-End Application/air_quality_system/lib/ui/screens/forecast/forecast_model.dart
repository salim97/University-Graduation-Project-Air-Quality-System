import 'package:air_quality_system/app/locator.dart';
import 'package:air_quality_system/datamodels/weather/ForecastData.dart';
import 'package:air_quality_system/services/Rest_API.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class ForecastModel extends FutureViewModel<List<List<ForecastWeather>>> {
  final RestAPI restAPIService = locator<RestAPI>();
  List<List<ForecastWeather>> forecastByDay = List<List<ForecastWeather>>();

  int currentPage = 0;
  int pageCount = 0;
  DateTime currentDateTime;
  // @override
  void initState() async {}

  List<List<ForecastWeather>> groupForecastListByDay(ForecastData forecastData) {
    if (forecastData == null) return null;

    List<List<ForecastWeather>> forecastListByDay = [];
    final forecastList = forecastData.forecastList;

    int currentDay = forecastList[0].dateTime.day;
    List<ForecastWeather> intermediateList = [];

    for (var forecast in forecastList) {
      if (currentDay == forecast.dateTime.day) {
        intermediateList.add(forecast);
      } else {
        forecastListByDay.add(intermediateList);
        currentDay = forecast.dateTime.day;
        intermediateList = [];
        intermediateList.add(forecast);
      }
    }

    forecastListByDay.add(intermediateList);
    return forecastListByDay;
  }

  @override
  Future<List<List<ForecastWeather>>> futureToRun() async {
    await Future.delayed(const Duration(seconds: 1));
    await restAPIService.getForecast().then((content) {
      ForecastData forecastData = content;
      this.forecastByDay = groupForecastListByDay(forecastData);
      pageCount = forecastByDay != null ? forecastByDay.length : 0;

      if (forecastByDay != null) {
        if (forecastByDay[currentPage].length > 0) {
          currentDateTime = forecastByDay[currentPage][0].dateTime;
        }
      }

       notifyListeners();
    }).catchError((e) {
      print(e);
      throw Exception(e.toString());
      // throw UnimplementedError();
    });
    return forecastByDay;
  }

  @override
  void onError(error) {
    // error thrown above will be sent here
    // We can show a dialog, set the error message to show on the UI
    // the UI will be rebuilt after this is called so you can set properties.
    // await _dialogService.showDialog(
    //   title: 'Test Dialog Title',
    //   description: 'Test Dialog Description',
    //   dialogPlatform: DialogPlatform.Material,
    // );

// _snackbarService.showSnackbar(title: "khra", message: "zbel", iconData: Icons.ac_unit);
  }
}
