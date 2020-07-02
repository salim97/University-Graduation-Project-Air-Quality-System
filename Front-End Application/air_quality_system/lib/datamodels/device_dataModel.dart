import 'package:air_quality_system/datamodels/GPS_dataModel.dart';

import 'sensor_datamodel.dart';

class DeviceDataModel {
  String upTime;
  String timeStamp;
  List<SensorDataModel> sensors = new List<SensorDataModel>();
  GPSDataModel gps;
  fromJson(Map<dynamic, dynamic> json) {
    sensors.clear();
    sensors.add(new SensorDataModel.fromJson(json, "DHT22"));
    sensors.add(new SensorDataModel.fromJson(json, "BME680"));
    sensors.add(new SensorDataModel.fromJson(json, "MHZ19"));
    sensors.add(new SensorDataModel.fromJson(json, "SGP30"));
    sensors.add(new SensorDataModel.fromJson(json, "MICS6814"));
    gps = new GPSDataModel().fromJson(json);
    sensors.removeWhere((value) => value == null); // remove non existing sensors
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
