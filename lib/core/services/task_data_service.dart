import 'package:collection/collection.dart';
import 'package:logger/logger.dart';
import '../../../core/models/equipment_response_models.dart';
import '../../../core/models/parameter_models.dart';
import '../../../core/models/sample_models.dart';

/// Service untuk menangani fetch dan parse data dari API
class TaskDataService {
  final Logger logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  /// Parse parameter data dari response
  List<TestingOrderParameter> parseParameterData(dynamic response) {
    final dataPars = response?.data?['data']?['testing_order_parameters'];

    if (dataPars is List) {
      return dataPars
          .map((e) =>
              TestingOrderParameter.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Parse equipment data dari response
  List<Equipment> parseEquipmentData(dynamic response) {
    final dataEquipments = response?.data?['data']?['testing_order_equipment'];

    if (dataEquipments is List) {
      return dataEquipments
          .map((e) => Equipment.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Parse task images dari response
  Map<String, List<String>> parseTaskImages(Map<String, dynamic> response) {
    final imageString = <String>[];
    final imageOldString = <String>[];
    final imageStringVerifiy = <String>[];
    final imageOldStringVerifiy = <String>[];

    if (response['documents'] != null && response['documents'] is List) {
      for (var url in response['documents']) {
        if (url != null && url['pathname'] != null && url['pathname'] != "") {
          imageString.add(url['pathname'].toString());
          imageOldString.add(url['pathname'].toString());
        }
        if (url['pathname_verifikasi'] != "" &&
            url['pathname_verifikasi'] != null) {
          imageStringVerifiy.add(url['pathname_verifikasi'].toString());
          imageOldStringVerifiy.add(url['pathname_verifikasi'].toString());
        }
      }
    }

    return {
      'imageString': imageString,
      'imageOldString': imageOldString,
      'imageStringVerifiy': imageStringVerifiy,
      'imageOldStringVerifiy': imageOldStringVerifiy,
    };
  }

  /// Parse task parameters dari response
  List<TakingSampleParameter> parseTaskParameters(
    Map<String, dynamic> response,
    List<TestingOrderParameter> listParameter,
  ) {
    final result = <TakingSampleParameter>[];

    if (response['taking_sample_parameters'] != null &&
        response['taking_sample_parameters'] is List) {
      for (var item in response['taking_sample_parameters']) {
        try {
          result.add(TakingSampleParameter.fromJson(item));

          final index = listParameter.indexWhere(
            (element) => element.parcode == item['parcode'],
          );

          if (index != -1 && item['parcode'] == listParameter[index].parcode) {
            listParameter.removeAt(index);
          }
        } catch (e) {
          logger.w('Error parsing parameter', error: e);
        }
      }
    }

    return result;
  }

  /// Parse task CI dari response
  List<TakingSampleCI> parseTaskCI(
    Map<String, dynamic> response,
    List<Equipment> equipmentlist,
  ) {
    final result = <TakingSampleCI>[];

    if (response['taking_sample_ci'] != null &&
        response['taking_sample_ci'] is List) {
      for (var item in response['taking_sample_ci']) {
        try {
          result.add(TakingSampleCI.fromJson(item));

          final index = equipmentlist.indexWhere(
            (element) => element.equipmentcode == item['equipmentcode'],
          );

          if (index != -1 &&
              item['equipmentcode'] == equipmentlist[index].equipmentcode) {
            equipmentlist.removeAt(index);
          }
        } catch (e) {
          logger.w('Error parsing CI', error: e);
        }
      }
    }

    return result;
  }

  /// Validate parameters
  bool validateParameters({
    required String? tsnumber,
    required List<TestingOrderParameter> listParameter,
    required List<TakingSampleParameter> listTakingSampleParameter,
  }) {
    if (tsnumber == '' || listParameter.isEmpty) {
      return false;
    }

    final groupedData = groupBy(
      listTakingSampleParameter,
      (item) => item.parcode?.toString().trim().toUpperCase() ?? '',
    );

    final groupedKeys = groupedData.keys.toList();
    final parameterCodes = listParameter
        .map((e) => e.parcode?.toString().trim().toUpperCase() ?? '')
        .toList();

    return parameterCodes.every((code) => groupedKeys.contains(code));
  }
}

