import 'dart:ui';
import 'package:air_quality_system/datamodels/device_dataModel.dart';
import 'package:air_quality_system/datamodels/sensor_datamodel.dart';
import 'package:air_quality_system/ui/widgets/localNetwork/DeviceTile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:stacked/stacked.dart';
import 'localNetwork_model.dart';
import 'package:latlong/latlong.dart';

class LocalNetworkView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // final ThemeData _theme = Theme.of(context);
    return ViewModelBuilder<LocalNetworkViewModel>.reactive(
      builder: (context, model, child) => Scaffold(
        appBar: new AppBar(
          title: new Text('Local Network Sensors'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.refresh, color: Colors.white,),
              onPressed: model.refresh,
            )
          ],
        ),
        body: DeviceTileList(
          model.devices,
          onHistoryDataTap: (SensorDataModel device) {
            
          },
        ),
      ),
      viewModelBuilder: () => LocalNetworkViewModel(),
      onModelReady: (model) =>
          model.initState(), // TODO: khrebch fiha apre, prc initstate ta3 fluter w hadi custom je pense pas 3andhom meme behavior
    );
  }
}
