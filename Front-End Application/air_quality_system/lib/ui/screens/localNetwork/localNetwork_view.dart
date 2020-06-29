import 'dart:ui';
import 'package:air_quality_system/datamodels/Device.dart';
import 'package:air_quality_system/datamodels/all_sensors_model.dart';
import 'package:air_quality_system/ui/widgets/DeviceTile.dart';
import 'package:air_quality_system/ui/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:stacked/stacked.dart';
import 'localNetwork_model.dart';
import 'package:latlong/latlong.dart';

class LocalNetworkView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);
    return ViewModelBuilder<LocalNetworkViewModel>.reactive(
      builder: (context, model, child) => Scaffold(
      appBar: new AppBar(
        title: new Text('Local Network Sensors'),
      ),
      body: DeviceTileList(
        model.devices,
        onHistoryDataTap: (Device device) {
          // Navigator
          //     .of(context)
          //     .push(MaterialPageRoute(builder: (_) => DeviceChartPage(device)));
        },
      ),
    ),
      viewModelBuilder: () => LocalNetworkViewModel(),
      onModelReady: (model) => model
          .initState(), // TODO: khrebch fiha apre, prc initstate ta3 fluter w hadi custom je pense pas 3andhom meme behavior
    );
  }



}
