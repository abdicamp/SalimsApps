import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:salims_apps_new/core/api_response.dart';
import 'package:salims_apps_new/core/models/equipment_response_models.dart';
import 'package:salims_apps_new/core/models/login_models.dart';
import 'package:salims_apps_new/core/models/parameter_models.dart';
import 'package:salims_apps_new/core/models/sample_location_models.dart';
import 'package:salims_apps_new/core/models/task_list_models.dart';
import 'package:salims_apps_new/core/models/unit_response_models.dart';
import 'package:salims_apps_new/core/services/local_Storage_Services.dart';

import '../models/task_list_history_models.dart';

class ApiService {
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

  Future<bool> cekToken() async {
    try {
      final getData = await _storage.getUserData();
      final response = await http.get(
        Uri.parse("$baseUrl/auth/check-token/${getData?.data?.username}"),
      );

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
        Uri.parse("$baseUrl/auth/login-customer-user"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "password": password,
          "token_fcm": "${token}"
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final loginResponse = LoginResponse.fromJson(data);
        return ApiResponse.success(loginResponse);
      } else {
        logger.w("Login Api failed: ${response.body}");
        final loginResponse = LoginResponse.fromJson(jsonDecode(response.body));
        return ApiResponse.error("Login gagal: ${loginResponse.msg}");
      }
    } catch (e) {
      return ApiResponse.error("Unexpected Error: $e");
    }
  }

  Future<ApiResponse<TaskListModels>?> getTaskList() async {
    try {
      final getData = await _storage.getUserData();
      final response = await http.get(
        Uri.parse(
            "$baseUrl/transaction/taking-sample/testing-order/${getData?.data?.branchcode}"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${getData?.accessToken}",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final taskListResponse = TaskListModels.fromJson(data);
        print("sampleResponse : ${jsonEncode(taskListResponse)}");
        return ApiResponse.success(taskListResponse);
      } else {
        return ApiResponse.error("Failed get data: ${response.statusCode}");
      }
    } catch (e) {
      return ApiResponse.error("Unexpected Error: $e");
    }
  }

  Future<ApiResponse<TaskListHistoryModels>?> getTaskListHistory() async {
    try {
      final getData = await _storage.getUserData();
      final response = await http.get(
        Uri.parse(
            "$baseUrl/transaction/taking-sample/testing-order-sampling-date/${getData?.data?.branchcode}"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${getData?.accessToken}",
        },
      );

      print("response.statusCode : ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final taskListHistory = TaskListHistoryModels.fromJson(data);
        print("taskListHistory : ${jsonEncode(taskListHistory)}");
        return ApiResponse.success(taskListHistory);
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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final sampleResponse = SampleLocationResponse.fromJson(data);
        print("sampleResponse : ${jsonEncode(sampleResponse)}");
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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final unitListResponse = UnitResponse.fromJson(data);

        return ApiResponse.success(unitListResponse);
      } else {
        return ApiResponse.error("Failed get data: ${response.statusCode}");
      }
    } catch (e) {
      return ApiResponse.error("Unexpected Error: $e");
    }
  }

  Future<ApiResponse<ParameterModels>?> getParameter(
      String? reqNumber, String? sampleNo) async {
    try {
      final getData = await _storage.getUserData();
      final response = await http.get(
        Uri.parse(
            "$baseUrl/transaction/taking-sample/testing-order-parameters/${getData?.data?.branchcode}?reqnumber=${reqNumber}&sampleno=${sampleNo}"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${getData?.accessToken}",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final parameterResponse = ParameterModels.fromJson(data);

        return ApiResponse.success(parameterResponse);
      } else {
        return ApiResponse.error("Failed get data: ${response.statusCode}");
      }
    } catch (e) {
      return ApiResponse.error("Unexpected Error: $e");
    }
  }
}
