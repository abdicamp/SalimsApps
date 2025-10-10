import 'package:flutter/material.dart';
import 'package:salims_apps_new/core/services/local_Storage_Services.dart';
import 'package:salims_apps_new/ui/views/bottom_navigator_view.dart';
import 'package:salims_apps_new/ui/views/login/login_view.dart';
import 'package:stacked/stacked.dart';

import '../../../core/services/api_services.dart';

class SplashScreenViewmodel extends FutureViewModel {
  BuildContext? context;
  final LocalStorageService _storage = LocalStorageService();
  ApiService apiService = new ApiService();

  SplashScreenViewmodel({this.context});

  getUserData() async {
    setBusy(true);
    try {
      await Future.delayed(Duration(seconds: 1));
      final getData = await _storage.getUserData();
      final cekToke = await apiService.cekToken();

      if (getData != null) {
        if (cekToke) {
          Navigator.of(context!).pushReplacement(
            MaterialPageRoute(builder: (context) => BottomNavigatorView()),
          );
          setBusy(false);
          notifyListeners();
        } else {
          await _storage.clear();
          Navigator.of(context!).pushReplacement(
              new MaterialPageRoute(builder: (context) => LoginView()));
          notifyListeners();
          setBusy(false);
        }
      } else {
        Navigator.of(
          context!,
        ).pushReplacement(MaterialPageRoute(builder: (context) => LoginView()));
        setBusy(false);
        notifyListeners();
      }
    } catch (e) {
      setBusy(false);
      notifyListeners();
      print("Error get data : ${e}");
    }
  }

  @override
  Future futureToRun() async {
    await getUserData();
  }
}
