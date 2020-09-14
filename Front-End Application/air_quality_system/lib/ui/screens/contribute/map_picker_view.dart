import 'dart:async';
import 'dart:math';

import 'package:air_quality_system/ui/widgets/home/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:stacked/stacked.dart';

import 'map_picker_model.dart';

class MapPickerView extends StatefulWidget {
  MapPickerView({Key key}) : super(key: key);

  @override
  _MapPickerViewState createState() => _MapPickerViewState();
}

class _MapPickerViewState extends State<MapPickerView> {
 

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MapPickerViewModel>.reactive(
      builder: (context, model, child) => Scaffold(
        body: Stack(
          children: [
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              left: 0,
              child: GoogleMap(
                zoomControlsEnabled: false,
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                  target: LatLng(35.691124, -0.618778),
                  zoom: 14.0,
                ),
                onMapCreated: (GoogleMapController controller) {
                  // Completer<GoogleMapController> _controller = Completer();
                  // _controller.complete(controller);
                  setState(() {
                    model.googleMapController = controller;
                  });
                },
                onCameraMove: (cameraPosition) {
                  model.setUserPosition(cameraPosition.target);
                },
                markers: Set<Marker>.of(model.markers.values),
              ),
            ),
            Positioned(
                right: -25,
                height: 75,
                width: 100,
                bottom: 100,
                child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.99),
                      borderRadius: BorderRadius.all(Radius.circular(36)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(right: 25.0),
                      child: IconButton(
                        icon: model.gettingUserPosition
                            ? CircularProgressIndicator()
                            : Icon(
                                Icons.gps_fixed,
                                color: Colors.blue,
                              ),
                        onPressed: () async {
                          if (model.gettingUserPosition == true) return;
                          model.getUserPosition();
                        },
                      ),
                    ))),
            Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                // height: 200,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.all(Radius.circular(36)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(model.userMarker?.position.toString()),
                        RaisedButton(
                          child: Text("Confirme"),
                          onPressed: () {
                            print("KAMOK");
                          },
                        )
                      ],
                    ),
                  ),
                ))
          ],
        ),
      ),
      viewModelBuilder: () => MapPickerViewModel(),
      onModelReady: (model) => model.initState(),
    );
  }
}
