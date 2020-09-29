import 'package:stacked/stacked.dart';

import '../../../services/locator.dart';
import '../../../services/device/permission_service.dart';
import '../../../services/auth/user_service.dart';
import '../../../services/local_storage/local_database.dart';
import '../../../services/network/connectivity.dart';
import '../../../services/auth/auth_service.dart';
import '../../../repositories/contacts_repo/contacts_repository.dart';

import '../../../core/routes/router.dart';

class LoadingViewModel extends BaseViewModel {
  // get all services
  final router = locator<Router>();
  final permission = locator<PermissionService>();
  final user = locator<UserService>();
  final localDB = locator<LocalDatabase>();
  final auth = locator<AuthService>();
  final contactsRepo = locator<ContactsRepository>();
  final connectivity = locator<ConnectivityService>();

  /// call once after the model is construct
  Future<void> initalise() async {
    // evoke init tasks
    await runInitTasks();
  }

  /// run app services initial tasks
  Future<void> runInitTasks() async {
    await connectivity.initConnectivity();
    // init local storage sqlite db
    await localDB.asyncInitDB();
    // request device permissions
    await permission.requestPermissions();
    // init auth service
    await auth.initAuth();
    // init user service
    await user.initUserService();
    // init contacts repo
    await contactsRepo.initalise();

    // if authenticated navigate main page, else navigate log-in page
    if (auth.isAuthenticated) {
      // navigate main page
      router.navigateMainPage();
    } else {
      // navigate login page
      router.navigateLoginPage();
    }
  }
}
