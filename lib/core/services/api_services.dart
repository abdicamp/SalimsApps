import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:salims_apps_new/core/api_response.dart';
import 'package:salims_apps_new/core/models/equipment_response_models.dart';
import 'package:salims_apps_new/core/models/login_models.dart';
import 'package:salims_apps_new/core/models/parameter_models.dart';
import 'package:salims_apps_new/core/models/sample_location_models.dart';
import 'package:salims_apps_new/core/models/sample_models.dart';
import 'package:salims_apps_new/core/models/task_list_models.dart';
import 'package:salims_apps_new/core/models/unit_response_models.dart';
import 'package:salims_apps_new/core/services/local_Storage_Services.dart';

import '../models/task_list_history_models.dart';
import '../models/testing_order_history_models.dart';
import '../models/notification_models.dart';

class ApiService {
  // final String baseUrl = "https://lims.pdam-sby.go.id/v1";
  final String baseUrl = "https://api-salims.chemitechlogilab.com/v1";
  final LocalStorageService _storage = LocalStorageService();
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

  // Callback untuk handle token expired (auto logout)
  static Function()? onTokenExpired;

  // Set callback untuk token expired
  static void setTokenExpiredCallback(Function() callback) {
    onTokenExpired = callback;
  }

  // Handle token expired - clear storage dan trigger logout
  Future<void> _handleTokenExpired() async {
    try {
      logger.w("Token expired, clearing storage and logging out");
      await _storage.clear();

      // Trigger callback jika ada
      if (onTokenExpired != null) {
        onTokenExpired!();
      }
    } catch (e) {
      logger.e("Error handling token expired: $e");
    }
  }

  // Check jika response adalah token expired (401 atau 403)
  Future<bool> _checkAndHandleTokenExpired(http.Response response) async {
    // Cek HTTP status code
    if (response.statusCode == 401 || response.statusCode == 403) {
      await _handleTokenExpired();
      return true;
    }

    // Cek response body untuk token expired indicator
    try {
      final responseData = jsonDecode(response.body);
      final message = responseData['message']?.toString().toLowerCase() ?? '';
      final error = responseData['error']?.toString().toLowerCase() ?? '';
      final msg = responseData['msg']?.toString().toLowerCase() ?? '';

      if (message.contains('token') &&
          (message.contains('expired') ||
              message.contains('invalid') ||
              message.contains('unauthorized'))) {
        await _handleTokenExpired();
        return true;
      }

      if (error.contains('token') &&
          (error.contains('expired') ||
              error.contains('invalid') ||
              error.contains('unauthorized'))) {
        await _handleTokenExpired();
        return true;
      }

      if (msg.contains('token') &&
          (msg.contains('expired') ||
              msg.contains('invalid') ||
              msg.contains('unauthorized'))) {
        await _handleTokenExpired();
        return true;
      }
    } catch (e) {
      // Jika tidak bisa parse JSON, skip check response body
    }

    return false;
  }

  Future<bool> cekToken() async {
    try {
      final getData = await _storage.getUserData();
      if (getData == null || getData.data == null) {
        return false;
      }

      final response = await http.get(
        Uri.parse("$baseUrl/auth/check-token/${getData.data?.username}"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${getData.accessToken}",
        },
      );

      // Check token expired
      final isTokenExpired = await _checkAndHandleTokenExpired(response);
      if (isTokenExpired) {
        return false;
      }

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<ApiResponse<LoginResponse>> login(
    String username,
    String password,
    String token,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "password": password,
          "token_fcm": "${token}"
        }),
      );
      print("token fcmm : ${token}");
      print("json data login : ${response.body}");

