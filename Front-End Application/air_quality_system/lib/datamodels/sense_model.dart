class Sense {
  String name;
  num value;
  String unit;
  bool isCalibrated;
  
  Sense({this.name, this.value, this.unit, this.isCalibrated});

  factory Sense.fromJson(Map<dynamic, dynamic> json, String metricName) {
    return Sense()
      ..name = metricName
      ..value = json['value'] as num
      ..unit = json['type'] as String
      ..isCalibrated = json['isCalibrated'] as bool;
  }
}
