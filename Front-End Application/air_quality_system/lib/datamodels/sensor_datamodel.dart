import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:intl/intl.dart';

class SensorDataModel {
    String value;
  String metric;
  String name;
  bool isCalibrated;
  String timeStamp;
  
  SensorDataModel({this.name, this.value, this.metric, this.isCalibrated}){
    this.timeStamp = DateFormat('kk:mm:ss').format(DateTime.now());
  }
 
  factory SensorDataModel.fromJson(Map<dynamic, dynamic> json) {
    return SensorDataModel()
      ..name = json['name'] as String
      ..value = json['value'].toString()
      ..metric = json['metric'] as String
      ..isCalibrated = json['isCalibrated'] as bool;
  }

  IconData getIcon() {
    IconData icon = MdiIcons.molecule; //white-balance-sunny
    if (metric == "°C") icon = MdiIcons.whiteBalanceSunny; //white-balance-sunny
    if (metric == "%") icon = MdiIcons.waterPercent; //white-balance-sunny
    if (metric.toLowerCase() == "hpa") icon = MdiIcons.arrowCollapseVertical; //white-balance-sunny
    if (metric.toLowerCase() == "ppm" && name.toLowerCase().contains("co")) icon = MdiIcons.moleculeCo; //white-balance-sunny
    if (metric.toLowerCase() == "ppm" && name.toLowerCase().contains("co2")) icon = MdiIcons.moleculeCo2; //white-balance-sunny
    return icon;
  }


}