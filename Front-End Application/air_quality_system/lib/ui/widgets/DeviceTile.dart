import 'package:air_quality_system/datamodels/Device.dart';
import 'package:air_quality_system/datamodels/sense_model.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class DeviceTile extends StatelessWidget {
  DeviceTile(this.device, {this.expanded, this.onTap, this.onHistoryDataTap});

  final Device device;
  final GestureTapCallback onTap;
  final GestureTapCallback onHistoryDataTap;
  final bool expanded;

  Widget _buildHeader() {
    return new ListTile(
      key: new ValueKey(device.timestamp),
      title:
          new Text(device.name, style: TextStyle(fontWeight: FontWeight.w500)),
      subtitle: new Text(device.timestamp),
      leading: const Icon(Icons.developer_board, size: 36.0),
      trailing: new Icon(
          this.expanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
          size: 36.0),
      onTap: this.onTap,
    );
  }

  Widget _buildCard(Widget child, {Function() onTap}) {
    return Material(
        elevation: 4.0,
        borderRadius: BorderRadius.circular(12.0),
        shadowColor: Colors.black,
        child: InkWell(child: child));
  }

  Widget _buildDataCard(
      String metricName, String value, String metric, IconData icon) {
    icon = MdiIcons.molecule; //white-balance-sunny
    if (metric == "°C") icon = MdiIcons.whiteBalanceSunny; //white-balance-sunny
    if (metric == "%") icon = MdiIcons.waterPercent; //white-balance-sunny
    if (metric.toLowerCase() == "hpa")
      icon = MdiIcons.arrowCollapseVertical; //white-balance-sunny
    if (metric.toLowerCase() == "ppm" &&
        metricName.toLowerCase().contains("co"))
      icon = MdiIcons.moleculeCo; //white-balance-sunny
    if (metric.toLowerCase() == "ppm" &&
        metricName.toLowerCase().contains("co2"))
      icon = MdiIcons.moleculeCo2; //white-balance-sunny

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
      device.sensors.forEach((element) {
        children.add(_buildDataCard(element.name, element.value.toString(),
            element.unit, Icons.device_unknown));
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
          Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children),
        ),
      ),
    );
  }
}

class DeviceTileList extends StatefulWidget {
  List<bool> expanded = new List<bool>();

  DeviceTileList(this.devices, {this.onHistoryDataTap}) {
    devices.forEach((element) {
      expanded.add(true);
    });
  }
  final List<Device> devices;
  final Function(Device) onHistoryDataTap;

  @override
  _DeviceTileListState createState() => new _DeviceTileListState();
}

class _DeviceTileListState extends State<DeviceTileList> {
  int selectedIndex = -1;

  // void initState() {
  //   super.initState();
  // }

  Widget build(BuildContext context) {
    return new ListView.builder(
      itemCount: this.widget.devices.length,
      itemBuilder: (BuildContext context, int index) {
        if (selectedIndex == index) {
          widget.devices[index].expanded = !widget.devices[index].expanded;
          selectedIndex = -1;
        }
        Device device = this.widget.devices[index];
        return DeviceTile(
          device,
          expanded: device.expanded, //widget.expanded[index],
          onHistoryDataTap: () {
            this.widget.onHistoryDataTap(device);
          },
          onTap: () {
            setState(() {
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
