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
import 'package:salims_apps_new/core/utils/app_localizations.dart';
import 'package:salims_apps_new/ui/views/bottom_navigator_view.dart';
import 'package:salims_apps_new/ui/views/splash_screen/splash_screen_view.dart';
import 'package:stacked/stacked.dart';
import 'package:path/path.dart' as p;
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'dart:typed_data';
import '../../../core/models/parameter_models.dart';
import '../../../core/models/task_list_models.dart';
import '../../../core/services/local_Storage_Services.dart';
import '../../../core/utils/radius_calculate.dart';

class DetailTaskViewmodel extends FutureViewModel {
  final formKey1 = GlobalKey<FormState>();
  final formKey2 = GlobalKey<FormState>();
  final formKey3 = GlobalKey<FormState>();
  bool? isDetailhistory = false;
  BuildContext? context;
  TestingOrder? listTaskList;
  Position? userPosition;
  String? latlang;
  String? longitude;
  String? latitude;
  LatLng? currentLocation;
  ApiService apiService = new ApiService();
  LocalStorageService localService = new LocalStorageService();
  DetailTaskViewmodel({this.context, this.listTaskList, this.isDetailhistory});

  // TASK INFO
  String? address;
  String? namaJalan;
  List<SampleLocation>? sampleLocationList = [];
  List<String> uploadFotoSampleList = [];
  SampleLocation? sampleLocationSelect;
  TextEditingController? locationController = new TextEditingController();
  TextEditingController? addressController = new TextEditingController();
  TextEditingController? weatherController = new TextEditingController();
  TextEditingController? windDIrectionController = new TextEditingController();
  TextEditingController? temperaturController = new TextEditingController();
  TextEditingController? descriptionController = new TextEditingController();

  // CONTAINER INFO
  int? incrementDetailNoCI = 0;
  List<TakingSampleCI> listTakingSampleCI = [];
  List<Equipment> equipmentlist = [];
  List<Unit>? unitList = [];
  Unit? conSelect;
  Unit? volSelect;
  Equipment? equipmentSelect;
  TextEditingController? conQTYController = new TextEditingController();
  TextEditingController? volQTYController = new TextEditingController();
  TextEditingController? descriptionCIController = new TextEditingController();

  // PARAMETER
  int? incrementDetailNoPar = 0;
  List<TakingSampleParameter> listTakingSampleParameter = [];
  List<TestingOrderParameter> listParameter = [];
  TestingOrderParameter? parameterSelect;
  TextEditingController? institutController = new TextEditingController();
  TextEditingController? descriptionParController = new TextEditingController();
  bool? isCalibration = false;
  bool? isConfirm = false;
  bool? allExistParameter = false;
  bool? isChangeLocation = false;

  List<File> imageFilesVerify = [];
  List<String> imageStringVerifiy = [];
  List<String> imageOldStringVerifiy = [];

  List<File> imageFiles = [];
  List<String> imageString = [];
  List<String> imageOldString = [];

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
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Pastikan file baru tidak sudah ada di list
      final newFile = File(pickedFile.path);
      bool alreadyExists = imageFiles.any((f) => f.path == newFile.path);

