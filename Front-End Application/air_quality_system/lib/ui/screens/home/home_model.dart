import 'dart:io';

import 'package:air_quality_system/app/locator.dart';
import 'package:air_quality_system/datamodels/device_dataModel.dart';
import 'package:air_quality_system/services/firebase_auth.dart';
import 'package:air_quality_system/services/firestore_db.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:stacked/stacked.dart';
import 'package:latlong/latlong.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:udp/udp.dart';

// class HomeViewModel extends FutureViewModel<void> {
class HomeViewModel extends BaseViewModel {
  LatLng myLocation;
  List<Marker> markers = List<Marker>();

  final MyFirebaseAuth firebaseAuthService = locator<MyFirebaseAuth>();
  final MyFirestoreDB myFirestoreDBservice = locator<MyFirestoreDB>();
  final DialogService _dialogService = locator<DialogService>();
  // final SnackbarService _snackbarService = locator<SnackbarService>();
  // final NavigationService _navigationService = locator<NavigationService>();
  MapController mapController = new MapController();

  var gas = {
    'Temperature': MdiIcons.whiteBalanceSunny,
    'Humidity': MdiIcons.waterPercent,
    'Pressure': MdiIcons.arrowCollapseVertical,
    'AQI': MdiIcons.molecule,
  };

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
    refresh();
    notifyListeners();
  }

  onCurrentSearchChanged(String item) {
    print(item);
    if(item == "Temperature") refresh(sensor: item);
    if(item == "Humidity") refresh(sensor: item);
  }

  refresh({String sensor = "Temperature"}) async {
    // await firebaseAuthService.signInAnonymously();
    // return;
    List<DeviceDataModel> list = await myFirestoreDBservice.getLastdata();

    markers.clear();
    List<LatLng> points = new List<LatLng>();

    list.forEach((element) {
      points.add(LatLng(element.gps.latitude, element.gps.longitude));
      String value = "NULL";
      String symbol = "" ;
      if (sensor == "Temperature") {
        value = element.getTemperature().first.value ;
        symbol = element.getTemperature().first.symbol ;
      }
      if (sensor == "Humidity") {
        value = element.getHumidity().first.value;
        symbol = element.getHumidity().first.symbol;
      }
      markers.add(addMarker(text: value+symbol, point: points.last, color: legendTemperature(double.parse(value).toInt())));
    });

    LatLngBounds llb = new LatLngBounds.fromPoints(points);

    mapController.fitBounds(llb, options: FitBoundsOptions(padding: EdgeInsets.all(50.0)));

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
              child: Text(text, style: TextStyle( fontSize: 14.0)),
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
    // await _dialogService.showDialog(
    //   title: 'Test Dialog Title',
    //   description: 'Test Dialog Description',
    //   dialogPlatform: DialogPlatform.Material,
    // );

// _snackbarService.showSnackbar(title: "khra", message: "zbel", iconData: Icons.ac_unit);
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
