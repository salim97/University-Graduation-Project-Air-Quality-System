import 'dart:ui';

import 'package:air_quality_system/datamodels/all_sensors_model.dart';
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
              Positioned(
                  top: 0,
                  left: MediaQuery.of(context).size.width * 0.5,
                  child: RaisedButton(
                    child: Text("refresh"),
                    onPressed: model.refresh,
                  )),
              Positioned(
                  top: 450,
                  left: MediaQuery.of(context).size.width * 0.3,
                  child: Container(
                    height: 200,
                    width: 20,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            end : Alignment.topCenter,
                            begin: Alignment.bottomCenter,
                            colors: [
                          Colors.blue,
                          // Colors.lightBlueAccent,
                          Colors.green,
                          Colors.yellow,
                          Colors.red
                        ])),
                  )),
              Positioned(
                bottom: 0,
                left: 0,
                //  height: MediaQuery.of(context).size.height * 0.50,
                width: MediaQuery.of(context).size.width * 0.25,
                child: Image.asset(
                  "assets/images/chrome_2020-06-12_10-00-09.png",
                ),
              ),
              /*  Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.25,
              child: Container(
                  alignment: Alignment.center,
                  constraints: BoxConstraints(),
                  padding: EdgeInsets.only(bottom: 20.0),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(
                          0,
                          0,
                          0,
                          0.15,
                        ),
                        blurRadius: 25.0,
                      ),
                    ],
                    color: Colors.transparent,
                  ),
                  child: ListView(
                    padding: EdgeInsets.only(left: 20),
                    children: getTechniciansInArea(),
                    scrollDirection: Axis.horizontal,
                  )),
            ) */
            ],
          ),
        ),
      ),
      viewModelBuilder: () => HomeViewModel(),
      onModelReady: (model) => model
          .initState(), // TODO: khrebch fiha apre, prc initstate ta3 fluter w hadi custom je pense pas 3andhom meme behavior
    );
  }

  List<Widget> getTechniciansInArea() {
    List<Technician> techies = getTechies();
    List<Widget> cards = [];
    for (Technician techy in techies) {
      cards.add(technicianCard(techy));
    }
    return cards;
  }

  List<Technician> getTechies() {
    List<Technician> techies = [];
    for (int i = 0; i < 10; i++) {
      AssetImage profilePic = new AssetImage("assets/images/eat.png");
      Technician myTechy = new Technician(
          "Carlos Teller",
          "070-379-031",
          "First road 23 elm street",
          529.3,
          4,
          "Available",
          profilePic,
          "Electrician");
      techies.add(myTechy);
    }
    return techies;
  }
}

Widget technicianCard(Technician technician) {
  return Container(
    padding: EdgeInsets.all(10),
    margin: EdgeInsets.only(right: 20),
    width: 180,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      color: Colors.white,
      boxShadow: [
        new BoxShadow(
          color: Colors.grey,
          blurRadius: 20.0,
        ),
      ],
    ),
    child: Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Container(
              child: CircleAvatar(
                backgroundImage: technician.profilePic,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  technician.name,
                  style: techCardTitleStyle,
                ),
                Text(
                  technician.occupation,
                  style: techCardSubTitleStyle,
                )
              ],
            )
          ],
        ),
        Container(
          margin: EdgeInsets.only(top: 10),
          child: Row(
            children: <Widget>[
              Text(
                "Status:  ",
                style: techCardSubTitleStyle,
              ),
              Text(technician.status, style: statusStyles[technician.status])
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    "Rating: " + technician.rating.toString(),
                    style: techCardSubTitleStyle,
                  )
                ],
              ),
              Row(children: getRatings(technician))
            ],
          ),
        )
      ],
    ),
  );
}

Map statusStyles = {
  'Available': statusAvailableStyle,
  'Unavailable': statusUnavailableStyle
};

TextStyle techCardTitleStyle = new TextStyle(
    fontFamily: 'Gotham', fontWeight: FontWeight.bold, fontSize: 18);
TextStyle techCardSubTitleStyle = new TextStyle(
    fontFamily: 'Gotham', fontWeight: FontWeight.bold, fontSize: 13);

TextStyle statusUnavailableStyle = new TextStyle(
    fontFamily: 'Gotham',
    fontWeight: FontWeight.bold,
    fontSize: 13,
    color: Colors.red);
TextStyle statusAvailableStyle = new TextStyle(
    fontFamily: 'Gotham',
    fontWeight: FontWeight.bold,
    fontSize: 13,
    color: Colors.green);

List<Widget> getRatings(Technician techy) {
  List<Widget> ratings = [];
  for (int i = 0; i < 5; i++) {
    if (i < techy.rating) {
      ratings.add(new Icon(Icons.star, color: Colors.yellow));
    } else {
      ratings.add(new Icon(Icons.star_border, color: Colors.black));
    }
  }
  return ratings;
}

class Technician {
  String name;
  String phoneNum;
  String address;
  double rate;
  String status;
  int rating;
  AssetImage profilePic;
  String occupation;

  Technician(this.name, this.phoneNum, this.address, this.rate, this.rating,
      this.status, this.profilePic, this.occupation);
}
