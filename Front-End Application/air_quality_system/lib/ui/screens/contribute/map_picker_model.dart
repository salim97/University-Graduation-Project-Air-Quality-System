import 'dart:async';
import 'dart:math';

import 'package:air_quality_system/ui/widgets/home/components.dart';
import 'package:android_intent/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stacked/stacked.dart';

class MapPickerViewModel extends BaseViewModel {
  final PermissionHandler permissionHandler = PermissionHandler();
  Map<PermissionGroup, PermissionStatus> permissions;

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{}; // CLASS MEMBER, MAP OF MARKS
  GoogleMapController googleMapController;

  // Location location = new Location();

  final MarkerId _userMarkerID = MarkerId("userLocation");
  get userMarker => markers[_userMarkerID];
  set userMarker(marker) => markers[_userMarkerID] = marker;
  void initState() {
    requestLocationPermission();
    _gpsService();
    getUserPosition();
    // _listenLocation();
  }

  // LocationData _currentUserLocation = null;
  // LocationData get currentUserLocation => _currentUserLocation;
  // set currentUserLocation(LocationData currentUserLocation) {
  //   if (_currentUserLocation == null) {
  //     // setUserPosition(LatLng(currentUserLocation.latitude, currentUserLocation.longitude));
  //     getUserPosition();
  //   }
  //   _currentUserLocation = currentUserLocation;
  // }

  // StreamSubscription<LocationData> _locationSubscription;
  // String _error;

  // Future<void> _listenLocation() async {
  //   _locationSubscription = location.onLocationChanged.handleError((dynamic err) {
  //     print(err);

  //     _error = err.code;
  //     notifyListeners();
  //     _locationSubscription.cancel();
  //   }).listen((LocationData currentLocation) {
  //     _error = null;

  //     currentUserLocation = currentLocation;
  //     notifyListeners();
  //   });
  // }

  // Future<void> _stopListen() async {
  //   _locationSubscription.cancel();
  // }

  setUserPosition(LatLng position) {
    googleMapController.moveCamera(CameraUpdate.newLatLng(position));
    Marker marker = Marker(
      markerId: _userMarkerID,
      position: position,
      infoWindow: InfoWindow(title: "Your location", snippet: '*'),
    );
    userMarker = marker;
    notifyListeners();
  }

  bool gettingUserPosition = false;
  void getUserPosition() async {
    gettingUserPosition = true;
    notifyListeners();

    // if (currentUserLocation == null) currentUserLocation = await location.getLocation();
    // var currentUserPosition = await location.getLocation();
    // setUserPosition(LatLng(currentUserLocation.latitude, currentUserLocation.longitude));
    Position p = await Geolocator().getCurrentPosition();
    setUserPosition(LatLng(p.latitude, p.longitude));
    gettingUserPosition = false;
    notifyListeners();
  }

/*Check if gps service is enabled or not*/
  Future _gpsService() async {
    if (!(await Geolocator().isLocationServiceEnabled())) {
      _checkGps();
      return null;
    } else
      return true;
  }

  Future<bool> _requestPermission(PermissionGroup permission) async {
    final PermissionHandler _permissionHandler = PermissionHandler();
    var result = await _permissionHandler.requestPermissions([permission]);
    if (result[permission] == PermissionStatus.granted) {
      return true;
    }
    return false;
  }

/*Checking if your App has been Given Permission*/
  Future<bool> requestLocationPermission({Function onPermissionDenied}) async {
    var granted = await _requestPermission(PermissionGroup.location);
    if (granted != true) {
      requestLocationPermission();
    }
    debugPrint('requestContactsPermission $granted');
    return granted;
  }

/*Show dialog if GPS not enabled and open settings location*/
  Future _checkGps() async {
    if (!(await Geolocator().isLocationServiceEnabled())) {
//   if (Theme.of(context).platform == TargetPlatform.android) {
// showDialog(
//    context: context,
//    builder: (BuildContext context) {
//     return AlertDialog(
//      title: Text("Can't get gurrent location"),
//      content:const Text('Please make sure you enable GPS and try again'),
//      actions: <Widget>[
//        FlatButton(child: Text('Ok'),
//        onPressed: () {
//          final AndroidIntent intent = AndroidIntent(
//           action: 'android.settings.LOCATION_SOURCE_SETTINGS');
//        intent.launch();
//        Navigator.of(context, rootNavigator: true).pop();
//        _gpsService();
//       })],
//      );
//    });

//   }
      final AndroidIntent intent = AndroidIntent(action: 'android.settings.LOCATION_SOURCE_SETTINGS');
      await intent.launch();
      // Navigator.of(context, rootNavigator: true).pop();
      _gpsService();
    }
  }
}

// void getUserPosition() async {
//   gettingUserPosition = true;
//   notifyListeners();
//   // bool _serviceEnabled = await location.serviceEnabled();
//   // if (!_serviceEnabled) {
//   //   _serviceEnabled = await location.requestService();
//   //   if (!_serviceEnabled) {
//   //     print("NIKMOK");
//   //     _btnControllerGPS.error();
//   //     return;
//   //   }
//   // }

//   // _permissionGranted = await location.hasPermission();
//   // if (_permissionGranted == PermissionStatus.denied) {
//   //   _permissionGranted = await location.requestPermission();
//   //   if (_permissionGranted != PermissionStatus.granted) {
//   //     print("NIKMOK");
//   //     _btnControllerGPS.error();
//   //     return;
//   //   }
//   // }
//   print(_error);
//   if (_location == null) _location = await location.getLocation();
//   // var currentUserPosition = await location.getLocation();
//   setUserPosition(LatLng(_location.latitude, _location.longitude));

//   gettingUserPosition = false;
//   notifyListeners();

//   // final AndroidIntent intent = new AndroidIntent(
//   //   action: 'android.settings.LOCATION_SOURCE_SETTINGS',
//   // );
//   // await intent.launch();
//   // serviceStatus = await LocationPermissions().checkServiceStatus();

//   // _btnControllerGPS.success();
//   // _btnControllerGPS.reset();
// }