      if (!alreadyExists) {
        imageFiles.add(newFile);
        notifyListeners();
      }
    }
  }

  Future<void> pickImageVerify() async {
    if (context == null) return;

    // Tampilkan dialog untuk memilih sumber gambar
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context!,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(AppLocalizations.of(context)?.gallery ?? 'Gallery'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: Text(AppLocalizations.of(context)?.camera ?? 'Camera'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      File processedFile;

      // Jika gambar diambil dari camera, tambahkan teks geotag
      if (source == ImageSource.camera &&
          latlang != null &&
          latlang!.isNotEmpty) {
        processedFile = await _addGeotagToImage(File(pickedFile.path));
      } else {
        // Jika dari gallery, gunakan file asli
        processedFile = File(pickedFile.path);
      }

      // Pastikan file baru tidak sudah ada di list
      bool alreadyExists =
          imageFilesVerify.any((f) => f.path == processedFile.path);

      if (!alreadyExists) {
        imageFilesVerify.add(processedFile);
        locationController?.text = latlang!;
        notifyListeners();
      }
    }
  }

  Future<File> _addGeotagToImage(File imageFile) async {
    try {
      // Baca file gambar
      final Uint8List imageBytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);

      if (image == null) {
        return imageFile; // Return original file if decode fails
      }

      // Buat teks geotag
      final geotagText = latlang ?? 'No location';

      // Ukuran tinggi area teks (disesuaikan dengan ukuran gambar)
      final textHeight = (image.height * 0.08).round().clamp(40, 80);

      // Buat gambar gabungan (gambar asli + area teks di bawah)
      final combinedImage = img.Image(
        width: image.width,
        height: image.height + textHeight,
      );

      // Copy gambar asli ke bagian atas
      for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
          final pixel = image.getPixel(x, y);
          combinedImage.setPixel(x, y, pixel);
        }
      }

      // Buat area teks dengan background semi-transparan hitam
      for (int y = 0; y < textHeight; y++) {
        for (int x = 0; x < image.width; x++) {
          // Background hitam dengan alpha untuk semi-transparan
          final bgColor = img.ColorRgba8(0, 0, 0, 200); // Alpha 200 dari 255
          combinedImage.setPixel(x, image.height + y, bgColor);
        }
      }

      // Gambar teks geotag menggunakan drawString
      // Posisi teks di pojok bawah kiri dengan padding
      final textX = 15;
      final textY = image.height + (textHeight ~/ 2) - 10;

      // Draw text menggunakan drawString dengan font bitmap
      // API untuk package image versi 4.x menggunakan named parameters
      img.drawString(
        combinedImage,
        geotagText,
        font: img.arial24,
        x: textX,
        y: textY,
        color: img.ColorRgb8(255, 255, 255), // Warna putih
      );

      // Simpan ke file baru
      final directory = imageFile.parent;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newFileName = 'image_${timestamp}_geotag.jpg';
      final newFile = File('${directory.path}/$newFileName');

      // Encode dan simpan
      final encodedImage = img.encodeJpg(combinedImage, quality: 90);
      await newFile.writeAsBytes(encodedImage);

      return newFile;
    } catch (e) {
      // Jika terjadi error, return file asli
      return imageFile;
    }
  }

  getData() async {
    setBusy(true);
    try {
      final cekTokens = await apiService.cekToken();
      if (cekTokens) {
        final responseSampleLoc = await apiService.getSampleLoc();
        final responseUnitList = await apiService.getUnitList();

        final responseParameterAndEquipment =
            await apiService.getParameterAndEquipment(
                '${listTaskList?.ptsnumber}', '${listTaskList?.sampleno}');
        // Convert List<dynamic> to List<TestingOrderParameter>
        final dataPars = responseParameterAndEquipment?.data?['data']
            ?['testing_order_parameters'];

        if (dataPars is List) {
          listParameter = dataPars
              .map((e) =>
                  TestingOrderParameter.fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
          listParameter = [];
        }

        // Convert List<dynamic> to List<Equipment>
        final dataEquipments = responseParameterAndEquipment?.data?['data']
            ?['testing_order_equipment'];
        if (dataEquipments is List) {
          equipmentlist = dataEquipments
              .map((e) => Equipment.fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
          equipmentlist = [];
        }

        sampleLocationList = responseSampleLoc?.data?.data;
        unitList = responseUnitList?.data?.data;

        locationController!.text = listTaskList!.geotag!;
        latlang = listTaskList!.geotag!;

        if (listTaskList?.tsnumber != '' && listParameter.isNotEmpty) {
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
          final allExist =
              parameterCodes.every((code) => groupedKeys.contains(code));
          allExistParameter = allExist;
          if (listTakingSampleCI.isNotEmpty) {
            isConfirm = true;
          }
        } else {
          if (listTakingSampleCI.isNotEmpty) {
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
    validasiConfirm();
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
    validasiConfirm();
    notifyListeners();
  }

  removeListCi(int index) {
    incrementDetailNoCI = 0;
    listTakingSampleCI.removeAt(index);
    for (var i = 0; i < listTakingSampleCI.length;) {
      listTakingSampleCI[i].detailno = i;
      incrementDetailNoCI = incrementDetailNoCI! + 1;
      i++;
    }
    validasiConfirm();
    notifyListeners();
  }

  removeListPar(int index) {
    incrementDetailNoPar = 0;
    listTakingSampleParameter.removeAt(index);
    for (var i = 0; i < listTakingSampleParameter.length;) {
      listTakingSampleParameter[i].detailno = i;
      incrementDetailNoPar = incrementDetailNoPar! + 1;
      i++;
    }
    validasiConfirm();
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
      return;
    }

    try {
      userPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      currentLocation = LatLng(userPosition!.latitude, userPosition!.longitude);
      latlang = '${currentLocation!.latitude},${currentLocation!.longitude}';
      latitude = '${currentLocation!.latitude}';
      longitude = '${currentLocation!.longitude}';
      locationController?.text = latlang!;

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          currentLocation!.latitude,
          currentLocation!.longitude,
        );
        if (placemarks.isNotEmpty) {
          Placemark placemark = placemarks[0];
          String safe(String? val) => val ?? '';

          address =
              "${safe(placemark.street)}, ${safe(placemark.name)}, ${safe(placemark.subLocality)}, ${safe(placemark.postalCode)}, ${safe(placemark.locality)}, ${safe(placemark.subAdministrativeArea)}, ${safe(placemark.administrativeArea)}, ${safe(placemark.country)}";
          namaJalan = safe(placemark.street);

          addressController?.text = namaJalan!;
          isChangeLocation = true;
        } else {
          // Jika tidak ada placemark, set default address
          address = "Location: ${latlang}";
          namaJalan = "Location";
          addressController?.text = namaJalan!;
          isChangeLocation = true;
        }
      } catch (e) {
        // Handle geocoding error (permission denied, network error, etc.)
        // Set default address dengan koordinat
        address = "Location: ${latlang}";
        namaJalan = "Location";
        addressController?.text = namaJalan!;
        isChangeLocation = true;
      }
    } catch (e) {
      // Set default values jika gagal mendapatkan lokasi
      address = "Location unavailable";
      namaJalan = "Location";
      addressController?.text = namaJalan!;
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  Future<void> confirmPost() async {
    try {
      setBusy(true);
      if (isChangeLocation == true) {
        await postDataTakingSample();
      } else {
        final isCek = await cekRangeLocation();
        if (isCek) {
        } else {
          ScaffoldMessenger.of(context!).showSnackBar(
            SnackBar(
              duration: Duration(seconds: 2),
              content: Text(AppLocalizations.of(context!)?.outOfLocationRange ??
                  "You are out of location range"),
              backgroundColor: Colors.red,
            ),
          );
          setBusy(false);
          notifyListeners();
        }
      }
      notifyListeners();
    } catch (e) {
      ScaffoldMessenger.of(context!).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 2),
          content: Text(
              "${AppLocalizations.of(context!)?.failedConfirm ?? "Failed to confirm"}: ${e}"),
          backgroundColor: Colors.red,
        ),
      );
      setBusy(false);
      notifyListeners();
    }
  }

  Future<String> convertImageToBase64(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final base64String = base64Encode(bytes);
    final ext = imageFile.path.split('.').last.toLowerCase();

    // Tambahkan prefix MIME type
    String mimeType = 'image/jpeg';
    if (ext == 'png')
      mimeType = 'image/png';
    else if (ext == 'jpg' || ext == 'jpeg') mimeType = 'image/jpeg';

    return 'data:$mimeType;base64,$base64String';
  }

  Future<String> convertImageUrlToBase64(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        // Ambil byte data dari response
        final bytes = response.bodyBytes;

        // Ubah ke Base64
        String base64Image = base64Encode(bytes);

        // Jika mau tambahkan prefix MIME type-nya:
        String base64WithPrefix = "data:image/jpeg;base64,$base64Image";

        return base64WithPrefix;
      } else {
        throw Exception('Gagal mengambil gambar: ${response.statusCode}');
      }
    } catch (e) {
      return '';
    }
  }

  postDataTakingSample() async {
    try {
      final getDataUser = await localService.getUserData();
      // 🔹 Ubah image ke base64
      List<String> imageBase64ListVerify = [];
      List<String> imageBase64List = [];
      for (var file in imageFiles) {
        String base64Str = await convertImageToBase64(file);
        imageBase64List.add(base64Str);
      }

      for (var file in imageFilesVerify) {
        String base64Str = await convertImageToBase64(file);
        imageBase64ListVerify.add(base64Str);
      }

      // 🔹 Gabungkan dengan URL lama jika ada
      if (imageString.isNotEmpty) {
        for (var file in imageString) {
          String base64Str = await convertImageUrlToBase64(file);
          imageBase64List.add(base64Str);
        }
      }

      // 🔹 Gabungkan dengan URL lama jika ada
      if (imageStringVerifiy.isNotEmpty) {
        for (var file in imageStringVerifiy) {
          String base64Str = await convertImageUrlToBase64(file);
          imageBase64ListVerify.add(base64Str);
        }
      }

      final dataJson = SampleDetail(
        description: descriptionController!.text,
        tsnumber: "${listTaskList?.tsnumber ?? ''}",
        tranidx: "1203",
        photoOldVerifikasi: imageOldStringVerifiy,
        uploadFotoVerifikasi: imageBase64ListVerify,
        periode:
            "${DateFormat('yyyyMM').format(DateTime.parse('${listTaskList!.samplingdate}'))}",
        tsdate: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
        samplename: "${listTaskList!.sampleName}",
        sampleno: "${listTaskList!.sampleno}",
        geoTag: "${latlang}",
        longtitude: '${longitude}',
        latitude: '${latitude}',
        address: "${listTaskList!.address}",
        weather: "${weatherController?.text}",
        winddirection: "${windDIrectionController?.text}",
        temperatur: "${temperaturController?.text}",
        branchcode: "${getDataUser?.data?.branchcode}",
        samplecode: "${listTaskList!.sampleCode}",
        ptsnumber: "${listTaskList!.ptsnumber}",
        usercreated: "${getDataUser?.data?.username}",
        samplingby: "${getDataUser?.data?.username}",
        buildingcode: "${getDataUser?.data?.buildingauthority}",
        takingSampleParameters: listTakingSampleParameter,
        takingSampleCI: listTakingSampleCI,
        photoOld: imageOldString,
        uploadFotoSample: imageBase64List,
        
      );
      print("data json post : ${jsonEncode(dataJson)}");
      final postSample = await apiService.postTakingSample(dataJson);

      if (postSample.data != null) {
        ScaffoldMessenger.of(context!).showSnackBar(
          SnackBar(
            duration: Duration(seconds: 2),
            content: Text("${postSample.data['message']}"),
            backgroundColor: Colors.green,
          ),
        );
        setBusy(false);
        Navigator.of(context!).pushReplacement(
          MaterialPageRoute(builder: (context) => BottomNavigatorView()),
        );
      } else {
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
    } catch (e, stackTrace) {
      setBusy(false);
      logger.e(
        "Error Post Data",
        error: e,
        stackTrace: stackTrace,
      );
      ScaffoldMessenger.of(context!).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 2),
          content: Text(AppLocalizations.of(context!)?.failedPostData ??
              "Failed to post data"),
          backgroundColor: Colors.red,
        ),
      );
      notifyListeners();
    }
  }

  Future<bool> cekRangeLocation() async {
    try {
      int allowedRadius = 50;
      var latLngSplit = latlang!.split(',');
      double lat = double.tryParse(latLngSplit[0]) ?? 0.0;
      double lng = double.tryParse(latLngSplit[1]) ?? 0.0;

      Position? userPositions = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double distance = RadiusCalculate.calculateDistanceInMeter(
        userPositions.latitude,
        userPositions.longitude,
        lat,
        lng,
      );

      if (distance <= allowedRadius) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  getOneTaskList() async {
    // Jangan setBusy(true) di sini karena FutureViewModel sudah mengatur isBusy
    try {
      if (listTaskList?.tsnumber == null || listTaskList!.tsnumber == '') {
        return;
      }

      final response = await apiService.getOneTaskList(listTaskList?.tsnumber);

      // Cek jika response adalah error
      if (response == null) {
        return;
      }

      if (response is Map && response.containsKey('error')) {
        return;
      }

      // Parse response data
      descriptionController!.text = response['description'] ?? '';
      weatherController!.text = response['weather'] ?? '';
      windDIrectionController!.text = response['winddirection'] ?? '';
      temperaturController!.text = response['temperatur'] ?? '';
      locationController!.text = response['geotag'] ?? '';
      addressController!.text = response['address'] ?? '';

      // ✅ Ambil list URL gambar dari API
      imageString.clear();
      imageOldString.clear();
      imageStringVerifiy.clear();
      imageOldStringVerifiy.clear();

      if (response['documents'] != null && response['documents'] is List) {
        for (var url in response['documents']) {
          if (url != null && url['pathname'] != null) {
            imageString.add(url['pathname'].toString());
            imageOldString.add(url['pathname'].toString());
            imageStringVerifiy.add(url['pathname'].toString());
            imageOldStringVerifiy.add(url['pathname'].toString());
          }
        }
      }

      // Clear list sebelum menambahkan data baru
      listTakingSampleParameter.clear();
      listTakingSampleCI.clear();
      incrementDetailNoPar = 0;
      incrementDetailNoCI = 0;

      if (response['taking_sample_parameters'] != null &&
          response['taking_sample_parameters'] is List) {
        for (var i in response['taking_sample_parameters']) {
          try {
            listTakingSampleParameter.add(TakingSampleParameter.fromJson(i));
            incrementDetailNoPar = incrementDetailNoPar! + 1;
          } catch (e) {
            // Error parsing parameter handled silently
          }
        }
      }

      if (response['taking_sample_ci'] != null &&
          response['taking_sample_ci'] is List) {
        for (var i in response['taking_sample_ci']) {
          try {
            listTakingSampleCI.add(TakingSampleCI.fromJson(i));
            incrementDetailNoCI = incrementDetailNoCI! + 1;
          } catch (e) {
            // Error parsing CI handled silently
          }
        }
      }

      notifyListeners();
    } catch (e, stackTrace) {
      notifyListeners();
      rethrow; // Re-throw agar error bisa di-handle di futureToRun
    }
  }

  validasiConfirm() async {
    try {
      if (listTaskList?.tsnumber != "") {
        if (listParameter.isNotEmpty) {
          final groupedData = groupBy(
            listTakingSampleParameter,
            (item) => item.parcode.toString().trim().toUpperCase() ?? "",
          );
          final groupedKeys = groupedData.keys.toList();
          final parameterCodes = listParameter
              .map((e) => e.parcode.toString().trim().toUpperCase())
              .toList();
          final allExist =
              parameterCodes.every((code) => groupedKeys.contains(code));
          allExistParameter = allExist;

          if (listTakingSampleCI.isNotEmpty && allExist) {
            isConfirm = true;
          } else {
            isConfirm = false;
          }
        } else {
          if (listTakingSampleCI.isNotEmpty) {
            isConfirm = true;
          } else {
            isConfirm = false;
          }
        }
      }
      notifyListeners();
    } catch (e) {}
  }

  confirm() async {
    setBusy(true);
    try {
      final dataJson = {
        'tsnumber': '${listTaskList?.tsnumber}',
        'tsdate': '${listTaskList?.tsdate}',
        'ptsnumber': '${listTaskList?.ptsnumber}',
        'sampleno': '${listTaskList?.sampleno}',
      };
      final response = await apiService.updateStatus(dataJson);

      if (response.data['status'] == true) {
        ScaffoldMessenger.of(context!).showSnackBar(
          SnackBar(
            duration: Duration(seconds: 2),
            content: Text("${response.data['message']}"),
            backgroundColor: Colors.green,
          ),
        );
        setBusy(false);
        Navigator.of(context!).pushReplacement(
          MaterialPageRoute(builder: (context) => BottomNavigatorView()),
        );

        notifyListeners();
      } else {
        ScaffoldMessenger.of(context!).showSnackBar(
          SnackBar(
            duration: Duration(seconds: 2),
            content: Text("${response.data['message']}"),
            backgroundColor: Colors.red,
          ),
        );
        setBusy(false);
        notifyListeners();
      }
    } catch (e) {
      setBusy(false);
      notifyListeners();
    }
  }

  @override
  Future futureToRun() async {
    try {
      if (isDetailhistory == true) {
        // Untuk history, hanya load data detail saja
        await getOneTaskList();
        // Set location controller dari data yang sudah ada
        if (listTaskList?.geotag != null && listTaskList!.geotag!.isNotEmpty) {
          locationController!.text = listTaskList!.geotag!;
          latlang = listTaskList!.geotag!;
        }
      } else {
        // Untuk task baru, load semua data termasuk parameter dan equipment
        await getData();
        await getOneTaskList();
        await validasiConfirm();
      }

      // Pastikan notifyListeners dipanggil untuk trigger rebuild
      notifyListeners();
    } catch (e, stackTrace) {
      // Pastikan setBusy false meskipun ada error
      setBusy(false);
      notifyListeners();
    }
    // await setLocationName();
  }
}
