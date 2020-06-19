
import 'package:air_quality_system/app/locator.dart';
import 'package:air_quality_system/services/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:stacked/stacked.dart';
import 'package:latlong/latlong.dart';

// class HomeViewModel extends FutureViewModel<void> {
class HomeViewModel extends BaseViewModel {
  LatLng myLocation;
  List<Marker> markers = [
    Marker(
      width: 60.0,
      height: 60.0,
      point: LatLng(35.693938, -0.627546),
      builder: (ctx) => Container(
        child: Opacity(
          opacity: 0.6,
          child: Image.asset(
            "assets/images/shape_hexagon.png",
            width: 60.0,
            height: 60.0,
            color: Colors.red,
          ),
        ),
      ),
    ),
    Marker(
      width: 60.0,
      height: 60.0,
      point: LatLng(35.691960, -0.622479),
      builder: (ctx) => Container(
        child: Opacity(
          opacity: 0.6,
          child: Image.asset(
            "assets/images/shape_hexagon.png",
            width: 60.0,
            height: 60.0,
            color: Colors.red,
          ),
        ),
      ),
    ),
    Marker(
      width: 60.0,
      height: 60.0,
      point: LatLng(35.689407, -0.625174),
      builder: (ctx) => Container(
        child: Opacity(
          opacity: 0.6,
          child: Image.asset(
            "assets/images/shape_hexagon.png",
            width: 60.0,
            height: 60.0,
            color: Colors.red,
          ),
        ),
      ),
    )
  ];
  
  final MyFirebaseAuth _firebaseAuthService = locator<MyFirebaseAuth>();

  // @override
  void initState() {
    print("=================== initState ");
    // getMyLocation();
    _firebaseAuthService.signInAnonymously();
  }

  // @override
  // Future<void> futureToRun()  {
  //     getDataFromServer();
     
  // }

  // Future<void> getDataFromServer() async {
  //   await Future.delayed(const Duration(seconds: 3));
  //   throw Exception('This is an error');
  // }

  @override
  void onError(error) {
    // error thrown above will be sent here
    // We can show a dialog, set the error message to show on the UI
    // the UI will be rebuilt after this is called so you can set properties.
  }

  Future<void> getMyLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    myLocation = LatLng(position.latitude, position.longitude);
    markers.add(
      Marker(
        width: 60.0,
        height: 60.0,
        point: myLocation,
        builder: (ctx) => Container(
          child: Row(
            children: <Widget>[
              Container(
                width: 30.0,
                child: Icon(Icons.person_pin_circle),
              ),
              Container(
                child: Text("Pick Up Here"),
              )
            ],
          ),
        ),
      ),
    );
    notifyListeners();
    print(position);
  }



}
