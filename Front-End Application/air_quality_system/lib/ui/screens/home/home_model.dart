import 'dart:async';
import 'dart:io';

import 'package:air_quality_system/app/locator.dart';
import 'package:air_quality_system/datamodels/device_dataModel.dart';
import 'package:air_quality_system/services/Rest_API.dart';
import 'package:air_quality_system/services/firebase_auth.dart';
import 'package:air_quality_system/services/firestore_db.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:geolocator/geolocator.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:stacked/stacked.dart';
import 'package:latlong/latlong.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:udp/udp.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// class HomeViewModel extends FutureViewModel<void> {
class HomeViewModel extends BaseViewModel {
  LatLng myLocation;
  List<Marker> markers = List<Marker>();
  double _mapZoom = 14.0;
  MapController mapController = new MapController();

  final MyFirebaseAuthService firebaseAuthService = locator<MyFirebaseAuthService>();
  final RestAPIService restAPIService = locator<RestAPIService>();
  final MyFirestoreDBService myFirestoreDBservice = locator<MyFirestoreDBService>();
  final DialogService _dialogService = locator<DialogService>();
  // final SnackbarService _snackbarService = locator<SnackbarService>();
  // final NavigationService _navigationService = locator<NavigationService>();

  var gas = {
    'Temperature': MdiIcons.whiteBalanceSunny,
    'Humidity': MdiIcons.waterPercent,
    'Pressure': MdiIcons.arrowCollapseVertical,
    'CO2': MdiIcons.molecule,
    'CO': MdiIcons.molecule,
    'NH3': MdiIcons.molecule,
    'NO2': MdiIcons.molecule,
    'O3': MdiIcons.molecule,
  };
  int gas_legend_index = 0;
  var gas_legend = {
    'Temperature': "assets/images/legend_Temperature.png",
    'Humidity': "assets/images/legend_Humidity.png",
    'Pressure': "assets/images/legend_Pressure.png",
  };

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool isInternetAvailable = true;
  // @override
  void initState() async {
    print("=================== initState ");
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      switch (result) {
        case ConnectivityResult.wifi:
          isInternetAvailable = true;
          break;
        case ConnectivityResult.mobile:
          isInternetAvailable = true;
          break;
        case ConnectivityResult.none:
          isInternetAvailable = false;
          break;
        default:
          isInternetAvailable = true;
          break;
      }
      notifyListeners();
    });

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
    // markers.add(addMarker(text: "80 \n %", point: LatLng(35.698272, -0.645404), color: legendHumidity(80), otherSensors: null));
    // markers.add(addMarker(text: "74 \n %", point: LatLng(35.687118, -0.636821), color: legendHumidity(74), otherSensors: null));
    // markers.add(addMarker(text: "94 \n %", point: LatLng(35.706357, -0.625834), color: legendHumidity(95), otherSensors: null));
    // markers.add(addMarker(text: "76 \n %", point: LatLng(35.688791, -0.629268), color: legendHumidity(76), otherSensors: null));
    gas_legend_index = 1 ;
    notifyListeners();
  }

  onCurrentSearchChanged(String item) {
    print(item);
    refresh(sensor: item);
    // if (item == "Temperature") refresh(sensor: item);
    // if (item == "Humidity") refresh(sensor: item);
    // if (item == "Pressure") refresh(sensor: item);
  }

  bool loadingDataFromBackend = false;
  refresh({String sensor = "Temperature"}) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return;
    }

    // await firebaseAuthService.signInAnonymously();
    // return;
    loadingDataFromBackend = true;
    notifyListeners();
    List<DeviceDataModel> list;
    // if (kIsWeb)
    list = await restAPIService.getLast10minRecords();
    // else
    // list = await myFirestoreDBservice.getLastdata();

    loadingDataFromBackend = false;
    notifyListeners();

    markers.clear();
    List<LatLng> points = new List<LatLng>();

    list.forEach((element) {
      String value = "NULL";
      String symbol = "";
      try {
        gas_legend_index = gas_legend.length;
        if (sensor == "Temperature") {
          value = element.getTemperature().first.value;
          symbol = element.getTemperature().first.metric;
          gas_legend_index = 0;
        }
        if (sensor == "Humidity") {
          value = element.getHumidity().first.value;
          symbol = element.getHumidity().first.metric;
          gas_legend_index = 1;
        }
        if (sensor == "Pressure") {
          value = element.getPressure().first.value;
          symbol = element.getPressure().first.metric;
          gas_legend_index = 2;
        }
        if (sensor == "CO2") {
          value = element.getCO2().first.value;
          symbol = element.getCO2().first.metric;
        }
      } catch (e) {
        print(e.toString());
        return;
      }
      if (value == "NULL") return;
      points.add(LatLng(element.gps.latitude, element.gps.longitude));
      if (sensor == "Temperature")
        markers.add(addMarker(
            text: value + "\n" + symbol, point: points.last, color: legendTemperature(double.parse(value).toInt()), otherSensors: element));
      if (sensor == "Humidity")
        markers.add(addMarker(
            text: value + "\n" + symbol, point: points.last, color: legendHumidity(double.parse(value).toInt()), otherSensors: element));
      if (sensor == "Pressure")
        markers.add(addMarker(
            text: value + "\n" + symbol, point: points.last, color: legendPressure(double.parse(value).toInt()), otherSensors: element));
    });
    if (points.isNotEmpty) {
      LatLngBounds llb = new LatLngBounds.fromPoints(points);
      mapController.fitBounds(llb, options: FitBoundsOptions(padding: EdgeInsets.all(50.0)));
    }
    loadingDataFromBackend = false;

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

  Color legendHumidity(int temp) {
    Color a, b;
    if (temp >= 100) return Colors.blue;
    if (temp <= 0) return Colors.red;

    if (temp >= 80 && temp < 100) {
      a = Colors.lightBlue;
      b = Colors.blue;
      temp -= 20;
    } else if (temp >= 60 && temp < 80) {
      a = Colors.green.shade700;
      b = Colors.lightBlue;
      temp -= 20;
    } else if (temp >= 40 && temp < 60) {
      a = Colors.yellow;
      b = Colors.green.shade700;
      temp -= 20;
    } else if (temp >= 20 && temp < 40) {
      a = Colors.orange;
      b = Colors.yellow;
      temp -= 20;
    } else if (temp >= 0 && temp < 20) {
      a = Colors.red;
      b = Colors.orange;
      temp -= 19;
    }

    return Color.lerp(a, b, temp / 20);
  }

  Color legendPressure(int temp) {
    Color a, b;
    if (temp >= 1100) return Colors.brown;
    if (temp <= 926) return Colors.purple;

    if (temp >= 1057 && temp < 1100) {
      a = Colors.brown;
      b = Colors.yellow;
      temp -= 43;
    } else if (temp >= 1013 && temp < 1057) {
      a = Colors.green.shade800;
      b = Colors.brown;
      temp -= 44;
    } else if (temp >= 970 && temp < 1013) {
      a = Colors.blueGrey;
      b = Colors.green.shade800;
      temp -= 43;
    } else if (temp >= 926 && temp < 970) {
      a = Colors.purple;
      b = Colors.blueGrey;
      temp -= 43;
    }

    return Color.lerp(a, b, temp / 20);
  }

  Widget dataTable = null;
  addMarker({point, color, text, DeviceDataModel otherSensors}) {
    return Marker(
      width: 60.0,
      height: 60.0,
      point: point,
      builder: (ctx) => GestureDetector(
        onTap: () async {
          List<DataRow> dataArray = [];
          otherSensors.sensors.forEach((sensor) {
            if (sensor.metric != null)
              dataArray.add(
                DataRow(cells: [
                  // DataCell(
                  //   Text(sensor.sensorName),
                  // ),
                  DataCell(
                    Text(sensor.sensorName + "_" + sensor.metricName),
                  ),
                  DataCell(
                    Text(sensor.value + " " + sensor.metric),
                  ),
                ]),
              );
          });
          dataTable = SingleChildScrollView(
            child: DataTable(
              columns: [
                // DataColumn(
                //   label: Text('Sensor Name'),
                // ),
                DataColumn(
                  label: Text('Sensor_Metric'),
                ),
                DataColumn(
                  label: Text('Value'),
                ),
              ],
              rows: dataArray,
            ),
          );
          var response = await _dialogService.showCustomDialog(
            barrierDismissible: true,
            customData: dataTable,
          );
          print('response data: ${response?.responseData}');
          notifyListeners();
        },
        child: Container(
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
                child: Text(text, style: TextStyle(fontSize: 13.0, color: Colors.white)),
              )
            ],
          ),
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
