import 'package:flutter/material.dart';
import 'package:salims_apps_new/core/utils/app_localizations.dart';
import '../../../core/models/equipment_response_models.dart';
import '../../../core/models/parameter_models.dart';
import '../../../core/models/sample_models.dart';
import '../../../core/models/task_list_models.dart';

/// Service untuk menangani semua validasi
class ValidationService {
  /// Validasi CardTaskInfo (form fields + gambar)
  bool validateCardTaskInfo({
    required GlobalKey<FormState> formKey1,
    required TestingOrder? listTaskList,
    required int totalSampleImagesNew,
    required int totalSampleImagesOld,
    required int totalSampleImages,
    required int imageStringVerifiyLength,
    required int imageOldStringVerifiyLength,
  }) {
    if (!formKey1.currentState!.validate()) {
      return false;
    }

    final isNewTask =
        listTaskList?.tsnumber == null || listTaskList?.tsnumber == "";

    if (isNewTask) {
      if (totalSampleImagesNew == 0) {
        return false;
      }
      if (imageStringVerifiyLength == 0) {
        return false;
      }
    } else {
      if (totalSampleImages == 0) {
        return false;
      }
      if (imageOldStringVerifiyLength == 0) {
        return false;
      }
    }

    return true;
  }

  /// Validasi CardTaskContainer
  bool validateCardTaskContainer({
    required List<Equipment> equipmentlist,
    required List<TakingSampleCI> listTakingSampleCI,
    required TestingOrder? listTaskList,
  }) {
    if (equipmentlist.isEmpty) {
      return true;
    }

    final hasTsnumber =
        listTaskList?.tsnumber != null && listTaskList!.tsnumber != "";

    if (hasTsnumber) {
      if (listTakingSampleCI.isEmpty) {
        return false;
      }
      return _isAllEquipmentInList(equipmentlist, listTakingSampleCI);
    } else {
      return listTakingSampleCI.isNotEmpty;
    }
  }

  /// Cek apakah semua equipment sudah masuk ke listTakingSampleCI
  bool _isAllEquipmentInList(
    List<Equipment> equipmentlist,
    List<TakingSampleCI> listTakingSampleCI,
  ) {
    if (equipmentlist.isEmpty) return true;
    if (listTakingSampleCI.isEmpty) return false;

    final equipmentCodes = equipmentlist
        .map((e) => e.equipmentcode.toString().trim().toUpperCase())
        .toList();

    final ciEquipmentCodes = listTakingSampleCI
        .map((e) => e.equipmentcode?.toString().trim().toUpperCase() ?? '')
        .toList();

    return equipmentCodes.every((code) => ciEquipmentCodes.contains(code));
  }

  /// Validasi CardTaskParameter
  bool validateCardTaskParameter({
    required List<TestingOrderParameter> listParameter,
    required List<TakingSampleParameter> listTakingSampleParameter,
    required TestingOrder? listTaskList,
  }) {
    if (listParameter.isEmpty) {
      return true;
    }

    final hasTsnumber =
        listTaskList?.tsnumber != null && listTaskList!.tsnumber != "";

    if (hasTsnumber) {
      if (listTakingSampleParameter.isEmpty) {
        return false;
      }
      return _isAllParameterInList(listParameter, listTakingSampleParameter);
    } else {
      return listTakingSampleParameter.isNotEmpty;
    }
  }

  /// Cek apakah semua parameter sudah masuk ke listTakingSampleParameter
  bool _isAllParameterInList(
    List<TestingOrderParameter> listParameter,
    List<TakingSampleParameter> listTakingSampleParameter,
  ) {
    if (listParameter.isEmpty) return true;
    if (listTakingSampleParameter.isEmpty) return false;

    final parameterCodes = listParameter
        .map((e) => e.parcode?.toString().trim().toUpperCase() ?? '')
        .toList();

    final sampleParameterCodes = listTakingSampleParameter
        .map((e) => e.parcode?.toString().trim().toUpperCase() ?? '')
        .toList();

    return parameterCodes.every((code) => sampleParameterCodes.contains(code));
  }

  /// Validasi form sebelum save
  String? validateBeforeSave({
    required BuildContext context,
    required GlobalKey<FormState> formKey1,
    required TestingOrder? listTaskList,
    required int totalSampleImagesNew,
    required int totalSampleImagesOld,
    required int totalSampleImages,
    required int imageStringVerifiyLength,
    required int imageOldStringVerifiyLength,
    required List<Equipment> equipmentlist,
    required List<TakingSampleCI> listTakingSampleCI,
    required bool Function() isAllEquipmentInList,
    required List<TestingOrderParameter> listParameter,
    required List<TakingSampleParameter> listTakingSampleParameter,
    required bool Function() isAllParameterInList,
  }) {
    final isNewTask =
        listTaskList?.tsnumber == null || listTaskList!.tsnumber == "";

    if (totalSampleImagesNew == 0 && isNewTask) {
      return AppLocalizations.of(context)?.imageCannotBeEmpty ??
          "Gambar sample tidak boleh kosong. Minimal harus ada 1 gambar sample.";
    }

    if (totalSampleImages == 0 && !isNewTask) {
      return AppLocalizations.of(context)?.imageCannotBeEmpty ??
          "Gambar sample tidak boleh kosong. Minimal harus ada 1 gambar sample (baru atau lama).";
    }

    if (imageStringVerifiyLength == 0 && isNewTask) {
      return AppLocalizations.of(context)?.imageCannotBeEmpty ??
          "Gambar verifikasi tidak boleh kosong. imageStringVerifiy wajib untuk task baru.";
    }

    if (imageOldStringVerifiyLength == 0 && !isNewTask) {
      return AppLocalizations.of(context)?.imageCannotBeEmpty ??
          "Gambar verifikasi tidak boleh kosong. imageOldStringVerifiy wajib untuk task existing.";
    }

    if (equipmentlist.isNotEmpty && listTakingSampleCI.isEmpty) {
      return AppLocalizations.of(context)?.formContainerInfoEmpty ??
          "Form Container Info is Empty";
    }

    if (equipmentlist.isNotEmpty && !isAllEquipmentInList()) {
      return AppLocalizations.of(context)?.formContainerInfoEmpty ??
          "Form Container Info is Empty";
    }

    if (listParameter.isNotEmpty && listTakingSampleParameter.isEmpty) {
      return AppLocalizations.of(context)?.formParameterEmpty ??
          "Form Parameter is Empty";
    }

    if (listParameter.isNotEmpty && !isAllParameterInList()) {
      return AppLocalizations.of(context)?.formParameterEmpty ??
          "Form Parameter is Empty";
    }

    return null;
  }
}

