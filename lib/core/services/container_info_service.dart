import 'package:salims_apps_new/core/models/equipment_response_models.dart';
import '../../../core/models/sample_models.dart';

/// Service untuk menangani operasi Container Info (CI)
class ContainerInfoService {
  /// Tambahkan CI ke list
  void addListCI({
    required int incrementDetailNoCI,
    required Function(int) setIncrementDetailNoCI,
    required List<TakingSampleCI> listTakingSampleCI,
    required List<Equipment> equipmentlist,
    required Equipment? equipmentSelect,
    required String? conQTY,
    required String? conUOM,
    required String? volQTY,
    required String? volUOM,
    required String? description,
    required Function() resetCIForm,
    required Function() notifyListeners,
  }) {
    final newIncrement = incrementDetailNoCI + 1;
    setIncrementDetailNoCI(newIncrement);

    listTakingSampleCI.add(
      TakingSampleCI(
        key: "",
        detailno: "$newIncrement",
        equipmentcode: '${equipmentSelect?.equipmentcode}',
        equipmentname: '${equipmentSelect?.equipmentname}',
        conqty: int.parse(conQTY ?? '0'),
        conuom: conUOM ?? '',
        volqty: int.parse(volQTY ?? '0'),
        voluom: volUOM ?? '',
        description: description ?? '',
      ),
    );

    for (var equipment in equipmentlist) {
      if (equipment.equipmentcode == equipmentSelect?.equipmentcode) {
        equipmentlist.remove(equipment);
        break;
      }
    }

    resetCIForm();
    notifyListeners();
  }

  /// Hapus CI dari list
  void removeListCi({
    required int index,
    required dynamic data,
    required List<Equipment> equipmentlist2,
    required List<Equipment> equipmentlist,
    required Function(int) setIncrementDetailNoCI,
    required List<TakingSampleCI> listTakingSampleCI,
    required Function() reindexCIList,
    required Function() notifyListeners,
  }) {
    for (var equipment in equipmentlist2) {
      if (equipment.equipmentcode == data.equipmentcode) {
        equipmentlist.add(equipment);
        break;
      }
    }

    setIncrementDetailNoCI(0);
    listTakingSampleCI.removeAt(index);
    reindexCIList();
    notifyListeners();
  }

  /// Re-index CI list
  void reindexCIList({
    required List<TakingSampleCI> listTakingSampleCI,
    required Function(int) setIncrementDetailNoCI,
  }) {
    int newIncrement = 0;
    for (int i = 0; i < listTakingSampleCI.length; i++) {
      listTakingSampleCI[i].detailno = i.toString();
      newIncrement++;
    }
    setIncrementDetailNoCI(newIncrement);
  }
}

