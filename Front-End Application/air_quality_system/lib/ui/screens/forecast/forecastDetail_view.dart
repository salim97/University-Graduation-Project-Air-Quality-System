import 'package:air_quality_system/datamodels/weather/ForecastData.dart';
import 'package:air_quality_system/ui/styles/Res.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final monthFormat = new DateFormat('MMMM');

class ForecastDetailView extends StatelessWidget {
  final ForecastWeather weather;

  ForecastDetailView(this.weather);

  static MaterialPageRoute getRoute(ForecastWeather forecastWeather) {
    return new MaterialPageRoute(builder: (BuildContext context) {
      return new ForecastDetailView(forecastWeather);
    });
  }

  @override
  Widget build(BuildContext context) {
    var title = weather.dateTime.hour.toString() + "h";
    var month = monthFormat.format(weather.dateTime);
    title += " • " + weather.dateTime.day.toString() + " " + month;

    return new Scaffold(
      appBar: new AppBar(title: new Text(title)),
      body: new Container(
          decoration: new BoxDecoration(
              gradient: new LinearGradient(
                  colors: [
                    const Color(0x99338600),
                    const Color(0x9900CCFF),
                    const Color(0xAA0077FF),
                  ],
                  begin: const FractionalOffset(0.0, 0.0),
                  end: const FractionalOffset(0.7, 1.0),
                  stops: [0.0, 0.7, 1.0],
                  tileMode: TileMode.clamp)),
          child: new Center(
            child: Container(
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                      child: new Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                        new Image.asset(
                          this.weather.condition.getAssetString(),
                          width: 50.0,
                          color: $Colors.blueParis,
                        ),
                        new Padding(
                          padding: new EdgeInsets.only(left: 16.0),
                          child: new Text(
                            this.weather.condition.description,
                            style: new TextStyle(fontSize: 32.0),
                          ),
                        )
                      ])),
                  new Container(
                    margin: const EdgeInsets.all(20.0),
                    height: 1.0,
                    width: 220.0,
                    color: Colors.black45,
                  ),
                  weatherInfo(weather.wind.toString() +" km/h", $Asset.wind),
                  weatherInfo(weather.pressure.toString() + " hpa", $Asset.pressure),
                  weatherInfo(weather.humidity.toString() + " %", $Asset.humidity),
                  // weatherInfo(weather..toString() + " ", $Asset.humidity),
                ],
              ),
            ),
          )),
    );
  }

  weatherInfo(info, imageAsset) {
    return new Container(
        child: new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new Image.asset(
          imageAsset,
          width: 30.0,
          color: $Colors.blueParis,
        ),
        new Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 12.0, top: 12.0),
          child: new Text(
            info,
            style: new TextStyle(fontSize: 20.0),
          ),
        )
      ],
    ));
  }
}
