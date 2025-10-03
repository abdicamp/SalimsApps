import 'package:flutter/material.dart';
import 'package:salims_apps_new/core/services/local_Storage_Services.dart';
import 'package:salims_apps_new/ui/views/splash_screen/splash_screen_view.dart';
import 'package:stacked/stacked.dart';

class HomeViewmodel extends FutureViewModel {
  BuildContext? context;
  HomeViewmodel({this.context});
  final LocalStorageService _storage = LocalStorageService();
  String? username = '';

  getUserData() async {
    setBusy(true);
    try {
      await Future.delayed(Duration(seconds: 1));
      final getData = await _storage.getUserData();
      username = getData?.data.username;

      setBusy(true);
      notifyListeners();
    } catch (e) {
      setBusy(false);
      notifyListeners();
      print("Error get data : ${e}");
    }
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

  @override
  Future futureToRun() async {
    await getUserData();
  }
}
