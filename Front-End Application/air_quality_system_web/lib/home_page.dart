import 'dart:math';

import 'package:air_quality_system_web/widgets/ui_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'Rest_API.dart';
import 'datamodels/device_dataModel.dart';
import 'widgets/map_button.dart';
import 'widgets/search_menu_widget.dart';
import 'widgets/search_widget.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  AnimationController animationControllerExplore;

  AnimationController animationControllerSearch;

  AnimationController animationControllerMenu;

  CurvedAnimation curve;

  Animation<double> animation;

  Animation<double> animationW;

  Animation<double> animationR;

  void animateSearch(bool open) {
    animationControllerSearch = AnimationController(
        duration: Duration(milliseconds: 1 + (800 * (isSearchOpen ? currentSearchPercent : (1 - currentSearchPercent))).toInt()),
        vsync: this);
    curve = CurvedAnimation(parent: animationControllerSearch, curve: Curves.ease);
    animation = Tween(begin: offsetSearch, end: open ? 347.0 - 68.0 : 0.0).animate(curve)
      ..addListener(() {
        setState(() {
          offsetSearch = animation.value;
        });
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          isSearchOpen = open;
        }
      });
    animationControllerSearch.forward();
  }

  /// search drag callback
  void onSearchHorizontalDragUpdate(details) {
    offsetSearch -= details.delta.dx;
    if (offsetSearch < 0) {
      offsetSearch = 0;
    } else if (offsetSearch > (347 - 68.0)) {
      offsetSearch = 347 - 68.0;
    }
    setState(() {});
  }

  /// get currentOffset percent
  get currentExplorePercent => max(0.0, min(1.0, offsetExplore / (760.0 - 122.0)));

  get currentSearchPercent => max(0.0, min(1.0, offsetSearch / (347 - 68.0)));

  get currentMenuPercent => max(0.0, min(1.0, offsetMenu / 358));

  var offsetExplore = 0.0;

  var offsetSearch = 0.0;

  var offsetMenu = 0.0;

  bool isExploreOpen = false;

  bool isSearchOpen = false;

  bool isMenuOpen = false;

  MapController mapController = new MapController();
  List<Marker> markers = List<Marker>();

  var gas = {
    'Temperature': MdiIcons.whiteBalanceSunny,
    'Humidity': MdiIcons.waterPercent,
    'Pressure': MdiIcons.arrowCollapseVertical,
    'CO2': MdiIcons.molecule,
    'CO': MdiIcons.molecule,
    'NH3': MdiIcons.molecule,
    'NO2': MdiIcons.molecule,
    // 'O3': MdiIcons.molecule,
  };
  int gas_legend_index = 0;
  var gas_legend = {
    'Temperature': "assets/images/legend_Temperature.png",
    'Humidity': "assets/images/legend_Humidity.png",
    'Pressure': "assets/images/legend_Pressure.png",
  };

  var _gas = {
    'Temperature': 'assets/images/legend_Temperature.png',
    'Humidity': 'assets/images/legend_Humidity.png',
    'Pressure': 'assets/images/legend_Pressure.png',
    'AQI': 'assets/images/legend_AQI.png',
  };
  List<DropdownMenuItem<String>> dropDownMenuItems;
  String currentGas, currentGasLegend;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      currentGas = _gas.keys.first;
      currentGasLegend = _gas.values.first;

      // markers.add(addMarker(text: "80 \n %", point: LatLng(35.698272, -0.645404), color: legendHumidity(80), otherSensors: null));
      // markers.add(addMarker(text: "74 \n %", point: LatLng(35.687118, -0.636821), color: legendHumidity(74), otherSensors: null));
      // markers.add(addMarker(text: "94 \n %", point: LatLng(35.706357, -0.625834), color: legendHumidity(95), otherSensors: null));
      // markers.add(addMarker(text: "76 \n %", point: LatLng(35.688791, -0.629268), color: legendHumidity(76), otherSensors: null));
    });
    refresh();
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
          setState(() {
            
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

          });
