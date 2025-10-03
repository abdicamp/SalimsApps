import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:salims_apps_new/core/api_response.dart';
import 'package:salims_apps_new/core/models/equipment_response_models.dart';
import 'package:salims_apps_new/core/models/login_models.dart';
import 'package:salims_apps_new/core/models/sample_location_models.dart';
import 'package:salims_apps_new/core/models/unit_response_models.dart';
import 'package:salims_apps_new/core/services/local_Storage_Services.dart';

class ApiService {
  final String baseUrl = "https://api-salims.chemitechlogilab.com/v1";
  final LocalStorageService _storage = LocalStorageService();

  Future<ApiResponse<LoginResponse>> login(
    String username,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final loginResponse = LoginResponse.fromJson(data);
        return ApiResponse.success(loginResponse);
      } else {
        return ApiResponse.error("Login gagal: ${response.statusCode}");
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
        Uri.parse("$baseUrl/general/get-equipment/${getData?.data.branchcode}"),
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
}
