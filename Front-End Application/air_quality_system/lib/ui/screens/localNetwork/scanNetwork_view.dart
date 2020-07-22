import 'dart:io';
import 'dart:math';

import 'package:android_intent/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:flutter/material.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:stacked/stacked.dart';

import 'scanNetwork_model.dart';

class ScanNetworkView extends StatelessWidget {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {

    return ViewModelBuilder<ScanNetworkViewModel>.reactive(
      onModelReady: (model) => model.initState(),
      viewModelBuilder: () => ScanNetworkViewModel(),
      builder: (
        BuildContext context,
        ScanNetworkViewModel model,
        Widget child,
      ) {

      // if (model.serviceStatus != ServiceStatus.enabled)
      // return MaterialApp(
      //     debugShowCheckedModeBanner: false,
      //     home: Scaffold(
      //       body: Center(
      //           child: Column(
      //         mainAxisAlignment: MainAxisAlignment.center,
      //         crossAxisAlignment: CrossAxisAlignment.center,
      //         children: <Widget>[
      //           Text("Please enable GPS..."),
      //           RaisedButton(
      //             color: Colors.green,
      //             child: Text("Turn On"),
      //             onPressed: () async {
      //               final AndroidIntent intent = new AndroidIntent(
      //                 action: 'android.settings.LOCATION_SOURCE_SETTINGS',
      //               );
      //               await intent.launch();
      //             },
      //           )
      //         ],
      //       )),
      //     ));

        return new Scaffold(
          key: _scaffoldKey,
          appBar: new AppBar(title:  Text('Network Scan')),
          floatingActionButton: FloatingActionButton(
            onPressed: () => model.refreshIndicatorKey.currentState.show(),
            child: Icon(Icons.network_check),
            backgroundColor: Theme.of(context).primaryColor,
          ),
          body: LiquidPullToRefresh(
              key: model.refreshIndicatorKey,
              onRefresh: model.onRefresh,
              showChildOpacityTransition: true,
              child: new ListView.builder(
                  itemCount: model.devices.length,
                  itemBuilder: (BuildContext ctxt, int index) {
                    return ListTile(
                        onTap: () {
                          // _scaffoldKey.currentState.showSnackBar(SnackBar(
                          //   content: Text("Ncha'allah brabi :)"),
                          //   duration: Duration(seconds: 1),
                          // ));
                           model.syncWithDevice(index);
                        },
                        leading: Icon(Icons.developer_board),
                        title: Text(model.devices.elementAt(index).name),
                        subtitle: Text("ip = "+model.devices.elementAt(index).ip+" , uptime = "+model.devices.elementAt(index).upTime)
                        );
                  })),
        );
      },
    );
  }
}
