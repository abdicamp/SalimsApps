import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';
import 'package:salims_apps_new/core/api_response.dart';
import 'package:salims_apps_new/core/models/login_models.dart';
import 'package:salims_apps_new/core/services/api_services.dart';
import 'package:salims_apps_new/core/services/local_storage_services.dart';
import 'package:salims_apps_new/ui/views/bottom_navigator_view.dart';
import 'package:stacked/stacked.dart';

class LoginViewModel extends FutureViewModel {
  BuildContext? context;
  LoginViewModel({this.context});

  final ApiService _apiServices = ApiService();
  final LocalStorageService _storage = LocalStorageService();
  Position? userPosition;
  ApiResponse<LoginResponse>? apiResponse;

  bool isRequestingPermission = false;

  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // Logger
  var logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  // ===============================
  // Fungsi Login
  // ===============================
  doLogin() async {
    try {
      setBusy(true);

      // 1️⃣ Cek izin lokasi
      final hasLocationPermission = await checkLocationPermission();
      if (!hasLocationPermission) {
        logger.w("Location permission denied");
        return; // hentikan login
      }

      // 2️⃣ Lakukan login
      final result = await _apiServices.login(
        usernameController.text,
        passwordController.text,
      );

      apiResponse = result;

      if (result.data != null) {
        await _storage.saveLoginData(result.data!);
        logger.i("User login successful: ${result.data!.data.username}");
        Navigator.of(context!).pushReplacement(
          MaterialPageRoute(builder: (context) => BottomNavigatorView()),
        );
      } else {
        logger.w("Login failed: ${result.error}");
        ScaffoldMessenger.of(context!).showSnackBar(
          SnackBar(
            duration: Duration(seconds: 2),
            content: Text("${result.error}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e, stackTrace) {
      logger.e(
        "Error login",
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  // ===============================
  // Fungsi cek izin lokasi
  // ===============================
  Future<bool> checkLocationPermission() async {
    if (isRequestingPermission) {
      logger.w("Still waiting for previous permission request.");
      return false;
    }

    isRequestingPermission = true;

    try {
      // ✅ Pastikan GPS aktif
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) return false;
      }

      // ✅ Cek permission
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return false;
      }

      if (permission == LocationPermission.deniedForever) {
        // ❌ User menolak permanen
        _showPermissionDialog();
        return false;
      }

      return true; // izin diberikan
    } catch (e, stackTrace) {
      logger.e(
        "Error checking location permission",
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    } finally {
      isRequestingPermission = false;
    }
  }

  // ===============================
  // Dialog jika user menolak izin permanen
  // ===============================
  void _showPermissionDialog() {
    if (context == null) return;

    showDialog(
      context: context!,
      builder: (context) => AlertDialog(
        title: Text("Izin Lokasi Diperlukan"),
        content: Text(
          "Anda menolak izin lokasi secara permanen. "
          "Silakan aktifkan izin lokasi di pengaturan aplikasi."
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              Geolocator.openAppSettings();
              Navigator.pop(context);
            },
            child: Text("Buka Pengaturan"),
          ),
        ],
      ),
    );
  }

  @override
  Future futureToRun() async {}
}