      // Parse response body terlepas dari HTTP status code
      try {
        final data = jsonDecode(response.body);

        final loginResponse = LoginResponse.fromJson(data);

        // Cek status dari JSON response body
        if (response.statusCode == 200 && loginResponse.status == true) {
          return ApiResponse.success(loginResponse);
        } else {
          // Handle error response (status false atau HTTP status code bukan 200)
          String errorMessage = "Login gagal";

          if (loginResponse.msg != null && loginResponse.msg!.isNotEmpty) {
            // Jika msg mengandung '|', ambil bagian setelah '|'
            if (loginResponse.msg!.contains('|')) {
              final parts = loginResponse.msg!.split('|');
              errorMessage = parts.length > 1 ? parts[1] : parts[0];
            } else {
              // Jika tidak ada '|', langsung gunakan msg
              errorMessage = loginResponse.msg!;
            }
          }

          logger.w("Login Api failed: ${response.body}");
          return ApiResponse.error(errorMessage);
        }
      } catch (e) {
        logger.e("Error parsing login response: $e");
        return ApiResponse.error("Login gagal: Error parsing response");
      }
    } catch (e) {
      return ApiResponse.error("Unexpected Error: $e");
    }
  }

  Future<ApiResponse<TaskListModels>?> getTaskList(
      String? dateFrom, String? dateTo) async {
    try {
      final getData = await _storage.getUserData();
      print(
          "${baseUrl}/transaction/taking-sample/testing-order?labourcode=${getData?.data?.labourcode}&dateFrom=${dateFrom}&dateTo=${dateTo}&branchcode=${getData?.data?.branchcode}");
      final response = await http.get(
        Uri.parse(
            "${baseUrl}/transaction/taking-sample/testing-order?labourcode=${getData?.data?.labourcode}&dateFrom=${dateFrom}&dateTo=${dateTo}&branchcode=${getData?.data?.branchcode}"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${getData?.accessToken}",
        },
      );

      // Check token expired
      final isTokenExpired = await _checkAndHandleTokenExpired(response);
      if (isTokenExpired) {
        return ApiResponse.error("Session expired. Please login again.");
      }
      print("response: ${response.body}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Cek status dari JSON response body
        final status = data['status'];
        final code = data['code'];

        if (status == false && code == 404) {
          // Return empty array untuk status false dan code 404
          final emptyResponse = TaskListModels(
            status: false,
            code: 404,
            message: data['message'] ?? "Data not found",
            data: [],
          );
          return ApiResponse.success(emptyResponse);
        }

        final taskListResponse = TaskListModels.fromJson(data);
        return ApiResponse.success(taskListResponse);
      } else if (response.statusCode == 404) {
        final data = jsonDecode(response.body);
        // Cek status dari JSON response body
        final status = data['status'];
        final code = data['code'];
        final emptyResponse = TaskListModels(
          status: false,
          code: 404,
          message: data['message'] ?? "Data not found",
          data: [],
        );
        return ApiResponse.success(emptyResponse);
      } else {
        return ApiResponse.error("Failed get data: ${response.statusCode}");
      }
    } catch (e) {
      return ApiResponse.error("Unexpected Error: $e");
    }
  }

  Future<ApiResponse<TaskListModels>?> getTaskListHistory(
      String? filterDate) async {
    try {
      final getData = await _storage.getUserData();

      if (getData == null || getData.data == null) {
        logger.w("User data is null in getTaskListHistory");
        return ApiResponse.error("User data not found");
      }

      // Bangun URL dengan query parameters (karena GET tidak bisa body)
      final uri = Uri.parse(
        "${baseUrl}/transaction/taking-sample/testing-order-sampling-date?branchcode=${getData.data?.branchcode}&samplingby=${getData.data?.username}",
      );

      final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${getData.accessToken}",
        },
      );

      // Check token expired
      final isTokenExpired = await _checkAndHandleTokenExpired(response);
      if (isTokenExpired) {
        return ApiResponse.error("Session expired. Please login again.");
      }

      // Parse response body terlepas dari HTTP status code
      // Model sudah bisa handle status false dan data kosong dengan baik
      try {
        final data = jsonDecode(response.body);
        final taskListResponse = TaskListModels.fromJson(data);

        return ApiResponse.success(taskListResponse);
      } catch (e) {
        logger.e("Error parsing JSON in getTaskListHistory: $e");
        // Jika tidak bisa parse JSON, return error dengan HTTP status code
        return ApiResponse.error("Failed get data: ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      logger.e("Error in getTaskListHistory", error: e, stackTrace: stackTrace);
      return ApiResponse.error("Unexpected Error: $e");
    }
  }

  Future<dynamic> getOneTaskList(String? tsNumber) async {
    try {
      final getData = await _storage.getUserData();
      print("tsNumber: ${tsNumber}");
      print(
          "baseUrl: ${baseUrl}/transaction/taking-sample/one/${getData?.data?.branchcode}?tsnumber=${tsNumber}");
      final response = await http.get(
        Uri.parse(
            "${baseUrl}/transaction/taking-sample/one/${getData?.data?.branchcode}?tsnumber=${tsNumber}"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${getData?.accessToken}",
        },
      );
      // Check token expired
      final isTokenExpired = await _checkAndHandleTokenExpired(response);
      if (isTokenExpired) {
        return ApiResponse.error("Session expired. Please login again.");
      }

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'];
      } else {
        return ApiResponse.error("Failed get data: ${response.statusCode}");
      }
    } catch (e) {
      return ApiResponse.error("Unexpected Error: $e");
    }
  }

  Future<ApiResponse<SampleLocationResponse>?> getSampleLoc() async {
    try {
      final getData = await _storage.getUserData();
      final response = await http.get(
        Uri.parse("$baseUrl/general/get-sample-location"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${getData?.accessToken}",
        },
      );

      // Check token expired
      final isTokenExpired = await _checkAndHandleTokenExpired(response);
      if (isTokenExpired) {
        return ApiResponse.error("Session expired. Please login again.");
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Cek status dari JSON response body
        final status = data['status'];
        final code = data['code'];

        if (status == false && code == 404) {
          // Return empty array untuk status false dan code 404
          final emptyResponse = SampleLocationResponse(
            status: false,
            code: 404,
            message: data['message'] ?? "Data not found",
            data: [],
          );
          return ApiResponse.success(emptyResponse);
        }

        final sampleResponse = SampleLocationResponse.fromJson(data);
        return ApiResponse.success(sampleResponse);
      } else {
        return ApiResponse.error("Failed get data: ${response.statusCode}");
      }
    } catch (e) {
      return ApiResponse.error("Unexpected Error: $e");
    }
  }

  Future<ApiResponse<EquipmentResponse>?> getEquipment() async {
    try {
      final getData = await _storage.getUserData();
      final response = await http.get(
        Uri.parse(
            "$baseUrl/general/get-equipment/${getData?.data?.branchcode}"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${getData?.accessToken}",
        },
      );

      // Check token expired
      final isTokenExpired = await _checkAndHandleTokenExpired(response);
      if (isTokenExpired) {
        return ApiResponse.error("Session expired. Please login again.");
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Cek status dari JSON response body
        final status = data['status'];
        final code = data['code'];

        if (status == false && code == 404) {
          // Return empty array untuk status false dan code 404
          final emptyResponse = EquipmentResponse(
            status: false,
            code: 404,
            message: data['message'] ?? "Data not found",
            data: [],
          );
          return ApiResponse.success(emptyResponse);
        }

        final equipmentResponse = EquipmentResponse.fromJson(data);
        return ApiResponse.success(equipmentResponse);
      } else {
        return ApiResponse.error("Failed get data: ${response.statusCode}");
      }
    } catch (e) {
      return ApiResponse.error("Unexpected Error: $e");
    }
  }

  Future<ApiResponse<UnitResponse>?> getUnitList() async {
    try {
      final getData = await _storage.getUserData();
      final response = await http.get(
        Uri.parse("$baseUrl/general/get-units"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${getData?.accessToken}",
        },
      );

      // Check token expired
      final isTokenExpired = await _checkAndHandleTokenExpired(response);
      if (isTokenExpired) {
        return ApiResponse.error("Session expired. Please login again.");
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Cek status dari JSON response body
        final status = data['status'];
        final code = data['code'];

        if (status == false && code == 404) {
          // Return empty array untuk status false dan code 404
          final emptyResponse = UnitResponse(
            status: false,
            code: 404,
            message: data['message'] ?? "Data not found",
            data: [],
          );
          return ApiResponse.success(emptyResponse);
        }

        final unitListResponse = UnitResponse.fromJson(data);
        return ApiResponse.success(unitListResponse);
      } else {
        return ApiResponse.error("Failed get data: ${response.statusCode}");
      }
    } catch (e) {
      return ApiResponse.error("Unexpected Error: $e");
    }
  }

  Future<ApiResponse<dynamic>?> getParameterAndEquipment(
      String? ptsNumber, String? sampleNo) async {
    try {
      final getData = await _storage.getUserData();
      final response = await http.get(
        Uri.parse(
            "$baseUrl/transaction/taking-sample/testing-order-parameter?branchcode=${getData?.data?.branchcode}&pts_number=${ptsNumber}&sampleno=${sampleNo}"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${getData?.accessToken}",
        },
      );

      // Check token expired
      final isTokenExpired = await _checkAndHandleTokenExpired(response);
      if (isTokenExpired) {
        return ApiResponse.error("Session expired. Please login again.");
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Cek status dari JSON response body
        final status = data['status'];
        final code = data['code'];

        if (status == false && code == 404) {
          // Return empty data untuk status false dan code 404
          final emptyData = {
            "status": false,
            "code": 404,
            "message": data['message'] ?? "Data not found",
            "data": {},
          };
          return ApiResponse.success(emptyData);
        }

        return ApiResponse.success(data);
      } else {
        return ApiResponse.error("Failed get data: ${response.statusCode}");
      }
    } catch (e) {
      return ApiResponse.error("Unexpected Error: $e");
    }
  }

  Future<ApiResponse<dynamic>> postTakingSample(SampleDetail? sample) async {
    try {
      final getData = await _storage.getUserData();

      if (sample?.tsnumber == "" || sample?.tsnumber == null) {
        final response = await http.post(
            Uri.parse("$baseUrl/transaction/taking-sample/store"),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer ${getData?.accessToken}",
            },
            body: jsonEncode(sample));

        // Check token expired
        final isTokenExpired = await _checkAndHandleTokenExpired(response);
        if (isTokenExpired) {
          return ApiResponse.error("Session expired. Please login again.");
        }

        final data = jsonDecode(response.body);
        print("response body post: ${response.body}");
        if (response.statusCode == 201 || response.statusCode == 200) {
          return ApiResponse.success(data);
        } else {
          return ApiResponse.error(
              'Error ${data['code']} : ${data['message']}');
        }
      } else {
        final response = await http.put(
            Uri.parse("$baseUrl/transaction/taking-sample/update"),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer ${getData?.accessToken}",
            },
            body: jsonEncode(sample));

        // Check token expired
        final isTokenExpired = await _checkAndHandleTokenExpired(response);
        if (isTokenExpired) {
          return ApiResponse.error("Session expired. Please login again.");
        }

        logger.w("post failed: ${response.body}");
        final data = jsonDecode(response.body);
        if (response.statusCode == 200) {
          return ApiResponse.success(data);
        } else {
          return ApiResponse.error(
              'Error ${data['code']} : ${data['message']}');
        }
      }
    } catch (e) {
      return ApiResponse.error('Error : ${e}');
    }
  }

  Future<ApiResponse<dynamic>> updateStatus(dynamic datas) async {
    try {
      final getData = await _storage.getUserData();

      final Map<String, dynamic> dataJson = {
        "tranidx": "1206",
        'branchcode': '${getData?.data?.branchcode}',
        'tsnumber': '${datas['tsnumber']}',
        'tsdate': '${datas['tsdate']}',
        'ptsnumber': '${datas['ptsnumber']}',
        'sampleno': '${datas['sampleno']}',
        'user': '${getData?.data?.username}',
        'appstatus': 'APPROVED',
        'appdescription': 'Finish',
      };

      final response = await http.put(
          Uri.parse("$baseUrl/transaction/taking-sample/update-app-status"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer ${getData?.accessToken}",
          },
          body: jsonEncode(dataJson));

      // Check token expired
      final isTokenExpired = await _checkAndHandleTokenExpired(response);
      if (isTokenExpired) {
        return ApiResponse.error("Session expired. Please login again.");
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse.success(data);
      } else {
        return ApiResponse.error('Error ${data['code']} : ${data['message']}');
      }
    } catch (e) {
      return ApiResponse.error('Error : ${e}');
    }
  }

  Future<dynamic> chagePassword(
      String? oldPassword, String? newPassword) async {
    try {
      final getData = await _storage.getUserData();
      final Map<String, dynamic> dataJson = {
        "username": "${getData?.data?.username}",
        'password_old': '${oldPassword}',
        'password_confirm': '${newPassword}',
      };

      final response =
          await http.put(Uri.parse("$baseUrl/auth/update-password"),
              headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer ${getData?.accessToken}",
              },
              body: jsonEncode(dataJson));

      // Check token expired
      final isTokenExpired = await _checkAndHandleTokenExpired(response);
      if (isTokenExpired) {
        return "Session expired. Please login again.";
      }

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return responseData;
      } else {
        return responseData;
      }
    } catch (e) {
      return "Error : ${e}";
    }
  }

  Future<ApiResponse<NotificationHistoryModels>?>
      getNotificationHistory() async {
    try {
      final getData = await _storage.getUserData();

      // Get zonaauthority from user data
      final zonaauthority = getData?.data?.zonaauthority;

      if (zonaauthority == null || zonaauthority.isEmpty) {
        return ApiResponse.error("Zona authority tidak ditemukan");
      }

      // Build URL with zonacode query parameter
      final uri = Uri.parse(
        "$baseUrl/notification/history?zonacode=$zonaauthority",
      );

      final response = await http.get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${getData?.accessToken}",
        },
      );

      // Check token expired
      final isTokenExpired = await _checkAndHandleTokenExpired(response);
      if (isTokenExpired) {
        return ApiResponse.error("Session expired. Please login again.");
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Cek status dari JSON response body
        final status = data['status'];
        final code = data['code'];

        if (status == false && code == 404) {
          // Return empty array untuk status false dan code 404
          final emptyData = NotificationData(data: [], pagination: null);
          final emptyResponse = NotificationHistoryModels(
            status: false,
            code: 404,
            message: data['message'] ?? "Data not found",
            data: emptyData,
            error: data['error'],
          );
          return ApiResponse.success(emptyResponse);
        }

        final notificationResponse = NotificationHistoryModels.fromJson(data);
        return ApiResponse.success(notificationResponse);
      } else {
        return ApiResponse.error("Failed get data: ${response.statusCode}");
      }
    } catch (e) {
      logger.e("Error getNotificationHistory: $e");
      return ApiResponse.error("Unexpected Error: $e");
    }
  }

  Future<ApiResponse<dynamic>> logout() async {
    try {
      final getData = await _storage.getUserData();

      if (getData == null || getData.data == null) {
        return ApiResponse.error("User data not found");
      }

      final username = getData.data?.username;

      if (username == null || username.isEmpty) {
        return ApiResponse.error("Username not found");
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse("$baseUrl/auth/logout"),
      );

      request.headers['Authorization'] = 'Bearer ${getData.accessToken}';
      request.fields['username'] = username;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          return ApiResponse.success(data);
        } catch (e) {
          return ApiResponse.success({"message": "Logout successful"});
        }
      } else {
        try {
          final data = jsonDecode(response.body);
          final errorMessage = data['message'] ?? data['msg'] ?? "Logout failed";
          return ApiResponse.error(errorMessage);
        } catch (e) {
          return ApiResponse.error("Logout failed: ${response.statusCode}");
        }
      }
    } catch (e) {
      logger.e("Error logout: $e");
      return ApiResponse.error("Unexpected Error: $e");
    }
  }

}
