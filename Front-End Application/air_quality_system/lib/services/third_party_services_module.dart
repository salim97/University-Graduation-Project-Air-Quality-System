import 'package:injectable/injectable.dart';
import 'package:stacked_services/stacked_services.dart';

import 'firebase_auth.dart';
import 'firestore_db.dart';

@registerModule
abstract class ThirdPartyServicesModule {
  @lazySingleton
  NavigationService get navigationService;
  @lazySingleton
  DialogService get dialogService;
}
