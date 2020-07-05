// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:air_quality_system/services/third_party_services_module.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:air_quality_system/services/firebase_auth.dart';
import 'package:air_quality_system/services/firestore_db.dart';
import 'package:air_quality_system/services/gps.dart';
import 'package:air_quality_system/services/Rest_API.dart';
import 'package:get_it/get_it.dart';

void $initGetIt(GetIt g, {String environment}) {
  final thirdPartyServicesModule = _$ThirdPartyServicesModule();
  g.registerLazySingleton<DialogService>(
      () => thirdPartyServicesModule.dialogService);
  g.registerLazySingleton<MyFirebaseAuth>(
      () => thirdPartyServicesModule.myFirebaseAuth);
  g.registerLazySingleton<MyFirestoreDB>(
      () => thirdPartyServicesModule.myFirestoreDB);
  g.registerLazySingleton<MyGPS>(() => thirdPartyServicesModule.myGPS);
  g.registerLazySingleton<NavigationService>(
      () => thirdPartyServicesModule.navigationService);
  g.registerLazySingleton<RestAPI>(() => thirdPartyServicesModule.restAPI);
  g.registerLazySingleton<SnackbarService>(
      () => thirdPartyServicesModule.snackbarService);
}

class _$ThirdPartyServicesModule extends ThirdPartyServicesModule {
  @override
  DialogService get dialogService => DialogService();
  @override
  MyFirebaseAuth get myFirebaseAuth => MyFirebaseAuth();
  @override
  MyFirestoreDB get myFirestoreDB => MyFirestoreDB();
  @override
  MyGPS get myGPS => MyGPS();
  @override
  NavigationService get navigationService => NavigationService();
  @override
  RestAPI get restAPI => RestAPI();
  @override
  SnackbarService get snackbarService => SnackbarService();
}
