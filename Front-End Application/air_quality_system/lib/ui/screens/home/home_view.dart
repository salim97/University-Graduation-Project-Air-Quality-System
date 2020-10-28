import 'dart:math';
import 'dart:ui';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';
import 'home_model.dart';
import 'package:latlong/latlong.dart';

import '../../widgets/home/components.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

const String feature1 = 'feature1', feature2 = 'feature2', feature3 = 'feature3', feature4 = 'feature4';

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  AnimationController animationControllerExplore;

  AnimationController animationControllerSearch;

  AnimationController animationControllerMenu;

  CurvedAnimation curve;

  Animation<double> animation;

  Animation<double> animationW;

  Animation<double> animationR;

  /// get currentOffset percent
  get currentExplorePercent => max(0.0, min(1.0, offsetExplore / (760.0 - 122.0)));

  get currentSearchPercent => max(0.0, min(1.0, offsetSearch / (347 - 68.0)));

  get currentMenuPercent => max(0.0, min(1.0, offsetMenu / 358));

  var offsetExplore = 0.0;

  var offsetSearch = 0.0;

  var offsetMenu = 0.0;

  bool isExploreOpen = false;

  bool isSearchOpen = false;

  bool isMenuOpen = false;

  /// search drag callback
  void onSearchHorizontalDragUpdate(details) {
    offsetSearch -= details.delta.dx;
    if (offsetSearch < 0) {
      offsetSearch = 0;
    } else if (offsetSearch > (347 - 68.0)) {
      offsetSearch = 347 - 68.0;
    }
    setState(() {});
  }

  /// explore drag callback
  void onExploreVerticalUpdate(details) {
    offsetExplore -= details.delta.dy;
    if (offsetExplore > 644) {
      offsetExplore = 644;
    } else if (offsetExplore < 0) {
      offsetExplore = 0;
    }
    setState(() {});
  }

  /// animate Explore
  ///
  /// if [open] is true , make Explore open
  /// else make Explore close
  void animateExplore(bool open) {
    animationControllerExplore = AnimationController(
        duration: Duration(milliseconds: 1 + (800 * (isExploreOpen ? currentExplorePercent : (1 - currentExplorePercent))).toInt()),
        vsync: this);
    curve = CurvedAnimation(parent: animationControllerExplore, curve: Curves.ease);
    animation = Tween(begin: offsetExplore, end: open ? 760.0 - 122 : 0.0).animate(curve)
      ..addListener(() {
        setState(() {
          offsetExplore = animation.value;
        });
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          isExploreOpen = open;
        }
      });
    animationControllerExplore.forward();
  }

  void animateSearch(bool open) {
    animationControllerSearch = AnimationController(
        duration: Duration(milliseconds: 1 + (800 * (isSearchOpen ? currentSearchPercent : (1 - currentSearchPercent))).toInt()),
        vsync: this);
    curve = CurvedAnimation(parent: animationControllerSearch, curve: Curves.ease);
    animation = Tween(begin: offsetSearch, end: open ? 347.0 - 68.0 : 0.0).animate(curve)
      ..addListener(() {
        setState(() {
          offsetSearch = animation.value;
        });
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          isSearchOpen = open;
        }
      });
    animationControllerSearch.forward();
  }

  void animateMenu(bool open) {
    animationControllerMenu = AnimationController(duration: Duration(milliseconds: 500), vsync: this);
    curve = CurvedAnimation(parent: animationControllerMenu, curve: Curves.ease);
    animation = Tween(begin: open ? 0.0 : 358.0, end: open ? 358.0 : 0.0).animate(curve)
      ..addListener(() {
        setState(() {
          offsetMenu = animation.value;
        });
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          isMenuOpen = open;
        }
      });
    animationControllerMenu.forward();
  }

  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('seen') ?? false);

    if (!_seen) {
      await prefs.setBool('seen', true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FeatureDiscovery.discoverFeatures(
          context,
          const <String>{
            feature1,
            feature2,
            feature3,
            feature4,
          },
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    //checkFirstSeen();
  }

  Widget iconDrawer = Icon(
    Icons.menu,
    size: 34,
  );
  Widget iconRefresh = Icon(
    Icons.refresh,
    size: 34,
    color: Colors.blue,
  );
  Widget iconMenu = Icon(
    // MdiIcons.formSelect,
    MdiIcons.cogOutline,
    size: 34,
  );
  Widget iconWeather = Icon(
    MdiIcons.weatherPartlySnowyRainy,
    size: 34,
    color: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    //bool kIsWeb = true;
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    if (screenWidth > standardWidth && kIsWeb) {
      screenWidth = standardWidth;
    }
    if (screenHeight > standardHeight && kIsWeb) {
      screenHeight = standardHeight;
    }
    //print("kIsWeb: "+ kIsWeb.toString());
    return ViewModelBuilder<HomeViewModel>.reactive(
      builder: (context, model, child) {
        if (model.isInternetAvailable == false) {
          return Scaffold(
            body: Center(
              child: Text("This app need internet in order to work"),
            ),
          );
        }
        return kIsWeb
            ? webUI(context, model, child)
            : Scaffold(
                body: SafeArea(
                  child: Center(
                    child: SizedBox(
                      width: screenWidth,
                      height: screenHeight,
                      child: Stack(
                        children: <Widget>[
                          FlutterMap(
                            mapController: model.mapController,
                            options: MapOptions(
                              center: LatLng(35.691124, -0.618778),
                              zoom: 14.0,
                            ),
                            layers: [
                              TileLayerOptions(
                                urlTemplate: "https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png",
                                subdomains: ['a', 'b', 'c'],
                              ),
                              MarkerLayerOptions(markers: model.markers)
                            ],
                          ),
                          model.gas_legend_index < model.gas_legend.length
                              ? Positioned(
                                  top: 0,
                                  right: 0,
                                  left: 0,
                                  height: screenHeight * 0.2,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.25),
                                      borderRadius: BorderRadius.all(Radius.circular(36)),
                                    ),
                                    child: Image.asset(
                                      model.gas_legend.values.elementAt(model.gas_legend_index),
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                )
                              : Container(),

                          ExploreWidget(
                            title: isExploreOpen ? "Weather Forecast" : "Weather",
                            icon: DescribedFeatureOverlay(
                                featureId: feature4,
                                tapTarget: iconWeather,
                                backgroundColor: Colors.green,
                                targetColor: Colors.blue,
                                onOpen: () async {
                                  print('Tapped tap target of $feature1.');
                                  return true;
                                },
                                title: const Text('Weather forecast', style: TextStyle(fontSize: 22.0)),
                                description: const Text('Get weather forecast of your current location', style: TextStyle(fontSize: 18.0)),
                                child: iconWeather),
                            currentExplorePercent: currentExplorePercent,
                            currentSearchPercent: currentSearchPercent,
                            animateExplore: animateExplore,
                            isExploreOpen: isExploreOpen,
                            onVerticalDragUpdate: onExploreVerticalUpdate,
                            onPanDown: () => animationControllerExplore?.stop(),
                          ),
                          //explore content
                          ExploreContentWidget(
                            currentExplorePercent: currentExplorePercent,
                          ),

                          //search menu background
                          offsetSearch != 0
                              ? Positioned(
                                  bottom: realH(88),
                                  left: realW((standardWidth - 320) / 2),
                                  width: realW(320),
                                  height: realH(400 * currentSearchPercent),
                                  child: Opacity(
                                    opacity: currentSearchPercent,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.7),
                                          borderRadius:
                                              BorderRadius.only(topLeft: Radius.circular(realW(33)), topRight: Radius.circular(realW(33)))),
                                    ),
                                  ),
                                )
                              : const Padding(
                                  padding: const EdgeInsets.all(0),
                                ),
                          //search menu
                          SearchMenuWidget(
                            currentSearchPercent: currentSearchPercent,
                            gas: model.gas,
                            onCurrentSearchChanged: model.onCurrentSearchChanged,
                          ),
                          //search
                          SearchWidget(
                            mainIcon: DescribedFeatureOverlay(
                                featureId: feature1,
                                tapTarget: iconMenu,
                                backgroundColor: Colors.green,
                                onOpen: () async {
                                  print('Tapped tap target of $feature1.');
                                  return true;
                                },
                                title: const Text('Map menu', style: TextStyle(fontSize: 22.0)),
                                description: const Text(
                                    'click on this mapbutton to select target chemical ( Temperature, humidity, CO2 ...etc ) to be displayed in the map',
                                    style: TextStyle(fontSize: 18.0)),
                                child: iconMenu),
                            currentSearchPercent: currentSearchPercent,
                            currentExplorePercent: currentExplorePercent,
                            isSearchOpen: isSearchOpen,
                            animateSearch: animateSearch,
                            onHorizontalDragUpdate: onSearchHorizontalDragUpdate,
                            onPanDown: () => animationControllerSearch?.stop(),
                          ),

                          MapButton(
                            currentSearchPercent: currentSearchPercent,
                            currentExplorePercent: currentExplorePercent,
                            bottom: 148,
                            offsetX: -68,
                            width: 68,
                            height: 71,
                            childWidget: model.loadingDataFromBackend
                                ? CircularProgressIndicator()
                                : DescribedFeatureOverlay(
                                    featureId: feature2,
                                    tapTarget: iconRefresh,
                                    backgroundColor: Colors.green,
                                    onOpen: () async {
                                      print('Tapped tap target of $feature1.');
                                      return true;
                                    },
                                    title: const Text('Map Refresh', style: TextStyle(fontSize: 22.0)),
                                    description:
                                        const Text('Get latest 10 min data and display it to map', style: TextStyle(fontSize: 18.0)),
                                    child: iconRefresh,
                                  ),
                            onButtonClicked: () async {
                              model.refresh();
                            },
                          ),

                          MapButton(
                            currentSearchPercent: currentSearchPercent,
                            currentExplorePercent: currentExplorePercent,
                            bottom: 250,
                            offsetX: -68,
                            width: 68,
                            height: 71,
                            childWidget: Icon(
                              Icons.help,
                              size: 34,
                              color: Colors.blue,
                            ),
                            onButtonClicked: () {
                              FeatureDiscovery.discoverFeatures(
                                context,
                                const <String>{
                                  feature1,
                                  feature2,
                                  feature3,
                                  feature4,
                                },
                              );
                            },
                          ),
                          //menu button
                          Positioned(
                            bottom: realH(53),
                            left: realW(-71 * (currentExplorePercent + currentSearchPercent)),
                            child: GestureDetector(
                              onTap: () {
                                animateMenu(true);
                              },
                              child: Opacity(
                                opacity: 1 - (currentSearchPercent + currentExplorePercent),
                                child: Container(
                                  width: realW(71),
                                  height: realH(71),
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.only(left: realW(17)),
                                  child: DescribedFeatureOverlay(
                                      featureId: feature3,
                                      tapTarget: iconDrawer,
                                      backgroundColor: Colors.green,
                                      onOpen: () async {
                                        print('Tapped tap target of $feature1.');
                                        return true;
                                      },
                                      title: const Text('App Drawer', style: TextStyle(fontSize: 22.0)),
                                      description: const Text('Access to more functionality of the App', style: TextStyle(fontSize: 18.0)),
                                      child: iconDrawer),
                                  decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.75),
                                      borderRadius:
                                          BorderRadius.only(bottomRight: Radius.circular(realW(36)), topRight: Radius.circular(realW(36))),
                                      boxShadow: [
                                        BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.3), blurRadius: realW(36)),
                                      ]),
                                ),
                              ),
                            ),
                          ),
                          //menu
                          MenuWidget(
                            currentMenuPercent: currentMenuPercent,
                            animateMenu: animateMenu,
                            name: "Air Quality System",
                            phoneNumber: "",
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
      },
      viewModelBuilder: () => HomeViewModel(),
      onModelReady: (model) =>
          model.initState(), // TODO: khrebch fiha apre, prc initstate ta3 fluter w hadi custom je pense pas 3andhom meme behavior
    );
  }

  webUI(context, model, child) {
    
    return Scaffold(body: Center(child: Text("NIK MOK"),));

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Stack(
            children: <Widget>[
              FlutterMap(
                mapController: model.mapController,
                options: MapOptions(
                  center: LatLng(35.691124, -0.618778),
                  zoom: 14.0,
                ),
                layers: [
                  TileLayerOptions(
                    urlTemplate: "https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c'],
                  ),
                  MarkerLayerOptions(markers: model.markers)
                ],
              ),
              model.gas_legend_index < model.gas_legend.length
                  ? Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        height: screenHeight * 0.2,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.all(Radius.circular(36)),
                        ),
                        child: Image.asset(
                          model.gas_legend.values.elementAt(model.gas_legend_index),
                          fit: BoxFit.fill,
                        ),
                      ),
                    )
                  : Container(),

              Align(
                alignment: Alignment.bottomCenter,
                child: ExploreWidget(
                  title: isExploreOpen ? "Weather Forecast" : "Weather",
                  icon: iconWeather,
                  currentExplorePercent: currentExplorePercent,
                  currentSearchPercent: currentSearchPercent,
                  animateExplore: animateExplore,
                  isExploreOpen: isExploreOpen,
                  onVerticalDragUpdate: onExploreVerticalUpdate,
                  onPanDown: () => animationControllerExplore?.stop(),
                ),
              ),
              //explore content
              ExploreContentWidget(
                currentExplorePercent: currentExplorePercent,
              ),

              //search menu background
              offsetSearch != 0
                  ? Positioned(
                      bottom: realH(88),
                      right: realW((standardWidth - 320) / 2),
                      width: realW(320),
                      height: realH(400 * currentSearchPercent),
                      child: Opacity(
                        opacity: currentSearchPercent,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(realW(33)), topRight: Radius.circular(realW(33)))),
                        ),
                      ),
                    )
                  : const Padding(
                      padding: const EdgeInsets.all(0),
                    ),
              //search menu
              SearchMenuWidget(
                currentSearchPercent: currentSearchPercent,
                gas: model.gas,
                onCurrentSearchChanged: model.onCurrentSearchChanged,
              ),
              //search
              SearchWidget(
                mainIcon: iconMenu,
                currentSearchPercent: currentSearchPercent,
                currentExplorePercent: currentExplorePercent,
                isSearchOpen: isSearchOpen,
                animateSearch: animateSearch,
                onHorizontalDragUpdate: onSearchHorizontalDragUpdate,
                onPanDown: () => animationControllerSearch?.stop(),
              ),

              MapButton(
                currentSearchPercent: currentSearchPercent,
                currentExplorePercent: currentExplorePercent,
                bottom: 148,
                offsetX: -68,
                width: 68,
                height: 71,
                childWidget: model.loadingDataFromBackend ? CircularProgressIndicator() : iconRefresh,
                onButtonClicked: () async {
                  model.refresh();
                },
              ),
            ],
          ),
        ),
      ),
    );
  
  }
}
