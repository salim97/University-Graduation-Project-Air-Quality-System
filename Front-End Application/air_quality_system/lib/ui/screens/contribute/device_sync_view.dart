import 'dart:io';
import 'dart:math';

import 'package:air_quality_system/app/router.gr.dart';
import 'package:android_intent/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:flutter/material.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:stacked/stacked.dart';
import 'package:wifi_connector/wifi_connector.dart';
import 'package:wifi_flutter/wifi_flutter.dart';

import 'device_sync_model.dart';

class DeviceSyncView extends StatelessWidget {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DeviceSyncViewModel>.reactive(
      onModelReady: (model) => model.initState(),
      viewModelBuilder: () => DeviceSyncViewModel(),
      builder: (
        BuildContext context,
        DeviceSyncViewModel model,
        Widget child,
      ) {
        // if (model.devices.isEmpty)
        //   return MaterialApp(
        //       debugShowCheckedModeBanner: false,
        //       home: Scaffold(
        //         body: Center(
        //             child: Column(
        //           mainAxisAlignment: MainAxisAlignment.center,
        //           crossAxisAlignment: CrossAxisAlignment.center,
        //           children: <Widget>[Text("Waiting for response"), CircularProgressIndicator()],
        //         )),
        //       ));

        return new Scaffold(
            key: _scaffoldKey,
            appBar: new AppBar(title: Text('Network Scan')),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                model.refreshIndicatorKey.currentState.show();
                // Navigator.push(context, MaterialPageRoute(builder: (context) => WebViewConfig()));
              },
              child: Icon(Icons.network_check),
              backgroundColor: Theme.of(context).primaryColor,
            ),
            body: Column(
              children: [
                ListTile(
                  title: Text("ESP8266 needs your wifi credentials to able to reach internet"),
                ),
                RaisedButton(
                  child: Text("configure  WiFi"),
                  onPressed: () {
                    model.navigationService.navigateTo(Routes.esptouchView);
                  },
                ),
              ],
            )
            // Stack(children: <Widget>[
            //   LiquidPullToRefresh(
            //       key: model.refreshIndicatorKey,
            //       onRefresh: model.onRefresh,
            //       showChildOpacityTransition: true,
            //       child: model.devices.length == 0
            //           ? Column(
            //               mainAxisAlignment: MainAxisAlignment.center,
            //               crossAxisAlignment: CrossAxisAlignment.center,
            //               children: [
            //                 Text("make sure the device is power ON"),
            //                 Text("if led AQ device is red then click on configure WiFi"),
            //                 Text("if led AQ device is blue then click on Scan local Network"),
            //                 RaisedButton(
            //                   child: Text("configure  WiFi"),
            //                   onPressed: () {
            //                     model.navigationService.navigateTo(Routes.esptouchView);
            //                   },
            //                 ),
            //                 RaisedButton(
            //                   child: Text("Scan local Network"),
            //                   onPressed: () {
            //                     // model.navigationService.navigateTo(Routes.esptouchView);
            //                      model.refreshIndicatorKey.currentState.show();
            //                   },
            //                 ),
            //               ],
            //             )
            //           : ListView.builder(
            //               itemCount: model.devices.length,
            //               itemBuilder: (BuildContext ctxt, int index) {
            //                 return ListTile(
            //                     onTap: () {
            //                       // _scaffoldKey.currentState.showSnackBar(SnackBar(
            //                       //   content: Text("Ncha'allah brabi :)"),
            //                       //   duration: Duration(seconds: 1),
            //                       // ));
            //                       // model.syncWithDevice(index);
            //                     },
            //                     leading: Icon(Icons.developer_board),
            //                     title: Text(model.devices.elementAt(index).name),
            //                     subtitle: Text(
            //                         "ip = " + model.devices.elementAt(index).ip + " , uptime = " + model.devices.elementAt(index).upTime));
            //               })),
            // ]),

            );
      },
    );
  }
}
