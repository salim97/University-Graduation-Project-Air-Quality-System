import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:stacked/stacked.dart';
import 'home_model.dart';
import 'package:latlong/latlong.dart';

import '../../widgets/home/components.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

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

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    if (screenWidth > standardWidth && kIsWeb) {
      screenWidth = standardWidth;
    }
    if (screenHeight > standardHeight && kIsWeb) {
      screenHeight = standardHeight;
    }

    return ViewModelBuilder<HomeViewModel>.reactive(
      builder: (context, model, child) => kIsWeb
          ? webUI(context, model, child)
          : WillPopScope(
                  onWillPop: () async {
                    if(model.dataTable != null) {
                      model.dataTable = null;
                      model.notifyListeners();
                      return false;
                    }
                    else
                    return true ;
        // return false;
      },
                      child: Scaffold(
                body: Center(
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
                        ExploreWidget(
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
                          currentSearchPercent: currentSearchPercent,
                          currentExplorePercent: currentExplorePercent,
                          isSearchOpen: isSearchOpen,
                          animateSearch: animateSearch,
                          onHorizontalDragUpdate: onSearchHorizontalDragUpdate,
                          onPanDown: () => animationControllerSearch?.stop(),
                        ),

                        // //layer button
                        // MapButton(
                        //   currentExplorePercent: currentExplorePercent,
                        //   currentSearchPercent: currentSearchPercent,
                        //   bottom: 243,
                        //   offsetX: -71,
                        //   width: 71,
                        //   height: 71,
                        //   isRight: false,
                        //   icon: Icons.layers,
                        //   onButtonClicked: (){
                        //     print("hahowa");
                        //   }
                        // ),
                        // //directions button
                        // MapButton(
                        //   currentSearchPercent: currentSearchPercent,
                        //   currentExplorePercent: currentExplorePercent,
                        //   bottom: 243,
                        //   offsetX: -68,
                        //   width: 68,
                        //   height: 71,
                        //   icon: Icons.directions,
                        //   iconColor: Colors.white,
                        //   gradient: const LinearGradient(colors: [
                        //     Color(0xFF59C2FF),
                        //     Color(0xFF1270E3),
                        //   ]),
                        // ),
                        //my_location button

                        MapButton(
                          currentSearchPercent: currentSearchPercent,
                          currentExplorePercent: currentExplorePercent,
                          bottom: 148,
                          offsetX: -68,
                          width: 68,
                          height: 71,
                          childWidget: model.loadingDataFromBackend
                              ? CircularProgressIndicator()
                              : Icon(
                                  Icons.refresh,
                                  size: realW(34),
                                  color: Colors.blue,
                                ),
                          onButtonClicked: () async {
                            // model.loadingDataFromBackend = true;
                            // model.notifyListeners();
                            model.refresh();
                            // model.loadingDataFromBackend = false;
                            // model.notifyListeners();
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
                                child: Icon(
                                  Icons.menu,
                                  size: realW(34),
                                ),
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
                          name: "Benda Benda",
                          phoneNumber: "06666666666",
                        ),

                        /*       Positioned(
                        bottom: 0,
                        left: MediaQuery.of(context).size.width * 0.25,
                        child: Container(
              decoration: BoxDecoration(color: Colors.white),
              child: DropdownButton(
                value: model.currentGas,
                items: model.dropDownMenuItems,
                onChanged: model.changedDropDownItem,
              ),
                        )),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      //  height: MediaQuery.of(context).size.height * 0.50,
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: Image.asset(
                        // "assets/images/legend_Temperature.png",
                        model.currentGasLegend
                      ),
                    ), */

                        model.dataTable != null ? Positioned.fill(
                          child: Align(
                            alignment: Alignment.center,
                            child: Container(
                              width: screenWidth * 0.8,
                              height: screenHeight * 0.8,
                              decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.75),
                                  borderRadius: BorderRadius.all(Radius.circular(realW(36))),
                                  boxShadow: [
                                    BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.3), blurRadius: realW(36)),
                                  ]),
                              child: model.dataTable,
                            ),
                          ),
                        ) : Container()
                      ],
                    ),
                  ),
                ),
              ),
          ),
      viewModelBuilder: () => HomeViewModel(),
      onModelReady: (model) =>
          model.initState(), // TODO: khrebch fiha apre, prc initstate ta3 fluter w hadi custom je pense pas 3andhom meme behavior
    );
  }

  webUI(context, model, child) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: screenWidth,
          height: screenHeight,
          child: Stack(
            children: <Widget>[
              FlutterMap(
                mapController: model.mapController,
                options: MapOptions(
                  center: LatLng(35.691124, -0.618778),
                  zoom: 14,
                ),
                layers: [
                  TileLayerOptions(
                    urlTemplate: "https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c'],
                  ),
                  MarkerLayerOptions(markers: model.markers),
                ],
              ),
              ExploreWidget(
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
              //ZOOM IN
              MapButton(
                  currentExplorePercent: currentExplorePercent,
                  currentSearchPercent: currentSearchPercent,
                  bottom: 243,
                  offsetX: -71,
                  width: 71,
                  height: 71,
                  isRight: true,
                  icon: Icons.zoom_in,
                  onButtonClicked: () {
                    model.mapController.move(model.mapController.center, model.mapController.zoom + 1);
                  }),
              //ZOOM OUT
              MapButton(
                  currentExplorePercent: currentExplorePercent,
                  currentSearchPercent: currentSearchPercent,
                  bottom: 148,
                  offsetX: -71,
                  width: 71,
                  height: 71,
                  isRight: true,
                  icon: Icons.zoom_out,
                  onButtonClicked: () {
                    model.mapController.move(model.mapController.center, model.mapController.zoom - 1);
                  }),
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
                currentSearchPercent: currentSearchPercent,
                currentExplorePercent: currentExplorePercent,
                isSearchOpen: isSearchOpen,
                animateSearch: animateSearch,
                onHorizontalDragUpdate: onSearchHorizontalDragUpdate,
                onPanDown: () => animationControllerSearch?.stop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
