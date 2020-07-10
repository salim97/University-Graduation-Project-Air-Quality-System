import 'package:air_quality_system/datamodels/GPS_dataModel.dart';

import 'sensor_datamodel.dart';

class DeviceDataModel {
  String upTime;
  int timeStamp;
  List<SensorDataModel> sensors = new List<SensorDataModel>();
  GPSDataModel gps;
  fromJson(Map<dynamic, dynamic> json) {
    sensors.clear();
    List<dynamic> list = json["Sensors"];
    list.forEach((element) {
      sensors.add(new SensorDataModel.fromJson(element));
    });
    gps = new GPSDataModel.fromJson(json);
    // sensors.removeWhere((value) => value.senses.isEmpty); // remove non existing sensors
  }
  removeNULLmetric()
  {
    sensors.removeWhere((value) => value.metric == null); // remove non existing sensors
  }
  List<SensorDataModel> getTemperature() {
    List<SensorDataModel> metricDataModel = new List<SensorDataModel>();

    sensors.forEach((sensor) {
      if (sensor.metric == "°C") {
        metricDataModel.add(sensor);
      }
    });

    return metricDataModel;
  }

  List<SensorDataModel> getHumidity() {
    List<SensorDataModel> metricDataModel = new List<SensorDataModel>();

    sensors.forEach((sensor) {
      if (sensor.metric == "%") {
        metricDataModel.add(sensor);
      }
    });

    return metricDataModel;
  }

// system_get_chip_id()
// ESP.getChipId()
  // String name;
  // String timestamp;
  // List<Sense> sensors;
  // bool expanded = true ;
  // Device({
  //   this.name,
  //   this.sensors,
  // }){
  // setCurrentTime();
  // }
  // setCurrentTime()
  // {
  //     timestamp = DateFormat('kk:mm:ss').format(DateTime.now());
  // }
  // String formattedDate() {
  //   return "${DateFormat.yMd().format(this.timestamp)} ${DateFormat.jm().format(this.timestamp)}";
  // }

  // factory Device.fromSnapshot(DataSnapshot snapshot) {
  //   return Device(
  //     name: snapshot.key,
  //     timestamp: snapshot.value['timestamp'],
  //     temperature: snapshot.value['temperature'],
  //     humidity: snapshot.value['humidity'],
  //     airQuality: snapshot.value['air_quality'],
  //     methane: snapshot.value['methane'],
  //     airQualityPPM: snapshot.value['air_quality_ppm'],
  //     methanePPM: snapshot.value['methane_ppm'],
  //   );
  // }
}
