import 'package:flutter/material.dart';
import 'package:salims_apps_new/core/services/local_Storage_Services.dart';
import 'package:salims_apps_new/ui/views/splash_screen/splash_screen_view.dart';
import 'package:stacked/stacked.dart';

import '../../../core/services/api_services.dart';

class HomeViewmodel extends FutureViewModel {
  BuildContext? context;
  HomeViewmodel({this.context});
  final LocalStorageService _storage = LocalStorageService();
  ApiService apiService = new ApiService();
  String? username = '';
  int totalListTask = 3;
  int totalListTaskHistory = 5;
  double? totalPerforma;

  getUserData() async {
    setBusy(true);
    try {
      await Future.delayed(Duration(seconds: 1));
      final getData = await _storage.getUserData();
      username = getData?.data?.username;

      setBusy(true);
      notifyListeners();
    } catch (e) {
      setBusy(false);
      notifyListeners();
      print("Error get data : ${e}");
    }
  }

  getMonthlyReport() {
    totalPerforma = totalListTask / totalListTaskHistory;
    notifyListeners();
  }

  logout() async {
    try {
      setBusy(true);
      await Future.delayed(Duration(seconds: 3));
      await _storage.clear();
      Navigator.of(context!).pushReplacement(
        MaterialPageRoute(builder: (context) => SplashScreenView()),
      );
      setBusy(false);

      notifyListeners();
    } catch (e) {
      print("error : ${e}");
      setBusy(false);

      notifyListeners();
    }
  }

  runAllFunction() async {
    final cekToken = await apiService.cekToken();

    if (cekToken) {
      await getMonthlyReport();
      await getUserData();
    } else {
      await _storage.clear();
      Navigator.of(context!).pushReplacement(
          new MaterialPageRoute(builder: (context) => SplashScreenView()));
      notifyListeners();
      setBusy(false);
    }
  }

  @override
  Future futureToRun() async {
    await runAllFunction();
  }
}
