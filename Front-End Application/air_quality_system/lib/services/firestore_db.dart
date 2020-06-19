import 'package:air_quality_system/datamodels/all_sensors_model.dart';
import 'dart:convert';

import 'package:injectable/injectable.dart';

/// The service responsible for networking requests
@lazySingleton
class MyFirestoreDB {
  // static const endpoint = 'https://jsonplaceholder.typicode.com';

  // var client = new http.Client();
  var client ;

  // Future<User> getUserProfile(int userId) async {
  //   var response = await client.get('$endpoint/users/$userId');
  //   return User.fromJson(json.decode(response.body));
  // }

  Future<List<All_Sensors>> getPostsForUser(int userId) async {
    var posts = List<All_Sensors>();


    return posts;
  }


}