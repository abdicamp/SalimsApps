import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:salims_apps_new/core/services/api_services.dart';
import 'package:salims_apps_new/core/services/local_Storage_Services.dart';
import 'package:salims_apps_new/ui/views/splash_screen/splash_screen_view.dart';
import 'package:stacked/stacked.dart';

class ProfileViewModel extends FutureViewModel {
  BuildContext? ctx;
  LocalStorageService localStorageService = new LocalStorageService();
  TextEditingController? oldPassword = new TextEditingController();
  TextEditingController? newPassword = new TextEditingController();

  ProfileViewModel({this.ctx});

  final ApiService _apiServices = ApiService();

  String? username;
  bool? isChangePassword = false;
  bool? isShowPasswordOld = false;
  bool? isShowPasswordNew = false;

  getDataUser() async {
    final prefGetData = await localStorageService.getUserData();
    username = prefGetData!.data?.username;
    notifyListeners();
  }

  changePassword() async {
    setBusy(true);
    try {
      final response = await _apiServices.chagePassword(
          oldPassword?.text, newPassword?.text);
      print("response.data viewmodel : ${response}");

      if (response['status'] == true) {
        ScaffoldMessenger.of(ctx!).showSnackBar(
          SnackBar(
            duration: Duration(seconds: 2),
            content: Text("${response['msg']} , Please login again !"),
            backgroundColor: Colors.green,
          ),
        );
        await localStorageService.clear();
        setBusy(false);
        Navigator.of(ctx!).pushReplacement(
          MaterialPageRoute(builder: (context) => SplashScreenView()),
        );

        notifyListeners();
      } else {
        ScaffoldMessenger.of(ctx!).showSnackBar(
          SnackBar(
            duration: Duration(seconds: 2),
            content: Text("${response['msg']}"),
            backgroundColor: Colors.red,
          ),
        );
        setBusy(false);
        notifyListeners();
      }
    } catch (e) {
      ScaffoldMessenger.of(ctx!).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 2),
          content: Text("Error change password :${e}"),
          backgroundColor: Colors.red,
        ),
      );
      setBusy(false);
      notifyListeners();
    }
  }

  @override
  Future futureToRun() async {
    await getDataUser();
  }
}
