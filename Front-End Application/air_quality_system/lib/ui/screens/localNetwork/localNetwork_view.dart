import 'dart:ui';
import 'package:air_quality_system/datamodels/device_dataModel.dart';
import 'package:air_quality_system/datamodels/sensor_datamodel.dart';
import 'package:air_quality_system/ui/widgets/localNetwork/DeviceTile.dart';
import 'package:air_quality_system/ui/widgets/localNetwork/navbar.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:stacked/stacked.dart';
import 'localNetwork_model.dart';
import 'package:latlong/latlong.dart';

// https://pub.dev/packages/curved_navigation_bar
// https://www.filledstacks.com/post/bottom-navigation-with-stacked-architecture/

class LocalNetworkView extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    // final ThemeData _theme = Theme.of(context);
       List<NavBarItemData> _navBarItems=[
            NavBarItemData("Sensors", Icons.developer_board, MediaQuery.of(context).size.width / 2, Color(0xff01b87d)),
            NavBarItemData("Log History", Icons.history, MediaQuery.of(context).size.width / 2, Color(0xff594ccf)),
          ];

    return ViewModelBuilder<LocalNetworkViewModel>.reactive(
      builder: (context, model, child) => Scaffold(
        // backgroundColor: Colors.transparent,
        bottomNavigationBar: NavBar(
          items: _navBarItems,
          itemTapped: model.setIndex,
          currentIndex: model.currentIndex,
        ),
        // bottomNavigationBar: CurvedNavigationBar(
        //     backgroundColor: Colors.grey,
        //     items: <Widget>[
        //       Icon(Icons.list, size: 30),
        //       Icon(Icons.history, size: 30),
        //     ],
        //     onTap: model.setIndex,
        //     index: model.currentIndex,
        //     height: 50.0),

        // BottomNavigationBar(
        //   type: BottomNavigationBarType.fixed,
        //   backgroundColor: Colors.grey[800],
        //   currentIndex: model.currentIndex,
        //   onTap: ,
        //   items: [
        //     BottomNavigationBarItem(
        //       title: Text('Sensors'),
        //       icon: Icon(Icons.list),
        //     ),
        //     BottomNavigationBarItem(
        //       title: Text('Log History'),
        //       icon: Icon(Icons.history),
        //     ),
        //   ],
        // ),
        appBar: new AppBar(
          backgroundColor: _navBarItems[model.currentIndex].selectedColor,
          title: new Text('Local Network Sensors'),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.refresh,
                color: Colors.white,
              ),
              onPressed: model.refresh,
            )
          ],
        ),
        body: AnimatedSwitcher(duration: Duration(milliseconds: 350), child: getViewForIndex(model)),
      ),
      viewModelBuilder: () => LocalNetworkViewModel(),
      onModelReady: (model) =>
          model.initState(), // TODO: khrebch fiha apre, prc initstate ta3 fluter w hadi custom je pense pas 3andhom meme behavior
    );
  }

  Widget getViewForIndex(model) {
    switch (model.currentIndex) {
      case 0:
        return Padding(
          padding: const EdgeInsets.only(bottom: 18.0),
          child: DeviceTileList(
            model.devices,
            onHistoryDataTap: (SensorDataModel device) {},
          ),
        );
      case 1:
        return new ListView.builder(
            itemCount: model.logs.length,
            itemBuilder: (BuildContext ctxt, int index) {
              var log = model.logs.elementAt(index);
              return new ListTile(
                leading: Icon(log.isError ? Icons.error : Icons.check, color: log.isError ? Colors.red : Colors.green),
                title: Text(log.msg),
                subtitle: Text(log.upTime),
              );
            });
      default:
        return DeviceTileList(
          model.devices,
          onHistoryDataTap: (SensorDataModel device) {},
        );
    }
  }
}
