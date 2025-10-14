import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:salims_apps_new/core/models/equipment_response_models.dart';
import 'package:salims_apps_new/core/models/sample_location_models.dart';
import 'package:salims_apps_new/core/models/sample_models.dart';
import 'package:salims_apps_new/core/models/unit_response_models.dart';
import 'package:salims_apps_new/core/services/api_services.dart';
import 'package:salims_apps_new/ui/views/splash_screen/splash_screen_view.dart';
import 'package:stacked/stacked.dart';

import '../../../core/models/parameter_models.dart';
import '../../../core/models/task_list_models.dart';
import '../../../core/services/local_Storage_Services.dart';

class DetailTaskViewmodel extends FutureViewModel {
  final formKey1 = GlobalKey<FormState>();
  final formKey2 = GlobalKey<FormState>();
  final formKey3 = GlobalKey<FormState>();
  BuildContext? context;
  TestingOrder? listTaskList;
  ApiService apiService = new ApiService();
  LocalStorageService localService = new LocalStorageService();
  DetailTaskViewmodel({this.context, this.listTaskList});

  // TASK INFO
  List<SampleLocation>? sampleLocationList = [];
  SampleLocation? sampleLocationSelect;
  TextEditingController? weatherController = new TextEditingController();
  TextEditingController? windDIrectionController = new TextEditingController();
  TextEditingController? temperaturController = new TextEditingController();
  TextEditingController? descriptionController = new TextEditingController();

  // CONTAINER INFO
  List<TakingSampleCI> listTakingSampleCI = [];
  List<Equipment>? equipmentlist = [];
  List<Unit>? unitList = [];
  Unit? conSelect;
  Unit? volSelect;
  Equipment? equipmentSelect;
  TextEditingController? conQTYController = new TextEditingController();
  TextEditingController? volQTYController = new TextEditingController();
  TextEditingController? descriptionCIController = new TextEditingController();

  // PARAMETER
  List<TestingOrderParameter> listParameter = [];
  TestingOrderParameter? parameterSelect;
  TextEditingController? institutController = new TextEditingController();
  TextEditingController? descriptionParController = new TextEditingController();
  bool? isCalibration = false;

  getData() async {
    setBusy(true);
    try {
      final cekTokens = await apiService.cekToken();

      if (cekTokens) {
        final responseSampleLoc = await apiService.getSampleLoc();
        final responseEquipment = await apiService.getEquipment();
        final responseUnitList = await apiService.getUnitList();
        final responseParameter = await apiService.getParameter(
            '${listTaskList?.reqnumber}', '${listTaskList?.sampleno}');

        print(
            "responseSampleLoc : ${jsonEncode(responseSampleLoc?.data?.data)}");
        sampleLocationList = responseSampleLoc?.data?.data;
        equipmentlist = responseEquipment?.data?.data;
        unitList = responseUnitList?.data?.data;
        listParameter = responseParameter!.data!.data;
        notifyListeners();
        setBusy(false);
      } else {
        await localService.clear();
        Navigator.of(context!).pushReplacement(
            new MaterialPageRoute(builder: (context) => SplashScreenView()));
        notifyListeners();
        setBusy(false);
      }
    } catch (e) {
      setBusy(false);
      notifyListeners();
      print("Error : ${e}");
    }
  }

  addListCI() {
    listTakingSampleCI.add(TakingSampleCI(
        equipmentcode: '${equipmentSelect?.equipmentcode}',
        equipmentname: '${equipmentSelect?.equipmentname}',
        conqty: int.parse(conQTYController!.text),
        conuom: '${conSelect?.name}',
        volqty: int.parse(volQTYController!.text),
        voluom: '${volSelect?.name}',
        description: '${descriptionCIController?.text}'));
    equipmentSelect = null;
    conSelect = null;
    volSelect = null;
    conQTYController?.text = '';
    volQTYController?.text = '';
    descriptionCIController?.text = '';
    notifyListeners();
  }

  removeListCi(int index) {
    listTakingSampleCI.removeAt(index);
    notifyListeners();
  }

  postDataTakingSample() async {
    try {
      final getDataUser = await localService.getUserData();
      final dataJson = SampleDetail(
        tsnumber: "",
        tranidx: "1203",
        periode:
            "${DateFormat('yyyyMM').format(DateTime.parse('${listTaskList!.samplingdate}'))}",
        tsdate: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
        sampleno: "${listTaskList!.sampleno}",
        geoTag: "",
        address: "${listTaskList!.address}",
        weather: "${weatherController?.text}",
        winddirection: "${windDIrectionController?.text}",
        temperatur: "${temperaturController?.text}",
        branchcode: "${getDataUser?.data?.branchcode}",
        samplecode: "",
        ptsnumber: "${listTaskList!.ptsnumber}",
        usercreated: "${getDataUser?.data?.username}",
        takingSampleParameters: [
          TakingSampleParameter(
            parcode: '${parameterSelect?.parcode}',
            parname: '${parameterSelect?.parname}',
            iscalibration: isCalibration!,
            insituresult: institutController!.text,
            description: descriptionParController!.text,
          )
        ],
        takingSampleCI: listTakingSampleCI,
      );

      print("dataJson : ${jsonEncode(dataJson)}");
    } catch (e) {
      print("error : ${e}");
    }
  }

  @override
  Future futureToRun() async {
    await getData();
  }
}
