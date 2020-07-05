// run this command on terminal each time you edit this file
// flutter pub run build_runner build

import 'package:injectable/injectable.dart';
import 'package:stacked_services/stacked_services.dart';

import 'Rest_API.dart';
import 'firebase_auth.dart';
import 'firestore_db.dart';
import 'gps.dart';

@module
abstract class ThirdPartyServicesModule {
  @lazySingleton
  NavigationService get navigationService;
  @lazySingleton
  DialogService get dialogService;
  @lazySingleton
  SnackbarService get snackbarService;

  @lazySingleton
  MyFirebaseAuth get myFirebaseAuth;
  @lazySingleton
  MyFirestoreDB get myFirestoreDB;
  @lazySingleton
  MyGPS get myGPS;
  @lazySingleton
  RestAPI get restAPI;
  
}
