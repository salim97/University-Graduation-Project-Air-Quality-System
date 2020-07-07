import 'package:air_quality_system/app/locator.dart';
import 'package:air_quality_system/datamodels/Forecast_dataModel.dart';
import 'package:air_quality_system/services/Rest_API.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class ForecastModel extends FutureViewModel<List<List<ForecastWeatherDataModel>>> {
  final RestAPI restAPIService = locator<RestAPI>();
  List<List<ForecastWeatherDataModel>> forecastByDay = List<List<ForecastWeatherDataModel>>();

  int currentPage = 0;
  int pageCount = 0;
  DateTime currentDateTime;
  // @override
  void initState() async {}

  List<List<ForecastWeatherDataModel>> groupForecastListByDay(ForecastDataModel forecastData) {
    if (forecastData == null) return null;

    List<List<ForecastWeatherDataModel>> forecastListByDay = [];
    final forecastList = forecastData.forecastList;

    int currentDay = forecastList[0].dateTime.day;
    List<ForecastWeatherDataModel> intermediateList = [];

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
  Future<List<List<ForecastWeatherDataModel>>> futureToRun() async {
    await Future.delayed(const Duration(seconds: 1));
    ForecastDataModel forecastData;
    try {
      forecastData = await restAPIService.getForecast();
      this.forecastByDay = groupForecastListByDay(forecastData);
      pageCount = forecastByDay != null ? forecastByDay.length : 0;

      if (forecastByDay != null) {
        if (forecastByDay[currentPage].length > 0) {
          currentDateTime = forecastByDay[currentPage][0].dateTime;
        }
      }

      notifyListeners();
    } catch (e) {
      print(e);
      errorMSG = error.toString();
      notifyListeners();
      // throw Exception(e.toString());
      return Future.error(e.toString());
      // throw UnimplementedError();
    }

    return forecastByDay;
  }

  String errorMSG = "";
  @override
  void onError(error) {
    print("  void onError(error) {" + error.toString());
    errorMSG = error.toString();
    notifyListeners();
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
