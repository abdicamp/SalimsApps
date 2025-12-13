import 'dart:convert';
import 'package:salims_apps_new/core/models/login_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const _keyAccessToken = "access_token";
  static const String _loginKey = "login_response";
  static const String _lastCheckedNotificationId = "last_checked_notification_id";

  Future<void> saveLoginData(LoginResponse login) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(
      login.toJson(),
    ); // simpan sebagai string JSON
    await prefs.setString(_loginKey, jsonString);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAccessToken);
  }

  Future<LoginResponse?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_loginKey);
    if (jsonString != null) {
      return LoginResponse.fromJson(jsonDecode(jsonString));
    }
    return null;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> saveLastCheckedNotificationId(int notificationId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastCheckedNotificationId, notificationId);
  }

  Future<int?> getLastCheckedNotificationId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_lastCheckedNotificationId);
  }
}
