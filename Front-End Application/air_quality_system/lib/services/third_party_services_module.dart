// run this command on terminal each time you edit this file
// flutter pub run build_runner build --delete-conflicting-outputs

import 'package:injectable/injectable.dart';
import 'package:stacked_services/stacked_services.dart';

import 'Rest_API.dart';
import 'firebase_auth.dart';
import 'firestore_db.dart';
import 'gps.dart';
import 'localNetworkEngine.dart';

@module
abstract class ThirdPartyServicesModule {
  @lazySingleton
  NavigationService get navigationService;
  @lazySingleton
  DialogService get dialogService;
  @lazySingleton
  SnackbarService get snackbarService;

  @lazySingleton
  MyFirebaseAuthService get myFirebaseAuth;
  @lazySingleton
  MyFirestoreDBService get myFirestoreDB;
  @lazySingleton
  MyGPSService get myGPS;
  @lazySingleton
  RestAPIService get restAPI;
  @lazySingleton
  LocalNetworkEngineService get localNetworkEngine;
  
  
}
