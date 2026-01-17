import 'dart:convert';

import 'package:salims_apps_new/core/models/parameter_models.dart';
import '../../../core/models/sample_models.dart';
import '../../../core/models/formula_exec_models.dart';

/// Service untuk menangani operasi parameter
class ParameterService {
  /// Tambahkan parameter ke list
  void addListParameter({
    required int incrementDetailNoPar,
    required Function(int) setIncrementDetailNoPar,
    required List<TakingSampleParameter> listTakingSampleParameter,
    required ParameterEquipmentDetail? parameterEquipmentSelect,
    required List<TestingOrderParameter> listParameter,
    required TestingOrderParameter? parameterSelect,
    required String? description,
    required List<FormulaExec>? formulaExecList,
    required Function() resetForm,
    required Function() notifyListeners,
  }) {
    final newIncrement = incrementDetailNoPar + 1;
    setIncrementDetailNoPar(newIncrement);

    // Konversi formulaExecList ke format baru untuk ls_t_ts_fo
    List<dynamic>? ls_t_ts_fo;
    if (formulaExecList != null && formulaExecList.isNotEmpty) {
      ls_t_ts_fo = formulaExecList.asMap().entries.map((entry) {
        final formulaIndex = entry.key;
        final formula = entry.value;
        
        // Format detail sesuai struktur baru
        final detailList = formula.formula_detail.asMap().entries.map((detailEntry) {
          final detailIndex = detailEntry.key;
          final detail = detailEntry.value;
          
          return {
            "detailno": "${detailIndex + 1}", // Increment dari 1 untuk detail
            "formulacode": detail.formulacode,
            "formulaversion": detail.formulaversion.toString(),
            "parameter": detail.parameter,
            "formula": detail.formula ?? "",
            "parameterresult": detail.simresult ?? "",
            "comparespec": detail.comparespec.toString(),
            "lspec": detail.lspec ?? "",
            "uspec": detail.uspec ?? "",
          };
        }).toList();
        
        // Format formula utama sesuai struktur baru
        // detailno untuk formula utama increment berdasarkan index formula (1, 2, 3, ...)
        return {
          "detailno": "${formulaIndex + 1}", // Increment untuk setiap formula (1, 2, 3, ...)
          "formulacode": formula.formulacode,
          "formulaversion": formula.formulaversion.toString(),
          "formulalevel": formula.formulalevel.toString(),
          "description": formula.description ?? "",
          "detail": detailList,
        };
      }).toList();
    }

    listTakingSampleParameter.add(
      TakingSampleParameter(
        key: "",
        detailno: "$newIncrement",
        equipmentcode: parameterEquipmentSelect?.equipmentcode ?? "",
        equipmentname: parameterEquipmentSelect?.equipmentname ?? "",
        parcode: parameterSelect?.parcode ?? "",
        parname: parameterSelect?.parname ?? "",
        description: description ?? "",
        ls_t_ts_fo: ls_t_ts_fo,
      ),
    );

    print("ls_t_ts_fo: ${jsonEncode(listTakingSampleParameter)}");

    for (var parameter in listParameter) {
      if (parameter.parcode == parameterSelect?.parcode) {
        listParameter.remove(parameter);
        break;
      }
    }

    resetForm();
    notifyListeners();
  }

  /// Hapus parameter dari list
  void removeListPar({
    required int index,
    required dynamic data,
    required List<TestingOrderParameter> listParameter2,
    required List<TestingOrderParameter> listParameter,
    required Function(int) setIncrementDetailNoPar,
    required List<TakingSampleParameter> listTakingSampleParameter,
    required Function() reindexParameterList,
    required Function() notifyListeners,
  }) {
    // Cek apakah parameter sudah ada di listParameter (untuk menghindari duplikat)
    final parcodeToRestore = data.parcode.toString().trim().toUpperCase();
    
    if (parcodeToRestore.isNotEmpty) {
      final alreadyExists = listParameter.any(
        (p) => p.parcode.toString().trim().toUpperCase() == parcodeToRestore,
      );

      // Jika belum ada, cari di listParameter2 dan tambahkan kembali
      if (!alreadyExists) {
        TestingOrderParameter? parameterToRestore;
        for (var parameter in listParameter2) {
          final paramParcode = parameter.parcode.toString().trim().toUpperCase();
          if (paramParcode == parcodeToRestore) {
            parameterToRestore = parameter;
            break;
          }
        }
        
        if (parameterToRestore != null) {
          listParameter.add(parameterToRestore);
        }
      }
    }
    
    setIncrementDetailNoPar(0);
    listTakingSampleParameter.removeAt(index);
    reindexParameterList();
    notifyListeners();
  }

  /// Re-index parameter list
  void reindexParameterList({
    required List<TakingSampleParameter> listTakingSampleParameter,
    required Function(int) setIncrementDetailNoPar,
  }) {
    int newIncrement = 0;
    for (int i = 0; i < listTakingSampleParameter.length; i++) {
      listTakingSampleParameter[i].detailno = i.toString();
      newIncrement++;
    }
    setIncrementDetailNoPar(newIncrement);
  }
}

