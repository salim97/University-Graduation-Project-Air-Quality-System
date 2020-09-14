import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

import 'package:injectable/injectable.dart';

/// The service responsible for networking requests
// @lazySingleton
class MyGPSService {


  // Future<void> getMyLocation() async {
  //   Position position = await Geolocator()
  //       .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  //   myLocation = LatLng(position.latitude, position.longitude);
  //   markers.add(
  //     Marker(
  //       width: 60.0,
  //       height: 60.0,
  //       point: myLocation,
  //       builder: (ctx) => Container(
  //         child: Row(
  //           children: <Widget>[
  //             Container(
  //               width: 30.0,
  //               child: Icon(Icons.person_pin_circle),
  //             ),
  //             Container(
  //               child: Text("Pick Up Here"),
  //             )
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  //   notifyListeners();
  //   print(position);
  // }
}