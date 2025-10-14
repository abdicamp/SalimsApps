import 'package:salims_apps_new/core/services/local_Storage_Services.dart';
import 'package:stacked/stacked.dart';

class ProfileViewModel extends FutureViewModel {
  LocalStorageService localStorageService = new LocalStorageService();
  String? username;

  getDataUser() async {
    final prefGetData = await localStorageService.getUserData();
    username = prefGetData!.data?.username;
    notifyListeners();
  }

  @override
  Future futureToRun() async {
    await getDataUser();
  }
}
