import 'dart:convert';

import 'package:http/http.dart' as http;

import 'dart:async';

import 'datamodels/device_dataModel.dart';

class RestAPIService {
  static RestAPIService _instance;

  static RestAPIService getInstance() {
    if (_instance == null) {
      _instance = new RestAPIService();
    }
    return _instance;
  }

  Future<List<DeviceDataModel>> getLast10minRecords() async {
    http.Response response;
    try {
      response = await http.get(Uri.encodeFull(Endpoints.FIREBASE_FUNCTION_GET_LAST_10MIN_RECORDS));
    } catch (e) {
      return Future.error(e.toString());
    }
    print("response.body : "+response.body);
    
    if(response.statusCode != 201) return List<DeviceDataModel>() ;

    print("response.statusCode : "+response.statusCode.toString());
    List<DeviceDataModel> posts = List<DeviceDataModel>();
      JsonDecoder decoder = new JsonDecoder();
      var map = decoder.convert(response.body);

    // Map<String, dynamic> data = jsonDecode(response.body);
    map.forEach((key, value) {
      // print("-----------------------------------");
      //print(element.data);
      if (value == null) return;
      DeviceDataModel s = new DeviceDataModel();
      s.fromJson(value);
      s.timeStamp = value["timestamp"];
      posts.add(s);
    });

    // if (posts == null) return Future.error(response.body);
    posts.removeWhere((value) => value.sensors.isEmpty); // remove devices with no sensor connect on it
    List<DeviceDataModel> unDuplicatedList = List<DeviceDataModel>();
    bool alreadyExist;
    posts.forEach((post) {
      alreadyExist = false;
      unDuplicatedList.forEach((element) {
        if (element.gps.toString() == post.gps.toString()) alreadyExist = true;
      });
      if (!alreadyExist) unDuplicatedList.add(post);
    });
    print(unDuplicatedList.length);
    return unDuplicatedList;
  }


}

class Endpoints {
  static const FIREBASE_FUNCTION_GET_LAST_10MIN_RECORDS = "https://us-central1-pfe-air-quality.cloudfunctions.net/getLast10minRecords";
}
