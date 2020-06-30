import 'metric_datamodel.dart';
import 'package:intl/intl.dart';

class SensorDataModel {
  String name;
  List<MetricDataModel> senses = new List<MetricDataModel>();
  String timeStamp;
  SensorDataModel({this.name, this.senses});

  SensorDataModel.fromJson(Map<String, dynamic> json, String name) {
    this.name = name;
    this.timeStamp = DateFormat('kk:mm:ss').format(DateTime.now());
    if (json[name] == null) return;
    senses.clear();
    Map<String, dynamic> t = json[name];
    t.forEach((key, value) {
      if (value["isCalibrated"] == null) return;
      if (value["type"] == null) return;
      if (value["value"] == null) return;
      senses.add(new MetricDataModel.fromJson(value, key));
    });
  }
}