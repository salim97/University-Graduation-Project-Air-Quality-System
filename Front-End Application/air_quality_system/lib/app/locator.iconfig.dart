// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:air_quality_system/services/third_party_services_module.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:air_quality_system/services/localNetworkEngine.dart';
import 'package:air_quality_system/services/firebase_auth.dart';
import 'package:air_quality_system/services/firestore_db.dart';
import 'package:air_quality_system/services/gps.dart';
import 'package:air_quality_system/services/Rest_API.dart';
import 'package:get_it/get_it.dart';

void $initGetIt(GetIt g, {String environment}) {
  final thirdPartyServicesModule = _$ThirdPartyServicesModule();
  g.registerLazySingleton<DialogService>(
      () => thirdPartyServicesModule.dialogService);
  g.registerLazySingleton<LocalNetworkEngineService>(
      () => thirdPartyServicesModule.localNetworkEngine);
  g.registerLazySingleton<MyFirebaseAuthService>(
      () => thirdPartyServicesModule.myFirebaseAuth);
  g.registerLazySingleton<MyFirestoreDBService>(
      () => thirdPartyServicesModule.myFirestoreDB);
  g.registerLazySingleton<MyGPSService>(() => thirdPartyServicesModule.myGPS);
  g.registerLazySingleton<NavigationService>(
      () => thirdPartyServicesModule.navigationService);
  g.registerLazySingleton<RestAPIService>(
      () => thirdPartyServicesModule.restAPI);
  g.registerLazySingleton<SnackbarService>(
      () => thirdPartyServicesModule.snackbarService);
}

class _$ThirdPartyServicesModule extends ThirdPartyServicesModule {
  @override
  DialogService get dialogService => DialogService();
  @override
  LocalNetworkEngineService get localNetworkEngine =>
      LocalNetworkEngineService();
  @override
  MyFirebaseAuthService get myFirebaseAuth => MyFirebaseAuthService();
  @override
  MyFirestoreDBService get myFirestoreDB => MyFirestoreDBService();
  @override
  MyGPSService get myGPS => MyGPSService();
  @override
  NavigationService get navigationService => NavigationService();
  @override
  RestAPIService get restAPI => RestAPIService();
  @override
  SnackbarService get snackbarService => SnackbarService();
}
