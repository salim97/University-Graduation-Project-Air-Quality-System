import 'package:flutter/material.dart';
import 'ui_helper.dart';
import 'package:air_quality_system/app/router.gr.dart';

/// Drawer Menu
class MenuWidget extends StatefulWidget {
  final num currentMenuPercent;
  final Function(bool) animateMenu;
  final String name;
  final String phoneNumber;
  MenuWidget({Key key, this.currentMenuPercent, this.animateMenu, this.phoneNumber, this.name}) : super(key: key);

  @override
  _MenuWidgetState createState() => _MenuWidgetState();
}

class _MenuWidgetState extends State<MenuWidget> {
  // i'm to lazy to make it elegant code
  //  final List _drawerMenu = [
  //     {
  //       // "icon": MdiIcons.accessPoint,
  //       "text": "Local Network",
  //       "route": Routes.localNetworkView,
  //     },
  //     {
  //       // "icon": MdiIcons.developerBoard,
  //       "text": "Contribute",
  //       "route": Routes.unAuth,
  //     },
  //     {
  //       // "icon": MdiIcons.information,
  //       "text": "About",
  //       // "route": ChatRiderRoute,
  //     },
  //     {
  //       // "icon": Icons.chat,
  //       "text": "Support",
  //       // "route": ChatRiderRoute,
  //     }
  //   ];

  List<String> menuItems = ['Home', 'Local Network', 'Timeline', 'Contributions'];
  List<String> subMenuItems = [
    'Settings',
    'About',
  ];

  String currentSelectedItem = 'Home';

  @override
  void initState() {
    super.initState();
    currentSelectedItem = menuItems.first;
  }

  onMenuItemClicked(String item) {
    setState(() {
      currentSelectedItem = item;
    });
    print(item);
    if (item == "Local Network") {
      Navigator.of(context).pushNamed(Routes.localNetworkView);
      widget.animateMenu(false);
      return;
    }
    if (item == "Contributions") {
      Navigator.of(context).pushNamed(Routes.phoneAuthView);
      widget.animateMenu(false);
      return;
    }
    
    
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text("Ncha'allah brabi :)"),
      duration: Duration(seconds: 1),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return widget.currentMenuPercent != 0
        ? Positioned(
            left: realW(-358 + 358 * widget.currentMenuPercent),
            width: realW(358),
            height: screenHeight,
            child: Opacity(
              opacity: widget.currentMenuPercent,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topRight: Radius.circular(realW(50))),
                  boxShadow: [
                    BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.16), blurRadius: realW(20)),
                  ],
                ),
                child: Stack(
                  children: <Widget>[
                    NotificationListener<OverscrollIndicatorNotification>(
                      onNotification: (notification) {
                        notification.disallowGlow();
                      },
                      child: CustomScrollView(
                        physics: NeverScrollableScrollPhysics(),
                        slivers: <Widget>[
                          SliverToBoxAdapter(
                            child: Container(
                              height: realH(100),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(topRight: Radius.circular(realW(50))),
                                  gradient: const LinearGradient(begin: Alignment.topLeft, colors: [
                                    Color(0xFF59C2FF),
                                    Color(0xFF1270E3),
                                  ])),
                              child: Stack(
                                children: <Widget>[
                                  Positioned(
                                    left: realW(10),
                                    top: realH(30),
                                    child: DefaultTextStyle(
                                      style: TextStyle(color: Colors.white),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            widget.name,
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: realW(18)),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            widget.phoneNumber,
                                            style: TextStyle(fontSize: realW(14)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: EdgeInsets.only(top: realH(34), bottom: realH(50), right: realW(37)),
                            sliver: SliverFixedExtentList(
                              itemExtent: realH(56),
                              delegate: new SliverChildBuilderDelegate((BuildContext context, int index) {
                                return GestureDetector(
                                  behavior: HitTestBehavior.translucent, // life saver <3
                                  onTap: () => onMenuItemClicked(menuItems[index]),
                                  child: Container(
                                    width: realW(321),
                                    alignment: Alignment.centerLeft,
                                    padding: EdgeInsets.only(left: realW(20)),
                                    decoration: menuItems[index] == currentSelectedItem
                                        ? BoxDecoration(
                                            color: Color(0xFF379BF2).withOpacity(0.2),
                                            borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(realW(50)), bottomRight: Radius.circular(realW(50))))
                                        : null,
                                    child: Text(
                                      menuItems[index],
                                      style: TextStyle(
                                          color: menuItems[index] == currentSelectedItem ? Colors.blue : Colors.black, fontSize: realW(20)),
                                    ),
                                  ),
                                );
                              }, childCount: menuItems.length),
                            ),
                          ),
                          SliverPadding(
                            padding: EdgeInsets.only(top: realH(34), bottom: realH(50), right: realW(37)),
                            sliver: SliverFixedExtentList(
                              itemExtent: realH(56),
                              delegate: new SliverChildBuilderDelegate((BuildContext context, int index) {
                                return GestureDetector(
                                  behavior: HitTestBehavior.translucent, // life saver <3
                                  onTap: () => onMenuItemClicked(subMenuItems[index]),
                                  child: Container(
                                    width: realW(321),
                                    alignment: Alignment.centerLeft,
                                    padding: EdgeInsets.only(left: realW(20)),
                                    decoration: subMenuItems[index] == currentSelectedItem
                                        ? BoxDecoration(
                                            color: Color(0xFF379BF2).withOpacity(0.2),
                                            borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(realW(50)), bottomRight: Radius.circular(realW(50))))
                                        : null,
                                    child: Text(
                                      subMenuItems[index],
                                      style: TextStyle(
                                          color: subMenuItems[index] == currentSelectedItem ? Colors.blue : Colors.black,
                                          fontSize: realW(20)),
                                    ),
                                  ),
                                );
                              }, childCount: subMenuItems.length),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // close button
                    Positioned(
                      bottom: realH(53),
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          widget.animateMenu(false);
                        },
                        child: Container(
                          width: realW(71),
                          height: realH(71),
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(left: realW(17)),
                          child: Icon(
                            Icons.close,
                            color: Color(0xFFE96977),
                            size: realW(34),
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFFFB5E74).withOpacity(0.2),
                            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(realW(36)), topLeft: Radius.circular(realW(36))),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        : const Padding(padding: EdgeInsets.all(0));
  }
}
