import 'dart:convert';
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:salims_apps_new/core/models/equipment_response_models.dart';
import 'package:salims_apps_new/core/models/sample_location_models.dart';
import 'package:salims_apps_new/core/models/sample_models.dart';
import 'package:salims_apps_new/core/models/unit_response_models.dart';
import 'package:salims_apps_new/core/services/api_services.dart';
import 'package:salims_apps_new/ui/views/bottom_navigator_view.dart';
import 'package:salims_apps_new/ui/views/splash_screen/splash_screen_view.dart';
import 'package:stacked/stacked.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/models/parameter_models.dart';
import '../../../core/models/task_list_models.dart';
import '../../../core/services/local_Storage_Services.dart';
import '../../../core/utils/radius_calculate.dart';

class DetailTaskViewmodel extends FutureViewModel {
  final formKey1 = GlobalKey<FormState>();
  final formKey2 = GlobalKey<FormState>();
  final formKey3 = GlobalKey<FormState>();
  BuildContext? context;
  TestingOrder? listTaskList;
  String? latlang;
  Position? userPosition;
  LatLng? currentLocation;
  ApiService apiService = new ApiService();
  LocalStorageService localService = new LocalStorageService();
  DetailTaskViewmodel({this.context, this.listTaskList});

  // TASK INFO
  String? address;
  String? namaJalan;
  List<SampleLocation>? sampleLocationList = [];
  SampleLocation? sampleLocationSelect;
  TextEditingController? locationController = new TextEditingController();
  TextEditingController? addressController = new TextEditingController();
  TextEditingController? weatherController = new TextEditingController();
  TextEditingController? windDIrectionController = new TextEditingController();
  TextEditingController? temperaturController = new TextEditingController();
  TextEditingController? descriptionController = new TextEditingController();

  // CONTAINER INFO
  int? incrementDetailNoCI = 0;
  List<TakingSampleParameter> listTakingSampleParameter = [];
  List<Equipment>? equipmentlist = [];
  List<Unit>? unitList = [];
  Unit? conSelect;
  Unit? volSelect;
  Equipment? equipmentSelect;
  TextEditingController? conQTYController = new TextEditingController();
  TextEditingController? volQTYController = new TextEditingController();
  TextEditingController? descriptionCIController = new TextEditingController();

  // PARAMETER
  int? incrementDetailNoPar = 0;
  List<TakingSampleCI> listTakingSampleCI = [];
  List<TestingOrderParameter> listParameter = [];
  TestingOrderParameter? parameterSelect;
  TextEditingController? institutController = new TextEditingController();
  TextEditingController? descriptionParController = new TextEditingController();
  bool? isCalibration = false;
  bool? isConfirm = false;
  bool? allExistParameter = false;
  bool? isChangeLocation = false;

  List<File> imageFiles = [];
  List<String> imageString = [];

  // Logger
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

