import 'package:air_quality_system/ui/screens/forecast/forecast_model.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:air_quality_system/datamodels/weather/ForecastData.dart';
import 'package:air_quality_system/ui/styles/Res.dart';
import 'package:air_quality_system/ui/widgets/forecast/DotPageIndicator.dart';
import 'package:air_quality_system/ui/widgets/forecast/TextWithExponent.dart';

import 'package:intl/intl.dart';

import 'forecastDetail_view.dart';

final weekdayFormat = new DateFormat('EEE');
final timeFormat = new DateFormat('HH');
final monthFormat = new DateFormat('MMMM');

class ForecastView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ForecastModel>.reactive(
      builder: (context, model, child) => model.isBusy
          ?  Center(child: CircularProgressIndicator())
          : model.hasError
              ? Container(
                  color: Colors.red,
                  alignment: Alignment.center,
                  child: Text(
                    'An error has occered while getting data from server, rest api end point',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : Stack(
                  children: <Widget>[
                    new Container(
                      // child: new ForecastPager(model.forecastByDay),
                      child: new Column(
                        children: <Widget>[
                          new _ForecastWeekTabs(model.currentDateTime, model.currentPage, model.pageCount),
                          new Expanded(
                              child: new PageView.builder(
                            itemBuilder: (BuildContext context, int index) => new ForecastList(model.forecastByDay[index]),
                            itemCount: model.pageCount,
                            scrollDirection: Axis.horizontal,
                            onPageChanged: (index) {
                              model.currentPage = index;
                              model.notifyListeners();
                            },
                          )),
                        ],
                      ),
                      decoration: new BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.rectangle,
                        borderRadius: new BorderRadius.only(
                          topLeft: new Radius.circular(15.0),
                          topRight: new Radius.circular(15.0),
                        ),
                        // boxShadow: <BoxShadow>[
                        //   new BoxShadow(
                        //       color: Colors.black12,
                        //       blurRadius: 10.0,
                        //       offset: new Offset(0.0, -10.0))
                        // ]
                      ),
                    ),
                  ],
                ),

      viewModelBuilder: () => ForecastModel(),
      // TODO: khrebch fiha apre, prc initstate ta3 fluter w hadi custom je pense pas 3andhom meme behavior
      // onModelReady: (model) =>  model.initState(), 
    );
  }
}

class _ForecastWeekTabs extends StatelessWidget {
  final DateTime dateTime;
  final int currentPage;
  final int pageCount;

  _ForecastWeekTabs(this.dateTime, this.currentPage, this.pageCount);

  @override
  Widget build(BuildContext context) {
    final textStyle = new TextStyle(fontSize: 24.0, color: Colors.white);
    String dayMonthSuffix = "";

    var weekDay = weekdayFormat.format(dateTime).toString();
    // final int dayOfMonth = dateTime != null ? dateTime.day : 0;
    // if (dayOfMonth == 1) {
    //   dayMonthSuffix += "st";
    // } else if (dayOfMonth == 2) {
    //   dayMonthSuffix += "nd";
    // } else {
    //   dayMonthSuffix += "th";
    // }

    String dd = DateFormat(' d MMM').format(DateTime.now());
 

    return new Container(
      child: new Container(
        child: new Stack(
          children: <Widget>[
            new Container(
              child: new Text(weekDay, style: textStyle),
              padding: new EdgeInsets.only(left: 36.0),
            ),
            new Align(
              child: new DotPageIndicator(this.currentPage, this.pageCount),
              alignment: FractionalOffset.center,
            ),
            new Positioned(
                child: new TextWithExponent(
                  dd,
                  dayMonthSuffix,
                  textSize: 24.0,
                  exponentTextSize: 18.0,
                ),
                right: 36.0),
          ],
        ),
        padding: new EdgeInsets.symmetric(vertical: 8.0),
      ),
      decoration: new BoxDecoration(border: new Border(bottom: new BorderSide(color: Colors.white))),
    );
  }
}

class ForecastList extends StatelessWidget {
  final List<ForecastWeather> _forecast;

  ForecastList(this._forecast);

  @override
  Widget build(BuildContext context) {
    return new ListView.builder(
      itemBuilder: (BuildContext context, int index) => new _ForecastListItem(_forecast[index]),
      itemCount: _forecast == null ? 0 : _forecast.length,
    );
  }
}

class _ForecastListItem extends StatelessWidget {
  final ForecastWeather weather;

  _ForecastListItem(this.weather);

  void clicked(BuildContext context) {
    Navigator.of(context).push(ForecastDetailView.getRoute(weather));
  }

  @override
  Widget build(BuildContext context) {
    final time = timeFormat.format(weather.dateTime);

    return new InkWell(
        onTap: () => clicked(context),
        child: new Container(
            height: 65.0,
            padding: new EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: new Stack(
              children: <Widget>[
                new Align(
                  child: new TextWithExponent(time, "h"),
                  alignment: FractionalOffset.centerLeft,
                ),
                new Positioned(
                  child: new Row(
                    children: <Widget>[
                       Container(
                        width: 80.0,
                        alignment: FractionalOffset.centerRight,
                        child: new Text(
                          weather.temperature + "°C",
                          style: new TextStyle(fontSize: 20.0, color: Colors.white),
                        ),
                      ),
                      SizedBox(width: 10,),
                       Container(
                        child: new Image.asset(
                          weather.condition.getAssetString(),
                          height: 46.0,
                          width: 46.0,
                          fit: BoxFit.scaleDown,
                          color: $Colors.ghostWhite,
                        ),
                        margin: new EdgeInsets.only(right: 8.0),
                      ),
                    ],
                  ),
                  right: 0.0,
                )
              ],
            )));
  }
}
