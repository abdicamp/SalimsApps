import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';
import 'package:salims_apps_new/core/api_response.dart';
import 'package:salims_apps_new/core/models/login_models.dart';
import 'package:salims_apps_new/core/services/api_services.dart';
import 'package:salims_apps_new/core/services/local_storage_services.dart';
import 'package:salims_apps_new/core/utils/app_localizations.dart';
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
  // Fungsi untuk mendapatkan FCM token dengan retry
  // ===============================
  Future<String?> _getFCMToken() async {
    try {
      // 1. Pastikan permission sudah diberikan
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      
      logger.i("Notification permission status: ${settings.authorizationStatus}");
      
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        logger.w("Notification permission denied");
        return null;
      }
      
      // 2. Untuk iOS, coba tunggu APNS token (tapi jangan block jika null di simulator)
      if (Platform.isIOS) {
        String? apnsToken;
        int retryCount = 0;
        const maxRetries = 10; // Tambah retry untuk memberi waktu lebih lama
        
        while (apnsToken == null && retryCount < maxRetries) {
          apnsToken = await FirebaseMessaging.instance.getAPNSToken();
          if (apnsToken == null) {
            retryCount++;
            logger.w("APNS token belum tersedia, retry ke-$retryCount/$maxRetries");
            await Future.delayed(const Duration(milliseconds: 1000));
          } else {
            logger.i("APNS token berhasil didapat: $apnsToken");
            break;
          }
        }
        
        // Di simulator, APNS token akan null, tapi kita tetap coba get FCM token
        if (apnsToken == null) {
          logger.w("APNS token masih null setelah $maxRetries retry (mungkin di simulator atau belum dikonfigurasi). Tetap mencoba mendapatkan FCM token...");
        }
      }
      
      // 3. Dapatkan FCM token dengan retry
      String? token;
      int tokenRetryCount = 0;
      const maxTokenRetries = 3;
      
      while (token == null && tokenRetryCount < maxTokenRetries) {
        try {
          token = await FirebaseMessaging.instance.getToken();
          if (token != null) {
            logger.i("FCM token berhasil didapat: $token");
            return token;
          } else {
            logger.w("FCM token null, retry ke-${tokenRetryCount + 1}/$maxTokenRetries");
            tokenRetryCount++;
            if (tokenRetryCount < maxTokenRetries) {
              await Future.delayed(const Duration(milliseconds: 1000));
            }
          }
        } catch (tokenError, tokenStackTrace) {
          logger.w(
            "Error getting FCM token (attempt ${tokenRetryCount + 1}/$maxTokenRetries): $tokenError",
          );
          
          final errorString = tokenError.toString();
          
          // Jika error karena APNS token tidak tersedia (iOS)
          if (errorString.contains('apns-token-not-set') || 
              errorString.contains('APNS token has not been set')) {
            logger.w("APNS token belum tersedia. Ini normal di simulator atau jika Push Notifications belum dikonfigurasi di Xcode.");
            // Tidak retry lagi jika APNS token tidak tersedia
            break;
          }
          
          // Jika error SERVICE_NOT_AVAILABLE (Android - Google Play Services tidak tersedia)
          if (errorString.contains('SERVICE_NOT_AVAILABLE') || 
              errorString.contains('SERVICE_NOT_AVAILABLE')) {
            logger.w("Google Play Services tidak tersedia atau tidak ter-update.");
            logger.w("Ini mungkin terjadi di emulator tanpa Google Play Services atau device tanpa Google Play.");
            // Tidak retry lagi untuk SERVICE_NOT_AVAILABLE
            break;
          }
          
          tokenRetryCount++;
          if (tokenRetryCount < maxTokenRetries) {
            await Future.delayed(const Duration(milliseconds: 1000));
          } else {
            // Log full error pada retry terakhir
            logger.e(
              "Failed to get FCM token after $maxTokenRetries attempts",
              error: tokenError,
              stackTrace: tokenStackTrace,
            );
          }
        }
      }
      
      logger.w("FCM token tidak dapat diperoleh setelah $maxTokenRetries attempts");
      return null;
    } catch (e, stackTrace) {
      logger.e(
        "Error getting FCM token",
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  // ===============================
  // Fungsi Login
  // ===============================
  doLogin() async {
    try {
      setBusy(true);
      
      // Dapatkan FCM token
      final token = await _getFCMToken();
      if (token == null || token.isEmpty) {
        logger.w("FCM token tidak dapat diperoleh. Tidak dapat melanjutkan login.");
        final currentContext = context;
        if (currentContext != null) {
          final errorMessage = Platform.isIOS 
            ? "Gagal mendapatkan token notifikasi.\n\nPastikan:\n1. Push Notifications capability diaktifkan di Xcode\n2. Izin notifikasi sudah diberikan\n3. Jika di simulator, gunakan device fisik untuk testing"
            : "Gagal mendapatkan token notifikasi. Pastikan izin notifikasi sudah diberikan.";
          
          ScaffoldMessenger.of(currentContext).showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 5),
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final hasLocationPermission = await checkLocationPermission();
      if (!hasLocationPermission) {
        logger.w("Location permission denied");
        return;
      }

      final result = await _apiServices.login(
        usernameController.text,
        passwordController.text,
        token,
      );
      logger.i("token: $token");
      apiResponse = result;

      if (result.data != null) {
        await _storage.saveLoginData(result.data!);
        logger.i("User login successful: ${jsonEncode(result.data!.data)}");
        
        final currentContext = context;
        if (currentContext != null) {
          Navigator.of(currentContext).pushReplacement(
            MaterialPageRoute(builder: (context) => BottomNavigatorView()),
          );
        }
      } else {
        final errorMessage = result.error ?? "Login gagal. Silakan coba lagi.";
        logger.w("Login failed: $errorMessage");
        
        final currentContext = context;
        if (currentContext != null) {
          ScaffoldMessenger.of(currentContext).showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 2),
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      logger.e(
        "Error login",
        error: e,
        stackTrace: stackTrace,
      );
      
      final currentContext = context;
      if (currentContext != null) {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          SnackBar(
            duration: Duration(seconds: 2),
            content: Text(AppLocalizations.of(currentContext)?.loginError ?? "An error occurred during login. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
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
    final currentContext = context;
    if (currentContext == null) return;

    showDialog(
      context: currentContext,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(currentContext)?.locationPermissionRequired ?? "Location Permission Required"),
        content: Text(AppLocalizations.of(currentContext)?.locationPermissionDeniedPermanently ?? "You have permanently denied location permission. Please enable location permission in app settings."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppLocalizations.of(currentContext)?.cancel ?? "Cancel"),
          ),
          TextButton(
            onPressed: () {
              Geolocator.openAppSettings();
              Navigator.pop(dialogContext);
            },
            child: Text(AppLocalizations.of(currentContext)?.openSettings ?? "Open Settings"),
          ),
        ],
      ),
    );
  }

  @override
  Future futureToRun() async {}
}
