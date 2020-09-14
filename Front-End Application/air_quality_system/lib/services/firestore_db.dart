import 'package:air_quality_system/datamodels/device_dataModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io' show Platform;

import 'package:injectable/injectable.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// The service responsible for networking requests
// @lazySingleton
class MyFirestoreDBService {
  // static const endpoint = 'https://jsonplaceholder.typicode.com';

  // var client = new http.Client();
  var client;

  // Future<User> getUserProfile(int userId) async {
  //   var response = await client.get('$endpoint/users/$userId');
  //   return User.fromJson(json.decode(response.body));
  // }

  Future<List<DeviceDataModel>> getLastdata() async {
    List<DeviceDataModel> posts = List<DeviceDataModel>();
    QuerySnapshot docs = await Firestore.instance
        .collection("Records")
        .where("timestamp", isGreaterThan: 1594399926478)
        .orderBy('timestamp', descending: true)
        .getDocuments();

    docs.documents.forEach((element) {
      // print("-----------------------------------");
      //print(element.data);
      if (element.data == null) return;
      DeviceDataModel s = new DeviceDataModel();

      s.fromJson(element.data);
      s.timeStamp = element.data["timestamp"];

      // print(s.dht22.temperature.value);
      posts.add(s);
    });

    posts.removeWhere((value) => value.sensors.isEmpty); // remove devices with no sensor connect on it
    List<DeviceDataModel> unDuplicatedList = List<DeviceDataModel>();
    bool alreadyExist ;
    posts.forEach((post) {
      alreadyExist = false ;
      unDuplicatedList.forEach((element) {
          if(element.gps.toString() == post.gps.toString() ) alreadyExist = true;
      });
      if(!alreadyExist)unDuplicatedList.add(post);
    });
    print(unDuplicatedList.length);
    return unDuplicatedList;
  }
}
