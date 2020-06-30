import 'package:flutter/material.dart';
import 'package:air_quality_system/app/router.gr.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
// import '../router.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeData _theme = Theme.of(context);
    final List _drawerMenu = [
      {
        "icon": MdiIcons.accessPoint,
        "text": "Local Network",
        "route": Routes.localNetworkView,
      },
      {
        "icon": MdiIcons.developerBoard,
        "text": "Contribute",
        "route": Routes.unAuth,
      },
      {
        "icon": MdiIcons.information,
        "text": "About",
        // "route": ChatRiderRoute,
      },
      {
        "icon": Icons.chat,
        "text": "Support",
        // "route": ChatRiderRoute,
      }
    ];

    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width - (MediaQuery.of(context).size.width * 0.2),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 25.0,
              ),
              height: 100.0,
              color: _theme.primaryColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Garuba OLayemii",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Navigator.of(context).pushNamed(ProfileRoute);
                        },
                        child: Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                  Text(
                    "444-509-980-103",
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 15.0,
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(
                  top: 20.0,
                ),
                child: ListView(
                  children: _drawerMenu.map((menu) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(menu["route"]);
                      },
                      child: ListTile(
                        leading: Icon(menu["icon"]),
                        title: Text(
                          menu["text"],
                          style: TextStyle(
                            fontSize: 17.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
