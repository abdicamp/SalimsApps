import 'package:flutter/material.dart';
import 'package:salims_apps_new/core/models/equipment_response_models.dart';
import 'package:salims_apps_new/core/models/sample_location_models.dart';
import 'package:salims_apps_new/core/models/unit_response_models.dart';
import 'package:salims_apps_new/core/services/api_services.dart';
import 'package:stacked/stacked.dart';

class DetailTaskViewmodel extends FutureViewModel {
  final formKey1 = GlobalKey<FormState>();
  final formKey2 = GlobalKey<FormState>();
  final formKey3 = GlobalKey<FormState>();
  BuildContext? context;
  ApiService apiService = new ApiService();
  DetailTaskViewmodel({this.context});

  // TASK INFO
  List<SampleLocation>? sampleLocationList = [];
  SampleLocation? sampleLocationSelect;
  TextEditingController? weatherController = new TextEditingController();
  TextEditingController? windDIrectionController = new TextEditingController();
  TextEditingController? temperaturController = new TextEditingController();
  TextEditingController? descriptionController = new TextEditingController();

  // CONTAINER INFO
  List<Equipment>? equipmentlist = [];
  List<Unit>? unitList = [];
  Unit? conSelect;
  Unit? volSelect;
  Equipment? equipmentSelect;
  TextEditingController? conQTYController = new TextEditingController();
  TextEditingController? volQTYController = new TextEditingController();
  TextEditingController? descriptionCIController = new TextEditingController();

  // PARAMETER

  TextEditingController? institutController = new TextEditingController();
  TextEditingController? descriptionParController = new TextEditingController();
  bool? isCalibration = false;

  getData() async {
    setBusy(true);
    try {
      final responseSampleLoc = await apiService.getSampleLoc();
      final responseEquipment = await apiService.getEquipment();
      final responseUnitList = await apiService.getUnitList();

      sampleLocationList = responseSampleLoc?.data?.data;
      equipmentlist = responseEquipment?.data?.data;
      unitList = responseUnitList?.data?.data;
      notifyListeners();
      setBusy(false);
    } catch (e) {
      setBusy(false);
      notifyListeners();
      print("Error : ${e}");
    }
  }

  addToTable() async {}

  @override
  Future futureToRun() async {
    await getData();
  }
}
