import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class MetricDataModel {
  String value;
  String symbol;
  String name;
  // String timeStamp;
  bool isCalibrated;

  MetricDataModel({this.name, this.value, this.symbol, this.isCalibrated});

  factory MetricDataModel.fromJson(Map<dynamic, dynamic> json, String metricName) {
    return MetricDataModel()
      ..name = metricName
      ..value = json['value'].toString()
      ..symbol = json['type'] as String
      ..isCalibrated = json['isCalibrated'] as bool;
  }

  IconData getIcon() {
    IconData icon = MdiIcons.molecule; //white-balance-sunny
    if (symbol == "°C") icon = MdiIcons.whiteBalanceSunny; //white-balance-sunny
    if (symbol == "%") icon = MdiIcons.waterPercent; //white-balance-sunny
    if (symbol.toLowerCase() == "hpa") icon = MdiIcons.arrowCollapseVertical; //white-balance-sunny
    if (symbol.toLowerCase() == "ppm" && name.toLowerCase().contains("co")) icon = MdiIcons.moleculeCo; //white-balance-sunny
    if (symbol.toLowerCase() == "ppm" && name.toLowerCase().contains("co2")) icon = MdiIcons.moleculeCo2; //white-balance-sunny
    return icon;
  }
}