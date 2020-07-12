import 'dart:collection';

import 'package:air_quality_system/datamodels/GPS_dataModel.dart';

import 'sensor_datamodel.dart';

class DeviceDataModel {
  String upTime;
  int timeStamp;
  List<SensorDataModel> sensors = new List<SensorDataModel>();
  GPSDataModel gps;

  fromJson(Map<dynamic, dynamic> json) {
    // sensors.clear();

    List<dynamic> list = json["Sensors"];
    list.forEach((element) {
      bool alreadyExist = false;
      SensorDataModel newElement = SensorDataModel.fromJson(element);
      for (int i = 0; i < sensors.length; i++) {
        if (newElement.uid() == sensors[i].uid()) {
          sensors[i].value = newElement.value;
          sensors[i].values.add(newElement.value);
          sensors[i].updateTimeStamp();
          alreadyExist = true;
        }
      }
      if (!alreadyExist) sensors.add(newElement);
    });
    gps = new GPSDataModel.fromJson(json);
    // sensors.removeWhere((value) => value.senses.isEmpty); // remove non existing sensors
  }

  removeNULLmetric() {
    sensors.removeWhere((value) => value.metric == null); // remove non existing sensors
  }

  Map<String, List<SensorDataModel>> regroupSensorsByName() {
    Map<String, List<SensorDataModel>> newSensors = new Map<String, List<SensorDataModel>>();

    List<String> arr = List<String>();
    sensors.forEach((element) {
      arr.add(element.sensorName);
    });
    List<String> result = LinkedHashSet<String>.from(arr).toList();
    result.forEach((element) {
      newSensors[element] = List<SensorDataModel>();
      sensors.forEach((sensor) {
        if (sensor.sensorName == element) {
          newSensors[element].add(sensor);
        }
      });
    });
    return newSensors;
  }

  List<SensorDataModel> getTemperature() {
    List<SensorDataModel> metricDataModel = new List<SensorDataModel>();

    sensors.forEach((sensor) {
      if (sensor.metric == "°C") {
        sensor.value = double.parse(sensor.value).toStringAsFixed(1);
        metricDataModel.add(sensor);
      }
    });

    return metricDataModel;
  }

  List<SensorDataModel> getHumidity() {
    List<SensorDataModel> metricDataModel = new List<SensorDataModel>();

    sensors.forEach((sensor) {
      if (sensor.metric == "%") {
        sensor.value = double.parse(sensor.value).toStringAsFixed(1);
        metricDataModel.add(sensor);
      }
    });

    return metricDataModel;
  }

  List<SensorDataModel> getPressure() {
    List<SensorDataModel> metricDataModel = new List<SensorDataModel>();

    sensors.forEach((sensor) {
      if (sensor.metric != null) if (sensor.metric.toLowerCase() == "hpa") {
        sensor.value = double.parse(sensor.value).toStringAsFixed(1);
        metricDataModel.add(sensor);
      }
    });

    return metricDataModel;
  }

  List<SensorDataModel> getCO2() {
    List<SensorDataModel> metricDataModel = new List<SensorDataModel>();

    sensors.forEach((sensor) {
      if (sensor.metric != null) if (sensor.metricName.toLowerCase() == "co2") {
        sensor.value = double.parse(sensor.value).toStringAsFixed(1);
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
