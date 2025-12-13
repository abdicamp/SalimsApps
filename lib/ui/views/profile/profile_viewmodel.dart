import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
<<<<<<< HEAD
=======
import 'package:http/http.dart';
>>>>>>> d9307d58676fc9c28c83e0c350d87b25294391cb
import 'package:salims_apps_new/core/services/api_services.dart';
import 'package:salims_apps_new/core/services/local_Storage_Services.dart';
import 'package:salims_apps_new/core/utils/app_localizations.dart';
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
<<<<<<< HEAD
  String? phone;
  String? email;
  String? profileImage;
=======
>>>>>>> d9307d58676fc9c28c83e0c350d87b25294391cb
  bool? isChangePassword = false;
  bool? isShowPasswordOld = false;
  bool? isShowPasswordNew = false;

  getDataUser() async {
    final prefGetData = await localStorageService.getUserData();
<<<<<<< HEAD
    username = prefGetData?.data?.username;
    phone = prefGetData?.data?.detail?.phone;
    email = prefGetData?.data?.detail?.email;
    profileImage = prefGetData?.data?.profileImage;
=======
    username = prefGetData!.data?.username;
>>>>>>> d9307d58676fc9c28c83e0c350d87b25294391cb
    notifyListeners();
  }

  changePassword() async {
    setBusy(true);
    try {
      final response = await _apiServices.chagePassword(
          oldPassword?.text, newPassword?.text);

      if (response['status'] == true) {
        ScaffoldMessenger.of(ctx!).showSnackBar(
          SnackBar(
            duration: Duration(seconds: 2),
            content: Text("${response['msg']} , ${AppLocalizations.of(ctx!)?.pleaseLoginAgain ?? "Please login again"}!"),
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
          content: Text("${AppLocalizations.of(ctx!)?.errorChangePassword ?? "Error changing password"}: ${e}"),
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
