
import 'dart:io';

import 'package:air_quality_system/app/locator.dart';
import 'package:air_quality_system/datamodels/device_dataModel.dart';
import 'package:air_quality_system/services/firebase_auth.dart';
import 'package:air_quality_system/services/firestore_db.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:stacked/stacked.dart';
import 'package:latlong/latlong.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:udp/udp.dart';

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
  final DialogService _dialogService = locator<DialogService>();
  // final SnackbarService _snackbarService = locator<SnackbarService>();
  // final NavigationService _navigationService = locator<NavigationService>();

  // @override
  void initState() async {
    print("=================== initState ");

    // getMyLocation();
    // print(firebaseAuthService.firebaseUser?.uid);
    // print(firebaseAuthService.isUserConnectedToFirebase);
    // // await firebaseAuthService.signInAnonymously();

    // print(firebaseAuthService.firebaseUser.uid);
    // print(firebaseAuthService.isUserConnectedToFirebase);

    dropDownMenuItems = getDropDownMenuItems();
    currentGas = _gas.keys.first;
    currentGasLegend = _gas.values.first;

    notifyListeners();
  }

  refresh() async {
    // await firebaseAuthService.signInAnonymously();
    // return;
    List<DeviceDataModel> list = await myFirestoreDBservice.getLastdata();
    DeviceDataModel tmp = list.first;
    markers.clear();
    // print(tmp.dht22.temperature.value);
    String temperature ; 

    tmp.sensors.forEach((sensor) {
      sensor.senses.forEach((sense) {
        if(sense.symbol == "°C" )
        {
          temperature = sense.value;
        } 

      });
    });

    markers.add(addMarker(
        text: temperature,
        point: LatLng(tmp.gps.latitude, tmp.gps.longitude),
        color: legendTemperature(double.parse(temperature).toInt())));

    print(Colors.blue);
    print(Colors.green);
    print(Colors.yellow);
    print(Colors.red);

    // await _dialogService.showDialog(
    //   title: 'Test Dialog Title',
    //   description: 'Test Dialog Description',
    //   dialogPlatform: DialogPlatform.Material,
    // );

// _snackbarService.showSnackbar(title: "khra", message: "zbel", iconData: Icons.ac_unit);
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

  addMarker({point, color, text}) {
    return Marker(
      width: 60.0,
      height: 60.0,
      point: point,
      builder: (ctx) => Container(
        child: Stack(
          children: <Widget>[
            Opacity(
              opacity: 0.6,
              child: Image.asset(
                "assets/images/shape_hexagon.png",
                width: 60.0,
                height: 60.0,
                color: color,
              ),
            ),
            Center(
              child: Text(text),
            )
          ],
        ),
      ),
    );
  }

  var _gas = {
    'Temperature': 'assets/images/legend_Temperature.png',
    'Humidity': 'assets/images/legend_Humidity.png',
    'Pressure': 'assets/images/legend_Pressure.png',
    'AQI': 'assets/images/legend_AQI.png',
  };
  List<DropdownMenuItem<String>> dropDownMenuItems;
  String currentGas, currentGasLegend;

  void changedDropDownItem(String selectedGas) {
    // print("Selected city $selectedCity, we are going to refresh the UI");
    currentGas = selectedGas;
    currentGasLegend = _gas[selectedGas];
    notifyListeners();
  }

  List<DropdownMenuItem<String>> getDropDownMenuItems() {
    List<DropdownMenuItem<String>> items = new List();
    for (String g in _gas.keys) {
      items.add(new DropdownMenuItem(value: g, child: new Text(g)));
    }
    return items;
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
    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
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
