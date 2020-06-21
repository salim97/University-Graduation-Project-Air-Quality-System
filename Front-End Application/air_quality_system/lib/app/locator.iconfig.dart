// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:air_quality_system/services/third_party_services_module.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:air_quality_system/services/firebase_auth.dart';
import 'package:air_quality_system/services/firestore_db.dart';
import 'package:air_quality_system/services/gps.dart';
import 'package:get_it/get_it.dart';

void $initGetIt(GetIt g, {String environment}) {
  final thirdPartyServicesModule = _$ThirdPartyServicesModule();
  g.registerLazySingleton<DialogService>(
      () => thirdPartyServicesModule.dialogService);
  g.registerLazySingleton<MyFirebaseAuth>(() => MyFirebaseAuth());
  g.registerLazySingleton<MyFirestoreDB>(() => MyFirestoreDB());
  g.registerLazySingleton<MyGPS>(() => MyGPS());
  g.registerLazySingleton<NavigationService>(
      () => thirdPartyServicesModule.navigationService);
  g.registerLazySingleton<SnackbarService>(
      () => thirdPartyServicesModule.snackbarService);
}

class _$ThirdPartyServicesModule extends ThirdPartyServicesModule {
  @override
  DialogService get dialogService => DialogService();
  @override
  NavigationService get navigationService => NavigationService();
  @override
  SnackbarService get snackbarService => SnackbarService();
}
