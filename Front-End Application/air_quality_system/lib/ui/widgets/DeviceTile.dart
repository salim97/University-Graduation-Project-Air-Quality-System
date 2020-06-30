import 'dart:math';

import 'package:air_quality_system/datamodels/device_dataModel.dart';

import 'package:air_quality_system/datamodels/sensor_datamodel.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class DeviceTile extends StatelessWidget {
  DeviceTile(this.sensor, {this.expanded, this.onTap, this.onHistoryDataTap});

  final SensorDataModel sensor;
  final GestureTapCallback onTap;
  final GestureTapCallback onHistoryDataTap;
  final bool expanded;

  Widget _buildHeader() {
    return new ListTile(
      key: new ValueKey(sensor.timeStamp),
      title: new Text(sensor.name, style: TextStyle(fontWeight: FontWeight.w500)),
      subtitle: new Text(sensor.timeStamp),
      leading: const Icon(Icons.developer_board, size: 36.0),
      trailing: new Icon(this.expanded ? Icons.arrow_drop_up : Icons.arrow_drop_down, size: 36.0),
      onTap: this.onTap,
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
    if (expanded) {
      sensor.senses.forEach((element) {
        children.add(_buildDataCard(element.name, element.value, element.symbol, element.getIcon()));
      });
      children.add(Container(
        alignment: Alignment.center,
        margin: EdgeInsets.all(4.0),
        child: FlatButton.icon(
          icon: const Icon(Icons.timeline),
          color: Colors.green,
          textColor: Colors.white,
          label: const Text('See historical data'),
          onPressed: this.onHistoryDataTap,
        ),
      ));
    }
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
    setState(() {
      widget.devices.sensors.forEach((element) {
        expanded[element.name] = true;
      });
    });
  }

  Widget build(BuildContext context) {
    return new ListView.builder(
      itemCount: this.widget.devices.sensors.length,
      itemBuilder: (BuildContext context, int index) {
        SensorDataModel sensor = this.widget.devices.sensors[index];
        if (expanded.isEmpty)
          widget.devices.sensors.forEach((element) {
            expanded[element.name] = true;
          });
        return DeviceTile(
          sensor,
          expanded: expanded[sensor.name],
          onHistoryDataTap: () {
            this.widget.onHistoryDataTap(sensor);
          },
          onTap: () {
            setState(() {
              expanded[sensor.name] = !expanded[sensor.name];
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