_drawerKey.currentState.openDrawer();
          // var response = await _dialogService.showCustomDialog(
          //   barrierDismissible: true,
          //   customData: dataTable,
          // );
          // print('response data: ${response?.responseData}');
          // notifyListeners();
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

  RestAPIService restAPIService = new RestAPIService();
  bool loadingDataFromBackend = false;
  refresh({String sensor = "Temperature"}) async {
    // await firebaseAuthService.signInAnonymously();
    // return;
    setState(() {
      loadingDataFromBackend = true;
    });
    List<DeviceDataModel> list;
    // if (kIsWeb)
    list = await restAPIService.getLast10minRecords();
    // else
    // list = await myFirestoreDBservice.getLastdata();

    setState(() {
      loadingDataFromBackend = false;
    });
    setState(() {
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
          if (sensor == "CO") {
            value = element.getCO().first.value;
            symbol = element.getCO().first.metric;
          }
          if (sensor == "NH3") {
            value = element.getNH3().first.value;
            symbol = element.getNH3().first.metric;
          }
          if (sensor == "NO2") {
            value = element.getNO2().first.value;
            symbol = element.getNO2().first.metric;
          }
          // if (sensor == "O3") {
          //   value = element.getO3().first.value;
          //   symbol = element.getO3().first.metric;
          // }

        } catch (e) {
          print(e.toString());
          return;
        }
        if (value == "NULL") return;
        points.add(LatLng(element.gps.latitude, element.gps.longitude));
        if (sensor == "Temperature")
          markers.add(addMarker(
              text: value + "\n" + symbol,
              point: points.last,
              color: legendTemperature(double.parse(value).toInt()),
              otherSensors: element));
        if (sensor == "Humidity")
          markers.add(addMarker(
              text: value + "\n" + symbol, point: points.last, color: legendHumidity(double.parse(value).toInt()), otherSensors: element));
        if (sensor == "Pressure")
          markers.add(addMarker(
              text: value + "\n" + symbol, point: points.last, color: legendPressure(double.parse(value).toInt()), otherSensors: element));
        // if (sensor == "CO2")
          markers.add(addMarker(
              text: value + "\n" + symbol, point: points.last, color: Colors.blue, otherSensors: element));
      });
      if (points.isNotEmpty) {
        LatLngBounds llb = new LatLngBounds.fromPoints(points);
        mapController.fitBounds(llb, options: FitBoundsOptions(padding: EdgeInsets.all(50.0)));
      }
      loadingDataFromBackend = false;
    });
  }

  onCurrentSearchChanged(String item) {
    print(item);
    refresh(sensor: item);
    // if (item == "Temperature") refresh(sensor: item);
    // if (item == "Humidity") refresh(sensor: item);
    // if (item == "Pressure") refresh(sensor: item);
  }
GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    if (screenWidth > standardWidth) {
      screenWidth = standardWidth;
    }
    if (screenHeight > standardHeight) {
      screenHeight = standardHeight;
    }

    return Scaffold(
        key: _drawerKey, // assign key to Scaffold
      drawer: Drawer(child: dataTable,),
      body: Stack(
        children: <Widget>[
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              center: LatLng(35.691124, -0.618778),
              zoom: 14.0,
            ),
            layers: [
              TileLayerOptions(
                urlTemplate: "https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayerOptions(markers: markers)
            ],
          ),
          gas_legend_index < gas_legend.length
              ? Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: screenHeight * 0.2,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.all(Radius.circular(36)),
                    ),
                    child: Image.asset(
                      gas_legend.values.elementAt(gas_legend_index),
                      fit: BoxFit.fill,
                    ),
                  ),
                )
              : Container(),
          MapButton(
            currentSearchPercent: currentSearchPercent,
            currentExplorePercent: currentExplorePercent,
            bottom: 148,
            offsetX: -68,
            width: 68,
            height: 71,
            childWidget: loadingDataFromBackend
                ? CircularProgressIndicator()
                : Icon(
                    MdiIcons.refresh,
                    size: 34,
                    color: Colors.blue,
                  ),
            onButtonClicked: () async {
              refresh();
            },
          ),

          //search menu background
          offsetSearch != 0
              ? Positioned(
                  bottom: realH(88),
                  right: realW((standardWidth - 320) / 2),
                  width: realW(320),
                  height: realH((400 * currentSearchPercent) + 50),
                  child: Opacity(
                    opacity: currentSearchPercent,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(realW(33)), topRight: Radius.circular(realW(33)))),
                    ),
                  ),
                )
              : const Padding(
                  padding: const EdgeInsets.all(0),
                ),
          //search menu
          SearchMenuWidget(
            currentSearchPercent: currentSearchPercent,
            gas: gas,
            onCurrentSearchChanged: onCurrentSearchChanged,
          ),
          //search
          SearchWidget(
            mainIcon: Icon(
              // MdiIcons.formSelect,
              MdiIcons.cogOutline,
              size: 34,
            ),
            currentSearchPercent: currentSearchPercent,
            currentExplorePercent: currentExplorePercent,
            isSearchOpen: isSearchOpen,
            animateSearch: animateSearch,
            onHorizontalDragUpdate: onSearchHorizontalDragUpdate,
            onPanDown: () => animationControllerSearch?.stop(),
          ),
        ],
      ),
    );
  }
}
