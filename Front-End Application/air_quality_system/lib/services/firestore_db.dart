import 'package:air_quality_system/datamodels/device_dataModel.dart';
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

  Future<List<DeviceDataModel>> getLastdata() async {
    var posts = List<DeviceDataModel>();
    QuerySnapshot docs = await Firestore.instance
        .collection("contacts")
        .where("timestamp", isGreaterThan: 1592676909333)
        .orderBy('timestamp', descending: true)
        .getDocuments();
    docs.documents.forEach((element) {
      // print("-----------------------------------");
      //print(element.data);

      DeviceDataModel s;
      s.fromJson(element.data);
      s.timeStamp = element.data["timestamp"];

      // print(s.dht22.temperature.value);
      posts.add(s);
    });
    return posts;
  }
}
