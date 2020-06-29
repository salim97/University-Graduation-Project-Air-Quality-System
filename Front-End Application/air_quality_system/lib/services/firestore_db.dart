import 'package:air_quality_system/datamodels/all_sensors_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

import 'package:injectable/injectable.dart';

/// The service responsible for networking requests
// @lazySingleton
class MyFirestoreDB {
  // static const endpoint = 'https://jsonplaceholder.typicode.com';

  // var client = new http.Client();
  var client;

  // Future<User> getUserProfile(int userId) async {
  //   var response = await client.get('$endpoint/users/$userId');
  //   return User.fromJson(json.decode(response.body));
  // }

  Future<List<All_Sensors>> getLastdata() async {
    var posts = List<All_Sensors>();
    QuerySnapshot docs = await Firestore.instance
        .collection("contacts")
        .where("timestamp", isGreaterThan: 1592676909333)
        .orderBy('timestamp', descending: true)
        .getDocuments();
    docs.documents.forEach((element) {
      // print("-----------------------------------");
      //print(element.data);

      var s = new All_Sensors();
      // s.dht22.temperature =new
      //     Sensor.fromJson(element.data["DHT22"]["Temperature"]);
      s.dht22.fromJson(element.data);
      s.mics6814.fromJson(element.data);
      s.sgp30.fromJson(element.data);
      s.mhz19.fromJson(element.data);
      s.bme680.fromJson(element.data);
      s.gps.fromJson(element.data);
      s.timestamp = element.data["timestamp"];

      // print(s.dht22.temperature.value);
      posts.add(s);
    });
    return posts;
  }
}
