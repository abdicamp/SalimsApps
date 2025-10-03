import 'package:flutter/material.dart';
import 'package:salims_apps_new/core/api_response.dart';
import 'package:salims_apps_new/core/models/login_models.dart';
import 'package:salims_apps_new/core/services/api_services.dart';
import 'package:salims_apps_new/core/services/local_storage_services.dart';
import 'package:salims_apps_new/ui/views/bottom_navigator_view.dart';
import 'package:salims_apps_new/ui/views/home/home_view.dart';
import 'package:salims_apps_new/ui/views/splash_screen/splash_screen_view.dart';
import 'package:stacked/stacked.dart';

class LoginViewModel extends FutureViewModel {
  BuildContext? context;
  LoginViewModel({this.context});
  final ApiService _apiServices = ApiService();
  final LocalStorageService _storage = LocalStorageService();

  ApiResponse<LoginResponse>? apiResponse;

  TextEditingController? usernameontroller = new TextEditingController();
  TextEditingController? passwordController = new TextEditingController();

  doLogin() async {
    try {
      setBusy(true);
      await Future.delayed(Duration(seconds: 1));
      final result = await _apiServices.login(
        usernameontroller!.text,
        passwordController!.text,
      );

      apiResponse = result;
      notifyListeners();

      if (result.data != null) {
        await _storage.saveLoginData(result.data!);
        Navigator.of(context!).pushReplacement(
          MaterialPageRoute(builder: (context) => BottomNavigatorView()),
        );
      } else {
        ScaffoldMessenger.of(context!).showSnackBar(
          SnackBar(
            duration: Duration(seconds: 2),
            content: Text("${result.error}"),
            backgroundColor: Colors.red,
          ),
        );
      }

      setBusy(false);
    } catch (e) {
      print("Error login : ${e}");
    }
  }

  @override
  Future futureToRun() async {}
}
