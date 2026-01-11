import 'package:salims_apps_new/core/models/parameter_models.dart';
import '../../../core/models/sample_models.dart';

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
    required bool? isCalibration,
    required String? insituresult,
    required String? description,
    required Function() resetForm,
    required Function() notifyListeners,
  }) {
    final newIncrement = incrementDetailNoPar + 1;
    setIncrementDetailNoPar(newIncrement);

    listTakingSampleParameter.add(
      TakingSampleParameter(
        key: "",
        detailno: "$newIncrement",
        equipmentcode: parameterEquipmentSelect?.equipmentcode ?? "",
        equipmentname: parameterEquipmentSelect?.equipmentname ?? "",
        parcode: parameterSelect?.parcode ?? "",
        parname: parameterSelect?.parname ?? "",
        iscalibration: isCalibration ?? false,
        insituresult: insituresult ?? "",
        description: description ?? "",
      ),
    );

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
    for (var parameter in listParameter2) {
      if (parameter.parcode == data.parcode) {
        listParameter.add(parameter);
        break;
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