  Future<void> pickImage() async {
    try {
      XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      // print("image picked : ${pickedFile!.path}");
      if (pickedFile != null) {
        File file = File(pickedFile.path);
        imageFiles.add(file);
        imageString.add(p.basename(file.path));
        notifyListeners();
      }
    } catch (e) {
      // print("error image : ${e}");
    }
  }

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
            "responseParameter : ${jsonEncode(responseParameter?.data?.data)}");
        sampleLocationList = responseSampleLoc?.data?.data;
        equipmentlist = responseEquipment?.data?.data;
        unitList = responseUnitList?.data?.data;
        listParameter = responseParameter!.data!.data;
        locationController!.text = listTaskList!.geotag!;
        latlang = listTaskList!.geotag!;

        if( listTaskList?.tsnumber != '' && listParameter.isNotEmpty){
          // Group berdasarkan parcode dari listTakingSampleParameter
          final groupedData = groupBy(
            listTakingSampleParameter,
                (item) => item.parcode?.toString().trim().toUpperCase() ?? "",
          );

          final groupedKeys = groupedData.keys.toList();

          // Ambil semua parcode dari listParameter (data referensi)
          final parameterCodes = listParameter
              .map((e) => e.parcode.toString().trim().toUpperCase())
              .toList();

          // Cek apakah semua parcode yang diambil sudah ada di listParameter
          final allExist = parameterCodes.every((code) => groupedKeys.contains(code));
          allExistParameter = allExist;
          if(listTakingSampleCI.isNotEmpty){
            isConfirm = true;
          }

        }else {
          if(listTakingSampleCI.isNotEmpty){
            isConfirm = true;
          }
        }
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

  addListParameter() {
    incrementDetailNoPar = (incrementDetailNoPar ?? 0) + 1;

    // Tambahkan data baru
    listTakingSampleParameter.add(
      TakingSampleParameter(
        key: "",
        detailno: "$incrementDetailNoPar",
        parcode: parameterSelect?.parcode ?? "",
        parname: parameterSelect?.parname ?? "",
        iscalibration: isCalibration ?? false,
        insituresult: institutController?.text ?? "",
        description: descriptionParController?.text ?? "",
      ),
    );

    // Reset form
    parameterSelect = null;
    institutController?.text = "";
    descriptionParController?.text = "";
    isCalibration = false;

    // ✅ Pengecekan kelengkapan data
    if (listParameter.isNotEmpty) {

      final groupedData = groupBy(
        listTakingSampleParameter,
            (item) => item.parcode.toString().trim().toUpperCase() ?? "",
      );

      final groupedKeys = groupedData.keys.toList();

      // Ambil semua parcode dari listParameter (data referensi)
      final parameterCodes = listParameter
          .map((e) => e.parcode.toString().trim().toUpperCase())
          .toList();

      // Cek apakah semua parcode yang diambil sudah ada di listParameter
      final allExist = parameterCodes.every((code) => groupedKeys.contains(code));
      allExistParameter = allExist;
      if(listTakingSampleCI.isNotEmpty && allExist){
        isConfirm = true;
      }
    }

    notifyListeners();
  }

  addListCI() {
    incrementDetailNoCI = incrementDetailNoCI! + 1;
    listTakingSampleCI.add(TakingSampleCI(
        key: "",
        detailno: "${incrementDetailNoCI}",
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

    if(listTakingSampleCI.isNotEmpty){
      isConfirm = true;
    }
    notifyListeners();
  }

  removeListCi(int index) {
    incrementDetailNoCI = 0;
    listTakingSampleCI.removeAt(index);
    for(var i = 0; i < listTakingSampleCI.length;){
      listTakingSampleCI[i].detailno = i;
      incrementDetailNoCI = incrementDetailNoCI! + 1;
      i++;
    }
    if(listTakingSampleCI.isEmpty){
      isConfirm = false;
    }
    print("listTakingSampleCI : ${jsonEncode(listTakingSampleParameter)}");
    notifyListeners();
  }

  removeListPar(int index) {
    incrementDetailNoPar = 0;
    listTakingSampleParameter.removeAt(index);
    for(var i = 0; i < listTakingSampleParameter.length;){
      listTakingSampleParameter[i].detailno = i;
      incrementDetailNoPar = incrementDetailNoPar! + 1;
      i++;
    }
    final groupedData = groupBy(
      listTakingSampleParameter,
          (item) => item.parcode.toString().trim().toUpperCase() ?? "",
    );

    final groupedKeys = groupedData.keys.toList();

    // Ambil semua parcode dari listParameter (data referensi)
    final parameterCodes = listParameter
        .map((e) => e.parcode.toString().trim().toUpperCase())
        .toList();

    // Cek apakah semua parcode yang diambil sudah ada di listParameter
    final allExist = parameterCodes.every((code) => groupedKeys.contains(code));
    allExistParameter = allExist;
    if(listTakingSampleCI.isNotEmpty && allExist){
      isConfirm = true;
    }else {
      isConfirm = false;
    }
    print("listTakingSampleParameter : ${jsonEncode(listTakingSampleParameter)}");
    notifyListeners();
  }

  setLocationName() async {
    setBusy(true);
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      // Tampilkan pesan ke user
      print("permission : ${permission}");
      return;
    }

    userPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    currentLocation = LatLng(userPosition!.latitude, userPosition!.longitude);
    latlang = '${currentLocation!.latitude},${currentLocation!.longitude}';
    locationController?.text = latlang!;
    List<Placemark> placemarks = await placemarkFromCoordinates(
      currentLocation!.latitude,
      currentLocation!.longitude,
    );
    print("placemarks : ${placemarks}");
    Placemark placemark = placemarks[0];


    if (placemarks.isNotEmpty) {
      Placemark placemark = placemarks[0];
      String safe(String? val) => val ?? '';

      address =
      "${safe(placemark.street)}, ${safe(placemark.name)}, ${safe(placemark.subLocality)}, ${safe(placemark.postalCode)}, ${safe(placemark.locality)}, ${safe(placemark.subAdministrativeArea)}, ${safe(placemark.administrativeArea)}, ${safe(placemark.country)}";
      namaJalan = safe(placemark.street);

      addressController?.text = namaJalan!;
      isChangeLocation = true;
      setBusy(false);
    }
    notifyListeners();
  }

  postDataTakingSample() async {
    setBusy(true);
    try {

      final getDataUser = await localService.getUserData();
      final dataJson = SampleDetail(
        description: descriptionController!.text,
        tsnumber: "${listTaskList?.tsnumber ?? ''}",
        tranidx: "1203",
        periode:
        "${DateFormat('yyyyMM').format(DateTime.parse('${listTaskList!.samplingdate}'))}",
        tsdate: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
        samplename: "${listTaskList!.sampleName}",
        sampleno: "${listTaskList!.sampleno}",
        geoTag: "${latlang}",
        address: "${listTaskList!.address}",
        weather: "${weatherController?.text}",
        winddirection: "${windDIrectionController?.text}",
        temperatur: "${temperaturController?.text}",
        branchcode: "${getDataUser?.data?.branchcode}",
        samplecode: "${listTaskList!.sampleCode}",
        ptsnumber: "${listTaskList!.ptsnumber}",
        usercreated: "${getDataUser?.data?.username}",
        takingSampleParameters: listTakingSampleParameter,
        takingSampleCI: listTakingSampleCI,
      );

      print("dataJson : ${jsonEncode(dataJson)}");
      final postSample = await apiService.postTakingSample(dataJson);

      if(postSample.data != null){
        ScaffoldMessenger.of(context!).showSnackBar(
          SnackBar(
            duration: Duration(seconds: 2),
            content: Text("${postSample.data['message']}"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context!).pushReplacement(
          MaterialPageRoute(builder: (context) => BottomNavigatorView()),
        );
      }else {
        setBusy(false);
        ScaffoldMessenger.of(context!).showSnackBar(
          SnackBar(
            duration: Duration(seconds: 2),
            content: Text("${postSample.error}"),
            backgroundColor: Colors.red,
          ),
        );
        notifyListeners();
      }

      setBusy(false);
      notifyListeners();
      // if(cekRangeLocation == true){
      //
      // }else {
      //   ScaffoldMessenger.of(context!).showSnackBar(
      //     SnackBar(
      //       duration: Duration(seconds: 2),
      //       content: Text("You are out of location range"),
      //       backgroundColor: Colors.red,
      //     ),
      //   );
      //   setBusy(false);
      //   notifyListeners();
      // }


    } catch (e, stackTrace) {
      logger.e(
        "Error Post Data",
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<bool> cekRangeLocation() async {
    try {
      int allowedRadius = 50;
      var latLngSplit = latlang!.split(',');
      print("latLngSplit : ${latLngSplit}");
      double lat = double.tryParse(latLngSplit[0]) ?? 0.0;
      double lng = double.tryParse(latLngSplit[1]) ?? 0.0;

      double distance = RadiusCalculate.calculateDistanceInMeter(
        userPosition!.latitude,
        userPosition!.longitude,
        lat,
        lng,
      );
      print("distance : ${distance}");

      if (distance <= allowedRadius) {
        return true;
      }else {
        return false;
      }

    }catch(e){
      print("error cek location : ${e}");
       return false;
    }
  }

  getOneTaskList() async {
    setBusy(true);
    try {
      if(listTaskList?.tsnumber != '') {

        final response = await apiService.getOneTaskList(listTaskList?.tsnumber);
        descriptionController!.text = response['description'];
        weatherController!.text = response['weather'];
        windDIrectionController!.text = response['winddirection'];
        temperaturController!.text = response['temperatur'];
      
        for(var i in response['taking_sample_parameters']){
          print("parameter : ${i}");
          listTakingSampleParameter.add(TakingSampleParameter.fromJson(i));
          incrementDetailNoPar = incrementDetailNoPar! + 1;
        }

        for(var i in response['taking_sample_ci']){
          listTakingSampleCI.add(TakingSampleCI.fromJson(i));
          incrementDetailNoCI = incrementDetailNoCI! + 1;
        }


      }
      setBusy(false);
      notifyListeners();
    }catch (e) {
      print("error get one task : ${e}");
    }
  }


  @override
  Future futureToRun() async {
    await getData();
    await getOneTaskList();
    // await setLocationName();
  }
}
