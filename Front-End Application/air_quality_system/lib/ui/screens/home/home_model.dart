import 'package:air_quality_system/app/locator.dart';
import 'package:air_quality_system/datamodels/all_sensors_model.dart';
import 'package:air_quality_system/services/firebase_auth.dart';
import 'package:air_quality_system/services/firestore_db.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:stacked/stacked.dart';
import 'package:latlong/latlong.dart';
import 'package:stacked_services/stacked_services.dart';

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

  final MyFirebaseAuth firebaseAuthService = locator<MyFirebaseAuth>();
  final MyFirestoreDB myFirestoreDBservice = locator<MyFirestoreDB>();
  // final DialogService _dialogService = locator<DialogService>();
  // final NavigationService _navigationService = locator<NavigationService>();

  // @override
  void initState() async {
    print("=================== initState ");
    // getMyLocation();
    print(firebaseAuthService.firebaseUser?.uid);
    print(firebaseAuthService.isUserConnectedToFirebase);
    await firebaseAuthService.signInAnonymously();
    print(firebaseAuthService.firebaseUser.uid);
    print(firebaseAuthService.isUserConnectedToFirebase);

    notifyListeners();
  }

  refresh() async {
    List<All_Sensors> list = await myFirestoreDBservice.getLastdata();
    All_Sensors tmp = list.first;
    markers.clear();
    print(tmp.dht22.temperature.value);

    print(legendTemperature(25));

    markers.add(addMarker(
        point: LatLng(tmp.gps.latitude, tmp.gps.longitude),
        // color: legendTemperature(double.parse(tmp.dht22.temperature.value).toInt())));
        color: legendTemperature(-20)));

    print(Colors.blue);
    print(Colors.green);
    print(Colors.yellow);
    print(Colors.red);

    notifyListeners();
  }

  Color legendTemperature(int temp) {
    Color a, b;
    if (temp >= 40) return Colors.red;
    if (temp <= -20) return Colors.blue;

    if (temp >= 20 && temp < 40) {
      a = Colors.yellow;
      b = Colors.red;
      temp -= 20;
    } else if (temp >= 0 && temp < 20) {
      a = Colors.green;
      b = Colors.yellow;
      temp -= 0;
    } else if (temp >= -20 && temp < 0) {
      a = Colors.blue;
      b = Colors.green;
      temp += 20;
    }

    return Color.lerp(a, b, temp / 20);
  }

  addMarker({point, color}) {
    return Marker(
      width: 60.0,
      height: 60.0,
      point: point,
      builder: (ctx) => Container(
        child: Opacity(
          opacity: 0.6,
          child: Image.asset(
            "assets/images/shape_hexagon.png",
            width: 60.0,
            height: 60.0,
            color: color,
          ),
        ),
      ),
    );
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
