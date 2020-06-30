import 'dart:ui';
import 'package:air_quality_system/ui/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:stacked/stacked.dart';
import 'home_model.dart';
import 'package:latlong/latlong.dart';

class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);
    return ViewModelBuilder<HomeViewModel>.reactive(
      builder: (context, model, child) => Scaffold(
        resizeToAvoidBottomPadding: false,
        drawer: AppDrawer(),
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              FlutterMap(
                options: MapOptions(
                  center: LatLng(35.691124, -0.618778),
                  zoom: 14.0,
                ),
                layers: [
                  TileLayerOptions(
                    urlTemplate:
                        "https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c'],
                  ),
                  MarkerLayerOptions(markers: model.markers)
                ],
              ),
              Builder(
                builder: (BuildContext context) {
                  return IconButton(
                    icon: Icon(
                      Icons.menu,
                      size: 35.0,
                    ),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  );
                },
              ),
              // Positioned(
              //     top: 0,
              //     left: MediaQuery.of(context).size.width * 0.5,
              //     child: RaisedButton(
              //       child: Text("refresh"),
              //       onPressed: model.refresh,
              //     )),
              // Positioned(
              //     bottom: 0,
              //     left: MediaQuery.of(context).size.width * 0.25,
              //     child: Container(
              //       decoration: BoxDecoration(color: Colors.white),
              //       child: DropdownButton(
              //         value: model.currentGas,
              //         items: model.dropDownMenuItems,
              //         onChanged: model.changedDropDownItem,
              //       ),
              //     )),
              // Positioned(
              //   bottom: 0,
              //   left: 0,
              //   //  height: MediaQuery.of(context).size.height * 0.50,
              //   width: MediaQuery.of(context).size.width * 0.25,
              //   child: Image.asset(
              //     // "assets/images/legend_Temperature.png",
              //     model.currentGasLegend
              //   ),
              // ),

            ],
          ),
        ),
      ),
      viewModelBuilder: () => HomeViewModel(),
      onModelReady: (model) => model
          .initState(), // TODO: khrebch fiha apre, prc initstate ta3 fluter w hadi custom je pense pas 3andhom meme behavior
    );
  }



}
