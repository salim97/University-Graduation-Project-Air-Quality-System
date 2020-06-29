import 'package:intl/intl.dart';
import 'sense_model.dart';

class Device {
  String name;
  String timestamp;
  List<Sense> sensors;
  bool expanded = true ;
  Device({
    this.name,
    this.sensors,
  }){
  setCurrentTime();
  }
  setCurrentTime()
  {
      timestamp = DateFormat('kk:mm:ss').format(DateTime.now());
  }
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
