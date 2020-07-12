import 'dart:collection';
import 'dart:math';

import 'package:air_quality_system/datamodels/device_dataModel.dart';

import 'package:air_quality_system/datamodels/sensor_datamodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sparkline/flutter_sparkline.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class DeviceTile extends StatefulWidget {
  DeviceTile(this.sensors, {this.expanded, this.onTap, this.onHistoryDataTap});

  final List<SensorDataModel> sensors;
  final GestureTapCallback onTap;
  final GestureTapCallback onHistoryDataTap;
  final bool expanded;

  @override
  _DeviceTileState createState() => _DeviceTileState();
}

class _DeviceTileState extends State<DeviceTile> {
  bool isChartOpen = false;
  int chartSample = 5;

  Widget _buildHeader() {
    return new ListTile(
      key: new ValueKey(widget.sensors.first.timeStamp),
      title: new Text(widget.sensors.first.sensorName, style: TextStyle(fontWeight: FontWeight.w500)),
      subtitle: new Text(widget.sensors.first.timeStamp),
      leading: const Icon(MdiIcons.developerBoard, size: 36.0),
      trailing: new Icon(this.widget.expanded ? Icons.arrow_drop_up : Icons.arrow_drop_down, size: 36.0),
      onTap: this.widget.onTap,
    );
  }

  Widget _buildCard(Widget child, {Function() onTap}) {
    return Material(elevation: 4.0, borderRadius: BorderRadius.circular(12.0), shadowColor: Colors.black, child: InkWell(child: child));
  }

  Widget _buildDataCard(String metricName, String value, String metric, IconData icon) {
    return Container(
      margin: EdgeInsets.all(2.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(metricName, style: TextStyle(color: Colors.green)),
                Text(
                  "$value $metric",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 34.0,
                  ),
                )
              ],
            ),
            Material(
                color: Colors.green,
                borderRadius: BorderRadius.circular(24.0),
                child: Center(
                    child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Icon(icon, color: Colors.white, size: 30.0),
                )))
          ],
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    var children = <Widget>[
      _buildHeader(),
    ];
    widget.sensors.forEach((sensor) {
      if (widget.expanded) {
        children.add(_buildDataCard(sensor.metricName, sensor.value, sensor.metric, sensor.getIcon()));
        // sensor.senses.forEach((element) {
        //   children.add(_buildDataCard(element.name, element.value, element.symbol, element.getIcon()));
        // });

        if (sensor.values != null && isChartOpen) {
          List<double> abc = new List<double>();
          sensor.values.forEach((element) {
            if (!element.contains("."))
              abc.add(int.parse(element).toDouble());
            else
              abc.add(double.parse(element));
          });
          // while (abc.length > chartSample) abc.removeAt(0);

          children.add(Padding(
            padding: const EdgeInsets.all(8.0),
            child: Sparkline(
              data: abc,
              lineWidth: 3.0,
              pointColor: Colors.black,
              pointSize: 8.0,
              pointsMode: PointsMode.last,
              lineColor: Colors.green,
            ),
          ));
        }
      }
    });
    children.add(Container(
      alignment: Alignment.center,
      margin: EdgeInsets.all(4.0),
      child: FlatButton.icon(
        icon: const Icon(Icons.timeline),
        color: Colors.green,
        textColor: Colors.white,
        label: const Text('See historical data'),
        onPressed: () {
          setState(() {
            isChartOpen = !isChartOpen;
          });
        },
      ),
    ));
    return Container(
      margin: EdgeInsets.all(4.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _buildCard(
          Column(mainAxisAlignment: MainAxisAlignment.spaceAround, crossAxisAlignment: CrossAxisAlignment.start, children: children),
        ),
      ),
    );
  }
}

class DeviceTileList extends StatefulWidget {
  DeviceTileList(this.devices, {this.onHistoryDataTap}) {}
  final DeviceDataModel devices;
  final Function(SensorDataModel) onHistoryDataTap;

  @override
  _DeviceTileListState createState() => new _DeviceTileListState();
}

class _DeviceTileListState extends State<DeviceTileList> {
  int selectedIndex = -1;
  Map<String, bool> expanded = new Map<String, bool>();

  void initState() {
    super.initState();
    Map<String, List<SensorDataModel>> newSensors = this.widget.devices.regroupSensorsByName();

    setState(() {
      newSensors.values.forEach((element) {
        expanded[element.first.uid()] = true;
      });
    });
  }

  Widget build(BuildContext context) {
    Map<String, List<SensorDataModel>> newSensors = this.widget.devices.regroupSensorsByName();

    return new ListView.builder(
      itemCount: newSensors.keys.length,
      itemBuilder: (BuildContext context, int index) {
        List<SensorDataModel> sensor = newSensors.values.elementAt(index);
        if (expanded.isEmpty)
          widget.devices.sensors.forEach((element) {
            expanded[element.uid()] = true;
          });

        return DeviceTile(
          sensor,
          expanded: expanded[sensor.first.uid()],
          onHistoryDataTap: () {
            // this.widget.onHistoryDataTap(sensor);
          },
          onTap: () {
            setState(() {
              expanded[sensor.first.uid()] = !expanded[sensor.first.uid()];
              if (selectedIndex == index) {
                selectedIndex = -1;
              } else {
                selectedIndex = index;
              }
            });
          },
        );
      },
    );
  }
}
