import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:stacked/stacked.dart';
import 'package:salims_apps_new/core/models/equipment_response_models.dart';
import 'package:salims_apps_new/core/models/sample_location_models.dart';
import 'package:salims_apps_new/core/models/sample_models.dart';
import 'package:salims_apps_new/core/models/unit_response_models.dart';
import 'package:salims_apps_new/core/services/api_services.dart';
import 'package:salims_apps_new/core/utils/app_localizations.dart';
import 'package:salims_apps_new/ui/views/bottom_navigator_view.dart';
import 'package:salims_apps_new/ui/views/splash_screen/splash_screen_view.dart';
import '../../../core/models/parameter_models.dart';
import '../../../core/models/task_list_models.dart';
import '../../../core/services/local_Storage_Services.dart';
import '../../../core/utils/radius_calculate.dart';
import '../../../core/utils/search_dropdown.dart';
import '../../../core/services/image_processing_service.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/validation_service.dart';
import '../../../core/services/parameter_service.dart';
import '../../../core/services/container_info_service.dart';
import '../../../core/services/task_data_service.dart';
import '../../../core/services/save_service.dart';

/// ViewModel untuk Detail Task
/// Menangani semua logika bisnis untuk detail task termasuk:
/// - Manajemen lokasi dan geotagging
/// - Upload dan processing gambar
/// - Manajemen parameter dan equipment
/// - Validasi dan konfirmasi data
class DetailTaskViewmodel extends FutureViewModel {
  // ============================================================================
  // DEPENDENCIES
  // ============================================================================
  final ApiService apiService = ApiService();
  final LocalStorageService localService = LocalStorageService();
  final ImageProcessingService imageService = ImageProcessingService();
  final LocationService locationService = LocationService();
  final ValidationService validationService = ValidationService();
  final ParameterService parameterService = ParameterService();
  final ContainerInfoService containerInfoService = ContainerInfoService();
  final TaskDataService taskDataService = TaskDataService();
  final SaveService saveService = SaveService();
  final logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  // ============================================================================
  // CONSTRUCTOR & FORM KEYS
  // ============================================================================
  final formKey1 = GlobalKey<FormState>();
  final formKey2 = GlobalKey<FormState>();
  final formKey3 = GlobalKey<FormState>();

  GlobalKey<CustomSearchableDropDownState> dropdownKeyEquipment = GlobalKey();
  GlobalKey<CustomSearchableDropDownState> dropdownKeyParameter = GlobalKey();
  GlobalKey<CustomSearchableDropDownState> dropdownKeyConUOM = GlobalKey();
  GlobalKey<CustomSearchableDropDownState> dropdownKeyVolUOM = GlobalKey();

  DetailTaskViewmodel({
    this.context,
    this.listTaskList,
    this.isDetailhistory,
  });

  // ============================================================================
  // CONTEXT & TASK DATA
  // ============================================================================
  BuildContext? context;
  bool? isDetailhistory = false;
  TestingOrder? listTaskList;

  // ============================================================================
  // LOCATION DATA
  // ============================================================================
  Position? userPosition;
  String? latlang;
  String? longitude;
  String? latitude;
  LatLng? currentLocation;
  String? address;
  String? namaJalan;
  bool? isChangeLocation = false;

  // ============================================================================
  // TASK INFO - CONTROLLERS & DATA
  // ============================================================================
  List<SampleLocation>? sampleLocationList = [];
  List<String> uploadFotoSampleList = [];
  SampleLocation? sampleLocationSelect;
  int? radiusLocation = 0;
  TextEditingController? locationController = TextEditingController();
  TextEditingController? locationSamplingController = TextEditingController();
  TextEditingController? locationCurrentController = TextEditingController();
  TextEditingController? addressController = TextEditingController();
  TextEditingController? weatherController = TextEditingController();
  TextEditingController? windDIrectionController = TextEditingController();
  TextEditingController? temperaturController = TextEditingController();
  TextEditingController? descriptionController = TextEditingController();

  // ============================================================================
  // IMAGE DATA
  // ============================================================================
  // Images untuk sample biasa
  List<File> imageFiles = [];
  List<String> imageString = [];
  List<String> imageOldString = [];

  // Images untuk verifikasi
  List<File> imageFilesVerify = [];
  List<String> imageStringVerifiy = [];
  List<String> imageOldStringVerifiy = [];

  // ============================================================================
  // CONTAINER INFO (CI) - DATA & CONTROLLERS
  // ============================================================================
  int? incrementDetailNoCI = 0;
  List<TakingSampleCI> listTakingSampleCI = [];
  List<Equipment> equipmentlist = [];
  List<Equipment> equipmentlist2 = []; // Backup untuk restore saat remove
  List<Unit>? unitList = [];
  Unit? conSelect;
  Unit? volSelect;
  Equipment? equipmentSelect;

  TextEditingController? conQTYController = TextEditingController();
  TextEditingController? volQTYController = TextEditingController();
  TextEditingController? descriptionCIController = TextEditingController();

  // ============================================================================
  // PARAMETER - DATA & CONTROLLERS
  // ============================================================================
  int? incrementDetailNoPar = 0;
  List<TakingSampleParameter> listTakingSampleParameter = [];
  List<TestingOrderParameter> listParameter = [];
  List<TestingOrderParameter> listParameter2 = []; // Backup untuk restore
  TestingOrderParameter? parameterSelect;

  // Equipment Parameter dari detail parameter yang dipilih
  List<ParameterEquipmentDetail> listParameterEquipment = [];
  ParameterEquipmentDetail? parameterEquipmentSelect;

  TextEditingController? institutController = TextEditingController();
  TextEditingController? descriptionParController = TextEditingController();
  bool? isCalibration = false;

  GlobalKey<CustomSearchableDropDownState> dropdownKeyParameterEquipment =
      GlobalKey();

  // ============================================================================
  // VALIDATION FLAGS
  // ============================================================================
  bool? allExistParameter = false;

  // ============================================================================
  // IMAGE PICKER METHODS
  // ============================================================================

  /// Pick image dari gallery untuk sample biasa
  Future<void> pickImage() async {
    try {
      setBusy(true);
      final source = await imageService.showImageSourceDialog(context!);

      if (source == null) {
        setBusy(false);
        return;
      }

      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile == null) {
        setBusy(false);
        return;
      }

      final newFile = File(pickedFile.path);
      final alreadyExists = imageFiles.any((f) => f.path == newFile.path);

      if (!alreadyExists) {
        imageFiles.add(newFile);
        notifyListeners();
      }
    } catch (e) {
      logger.e('Error picking image', error: e);
      if (context != null) {
        ScaffoldMessenger.of(context!).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil gambar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setBusy(false);
    }
  }

  /// Pick image untuk verifikasi (dengan geotagging jika dari camera)
  Future<void> pickImageVerify() async {
    if (context == null) return;

    try {
      final source = await imageService.showImageSourceDialogVerify(context!);

      if (source == null) return;

      // Ambil lokasi jika dari camera dan belum ada
      if (source == ImageSource.camera &&
          (latlang == null || latlang!.isEmpty)) {
        final success = await _requestLocationForCamera();
        if (!success) {
          setBusy(false);
          return;
        }
        // Pastikan geocoding selesai dan alamat sudah di-set
        logger.i('Lokasi dan alamat sudah diambil sebelum mengambil foto');
        logger.i('Alamat: $address');
        logger.i('Nama jalan: $namaJalan');
      } else if (source == ImageSource.camera &&
          (address == null ||
              address!.isEmpty ||
              namaJalan == null ||
              namaJalan!.isEmpty)) {
        // Jika lokasi sudah ada tapi alamat belum, coba ambil alamat lagi
        logger
            .i('Lokasi sudah ada tapi alamat belum, mencoba geocoding lagi...');
        if (currentLocation != null) {
          final addressResult =
              await locationService.fetchAddressFromLocation(currentLocation!);
          address = addressResult['address'];
          namaJalan = addressResult['namaJalan'];
        }
      }

      setBusy(true);
      notifyListeners();

      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile == null) {
        setBusy(false);
        return;
      }

      // Proses gambar dengan geotag
      final processedFile = await imageService.processImageFile(
        File(pickedFile.path),
        source,
        latlang,
        address: address,
        namaJalan: namaJalan,
      );

      if (!imageFilesVerify.any((f) => f.path == processedFile.path)) {
        imageFilesVerify.add(processedFile);
        if (latlang != null && latlang!.isNotEmpty) {
          locationController?.text = latlang!;
          locationCurrentController?.text = latlang!;
        }
        notifyListeners();
      }
    } catch (e) {
      logger.e('Error picking verify image', error: e);
      if (context != null) {
        ScaffoldMessenger.of(context!).showSnackBar(
          SnackBar(
            content: Text('Gagal memproses gambar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  /// Request lokasi untuk camera (dengan permission handling)
  Future<bool> _requestLocationForCamera() async {
    try {
      setBusy(true);
      final permission =
          await locationService.checkAndRequestLocationPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (context != null) {
          locationService.showLocationPermissionError(context!);
        }
        setBusy(false);
        return false;
      }

      final position = await locationService.fetchCurrentLocation();
      userPosition = position;
      currentLocation = LatLng(position.latitude, position.longitude);
      latlang = '${currentLocation!.latitude},${currentLocation!.longitude}';
      latitude = '${currentLocation!.latitude}';
      longitude = '${currentLocation!.longitude}';

      final isFake = await locationService.isFakeGPS(position);
      if (isFake) {
        if (context != null) {
          locationService.showFakeGPSWarning(context!);
        }
        setBusy(false);
        return false;
      }

      final addressResult =
          await locationService.fetchAddressFromLocation(currentLocation!);
      address = addressResult['address'];
      namaJalan = addressResult['namaJalan'];
      _updateLocationController();

      if ((address == null ||
              address!.isEmpty ||
              address == 'Location unavailable' ||
              address!.startsWith('Location:')) &&
          (namaJalan == null ||
              namaJalan!.isEmpty ||
              namaJalan == 'Location' ||
              namaJalan == 'Location unavailable')) {
        logger.w('Geocoding pertama gagal, mencoba sekali lagi...');
        await Future.delayed(const Duration(seconds: 1));
        final retryResult =
            await locationService.fetchAddressFromLocation(currentLocation!);
        address = retryResult['address'];
        namaJalan = retryResult['namaJalan'];
      }

      setBusy(false);
      return true;
    } catch (e) {
      setBusy(false);
      if (context != null) {
        locationService.showLocationError(context!);
      }
      return false;
    }
  }

  /// Update location controller dengan latlang
  void _updateLocationController() {
    if (locationController != null && latlang != null) {
      locationController!.text = latlang!;
    }
    if (locationCurrentController != null && latlang != null) {
      locationCurrentController!.text = latlang!;
    }
  }

  // ============================================================================
  // LOCATION METHODS
  // ============================================================================

  /// Set location name dari GPS
  Future<void> setLocationName() async {
    setBusy(true);
    try {
      final permission =
          await locationService.checkAndRequestLocationPermission();
      if (permission == LocationPermission.deniedForever) {
        setBusy(false);
        return;
      }

      final position = await locationService.fetchCurrentLocation();
      userPosition = position;
      currentLocation = LatLng(position.latitude, position.longitude);
      latlang = '${currentLocation!.latitude},${currentLocation!.longitude}';
      latitude = '${currentLocation!.latitude}';
      longitude = '${currentLocation!.longitude}';

      final isFake = await locationService.isFakeGPS(position);
      if (isFake) {
        if (context != null) {
          locationService.showFakeGPSWarning(context!);
        }
        setBusy(false);
        return;
      }

      final addressResult =
          await locationService.fetchAddressFromLocation(currentLocation!);
      address = addressResult['address'];
      namaJalan = addressResult['namaJalan'];
      _updateLocationController();
      addressController?.text = namaJalan ?? '';
      isChangeLocation = true;
    } catch (e) {
      _setDefaultLocationValues();
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  /// Set default location values jika gagal
  void _setDefaultLocationValues() {
    address = "Location unavailable";
    namaJalan = "Location";
    addressController?.text = namaJalan!;
  }

  /// Cek apakah user dalam range lokasi yang diizinkan
  Future<bool> cekRangeLocation() async {
    try {
      const int allowedRadius = 50;
      final latLngSplit = latlang!.split(',');
      final lat = double.tryParse(latLngSplit[0]) ?? 0.0;
      final lng = double.tryParse(latLngSplit[1]) ?? 0.0;

      final userPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final distance = RadiusCalculate.calculateDistanceInMeter(
        userPosition.latitude,
        userPosition.longitude,
        lat,
        lng,
      );

      return distance <= allowedRadius;
    } catch (e) {
      return false;
    }
  }

  /// Cek apakah lokasi saat ini berada dalam radius lokasi sampling
  Future<bool> cekRadiusSamplingLocation() async {
    try {
      // Jika radiusLocation tidak ada atau 0, skip validasi
      if (radiusLocation == null || radiusLocation == 0) {
        return true;
      }

      // Ambil lokasi sampling dari listTaskList (prioritas: latlong > gps_subzone > geotag)
      String? samplingLocation;
      if (listTaskList?.latlong != null && listTaskList!.latlong!.isNotEmpty) {
        samplingLocation = listTaskList!.latlong!;
      } else if (listTaskList?.gps_subzone != null &&
          listTaskList!.gps_subzone.isNotEmpty) {
        samplingLocation = listTaskList!.gps_subzone;
      } else if (listTaskList?.geotag != null &&
          listTaskList!.geotag!.isNotEmpty) {
        samplingLocation = listTaskList!.geotag!;
      } else {
        // Jika tidak ada lokasi sampling, skip validasi
        return true;
      }

      // Parse koordinat lokasi sampling
      final latLngSplit = samplingLocation.split(',');
      if (latLngSplit.length != 2) {
        return true; // Skip validasi jika format tidak valid
      }

      final samplingLat = double.tryParse(latLngSplit[0].trim());
      final samplingLng = double.tryParse(latLngSplit[1].trim());

      if (samplingLat == null || samplingLng == null) {
        return true; // Skip validasi jika parsing gagal
      }

      // Ambil lokasi saat ini
      final userPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Hitung jarak
      final distance = RadiusCalculate.calculateDistanceInMeter(
        userPosition.latitude,
        userPosition.longitude,
        samplingLat,
        samplingLng,
      );

      // Cek apakah dalam radius
      return distance <= radiusLocation!;
    } catch (e) {
      logger.e('Error checking radius sampling location', error: e);
      return false;
    }
  }

  // ============================================================================
  // PARAMETER METHODS
  // ============================================================================

  /// Tambahkan parameter ke list
  void addListParameter() {
    parameterService.addListParameter(
      incrementDetailNoPar: incrementDetailNoPar ?? 0,
      setIncrementDetailNoPar: (value) => incrementDetailNoPar = value,
      listTakingSampleParameter: listTakingSampleParameter,
      parameterEquipmentSelect: parameterEquipmentSelect,
      listParameter: listParameter,
      parameterSelect: parameterSelect,
      isCalibration: isCalibration,
      insituresult: institutController?.text,
      description: descriptionParController?.text,
      resetForm: _resetParameterForm,
      notifyListeners: notifyListeners,
    );
  }

  /// Reset form parameter
  void _resetParameterForm() {
    parameterSelect = null;
    listParameterEquipment = [];
    parameterEquipmentSelect = null;
    institutController?.text = "";
    descriptionParController?.text = "";
    isCalibration = false;
    dropdownKeyParameter.currentState?.clearValue();
    dropdownKeyParameterEquipment.currentState?.clearValue();
  }

  /// Update list equipment parameter ketika parameter dipilih
  void updateParameterEquipment() {
    if (parameterSelect?.detail != null &&
        parameterSelect!.detail!.isNotEmpty) {
      listParameterEquipment = parameterSelect!.detail!;
    } else {
      listParameterEquipment = [];
    }
    parameterEquipmentSelect = null;
    notifyListeners();
  }

  /// Hapus parameter dari list
  void removeListPar(int index, dynamic data) {
    parameterService.removeListPar(
      index: index,
      data: data,
      listParameter2: listParameter2,
      listParameter: listParameter,
      setIncrementDetailNoPar: (value) => incrementDetailNoPar = value,
      listTakingSampleParameter: listTakingSampleParameter,
      reindexParameterList: _reindexParameterList,
      notifyListeners: notifyListeners,
    );
  }

  /// Re-index parameter list
  void _reindexParameterList() {
    parameterService.reindexParameterList(
      listTakingSampleParameter: listTakingSampleParameter,
      setIncrementDetailNoPar: (value) => incrementDetailNoPar = value,
    );
  }

  // ============================================================================
  // CONTAINER INFO (CI) METHODS
  // ============================================================================

  /// Tambahkan CI ke list
  void addListCI() {
    containerInfoService.addListCI(
      incrementDetailNoCI: incrementDetailNoCI ?? 0,
      setIncrementDetailNoCI: (value) => incrementDetailNoCI = value,
      listTakingSampleCI: listTakingSampleCI,
      equipmentlist: equipmentlist,
      equipmentSelect: equipmentSelect,
      conQTY: conQTYController?.text,
      conUOM: conSelect?.name,
      volQTY: volQTYController?.text,
      volUOM: volSelect?.name,
      description: descriptionCIController?.text,
      resetCIForm: _resetCIForm,
      notifyListeners: notifyListeners,
    );
  }

  /// Reset form CI
  void _resetCIForm() {
    dropdownKeyEquipment.currentState?.clearValue();
    dropdownKeyConUOM.currentState?.clearValue();
    dropdownKeyVolUOM.currentState?.clearValue();
    equipmentSelect = null;
    conSelect = null;
    volSelect = null;
    conQTYController?.text = '';
    volQTYController?.text = '';
    descriptionCIController?.text = '';
  }

  /// Hapus CI dari list
  void removeListCi(int index, dynamic data) {
    containerInfoService.removeListCi(
      index: index,
      data: data,
      equipmentlist2: equipmentlist2,
      equipmentlist: equipmentlist,
      setIncrementDetailNoCI: (value) => incrementDetailNoCI = value,
      listTakingSampleCI: listTakingSampleCI,
      reindexCIList: _reindexCIList,
      notifyListeners: notifyListeners,
    );
  }

  /// Re-index CI list
  void _reindexCIList() {
    containerInfoService.reindexCIList(
      listTakingSampleCI: listTakingSampleCI,
      setIncrementDetailNoCI: (value) => incrementDetailNoCI = value,
    );
  }

  // ============================================================================
  // API DATA METHODS
  // ============================================================================

  /// Get data awal (sample location, unit, parameter, equipment)
  Future<void> getData() async {
    setBusy(true);
    try {
      final cekTokens = await apiService.cekToken();
      if (!cekTokens) {
        await _handleTokenExpired();
        return;
      }

      await _fetchInitialData();
      _initializeLocationData();
      _validateParameters();
      await _fetchCurrentLocationForDisplay();

      notifyListeners();
      setBusy(false);
    } catch (e) {
      logger.e('Error getting data', error: e);
      setBusy(false);
      notifyListeners();
    }
  }

  /// Handle token expired
  Future<void> _handleTokenExpired() async {
    await localService.clear();
    if (context != null) {
      Navigator.of(context!).pushReplacement(
        MaterialPageRoute(builder: (context) => SplashScreenView()),
      );
    }
    notifyListeners();
    setBusy(false);
  }

  /// Fetch initial data dari API
  Future<void> _fetchInitialData() async {
    final responseSampleLoc = await apiService.getSampleLoc();
    final responseUnitList = await apiService.getUnitList();
    final samplingRadiusValue = listTaskList?.samplingradius;
    locationSamplingController!.text = listTaskList?.gps_subzone ?? '';
    if (samplingRadiusValue is int) {
      radiusLocation = samplingRadiusValue;
    } else if (samplingRadiusValue is String) {
      radiusLocation = int.tryParse(samplingRadiusValue) ?? 0;
    } else {
      radiusLocation = 0;
    }
    print("radiusLocation: $radiusLocation");
    final responseParameterAndEquipment =
        await apiService.getParameterAndEquipment(
      '${listTaskList?.ptsnumber}',
      '${listTaskList?.sampleno}',
    );

    sampleLocationList = responseSampleLoc?.data?.data;
    unitList = responseUnitList?.data?.data;

    _parseParameterData(responseParameterAndEquipment);
    _parseEquipmentData(responseParameterAndEquipment);
  }

  /// Parse parameter data dari response
  void _parseParameterData(dynamic response) {
    listParameter = taskDataService.parseParameterData(response);
    listParameter2 = List.from(listParameter);
  }

  /// Parse equipment data dari response
  void _parseEquipmentData(dynamic response) {
    equipmentlist = taskDataService.parseEquipmentData(response);
    equipmentlist2 = List.from(equipmentlist);
  }

  /// Initialize location data
  void _initializeLocationData() {
    if (listTaskList?.geotag != null) {
      locationController!.text = listTaskList!.geotag!;
      latlang = listTaskList!.geotag!;
    }
  }

  /// Fetch current location untuk ditampilkan di locationCurrentController
  Future<void> _fetchCurrentLocationForDisplay() async {
    try {
      final permission =
          await locationService.checkAndRequestLocationPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await locationService.fetchCurrentLocation();
      final currentLatLng = '${position.latitude},${position.longitude}';
      if (locationCurrentController != null) {
        locationCurrentController!.text = currentLatLng;
      }
    } catch (e) {
      logger.e('Error fetching current location for display', error: e);
    }
  }

  /// Validate parameters
  void _validateParameters() {
    allExistParameter = taskDataService.validateParameters(
      tsnumber: listTaskList?.tsnumber,
      listParameter: listParameter,
      listTakingSampleParameter: listTakingSampleParameter,
    );
  }

  /// Get one task list detail
  Future<void> getOneTaskList() async {
    try {
      if (listTaskList?.tsnumber == null || listTaskList!.tsnumber == '') {
        return;
      }

      final response = await apiService.getOneTaskList(listTaskList?.tsnumber);
      if (response == null ||
          (response is Map && response.containsKey('error'))) {
        return;
      }

      if (response['appstatus'] == 'APPROVED' && isDetailhistory == false) {
        if (context != null) {
          Navigator.of(context!).pop();
          ScaffoldMessenger.of(context!).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
              content: Text('Task sudah di${response['appstatus'].toUpperCase()} , Silahkan Refresh Kembali'),
            ),
          );
        }
        return;
      }

      _parseTaskDetailResponse(response);
      _parseTaskImages(response);
      _parseTaskParameters(response);
      _parseTaskCI(response);

      notifyListeners();
    } catch (e, stackTrace) {
      logger.e('Error getting one task list', error: e, stackTrace: stackTrace);
      notifyListeners();
      rethrow;
    }
  }

  /// Parse task detail response
  void _parseTaskDetailResponse(Map<String, dynamic> response) {
    descriptionController!.text = response['description'] ?? '';
    weatherController!.text = response['weather'] ?? '';
    windDIrectionController!.text = response['winddirection'] ?? '';
    temperaturController!.text = response['temperatur'] ?? '';
    locationController!.text = response['geotag'] ?? '';
    addressController!.text = response['address'] ?? '';
  }

  /// Parse task images dari response
  void _parseTaskImages(Map<String, dynamic> response) {
    imageString.clear();
    imageOldString.clear();
    imageStringVerifiy.clear();
    imageOldStringVerifiy.clear();

    // Parse langsung dari response menggunakan pathname dan pathname_verifikasi
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

    // Cek apakah task baru atau existing
    final isNewTask =
        listTaskList?.tsnumber == null || listTaskList!.tsnumber == "";

    // Validasi hanya untuk task existing yang tidak memiliki data gambar dari API
    // Untuk task baru, user akan mengisi gambar sendiri, jadi tidak perlu warning di sini
    if (!isNewTask) {
      // Task existing (tsnumber tidak null): cek imageString dan imageStringVerifiy dari response API
      if (imageString.isEmpty && imageOldString.isEmpty) {
        logger.w(
            '⚠️ Validasi: imageString dan imageOldString keduanya kosong dari response API');
        if (context != null) {
          ScaffoldMessenger.of(context!).showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 3),
              content: Text(
                'Peringatan: Data gambar sample tidak ditemukan dari response API',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }

      if (imageStringVerifiy.isEmpty && imageOldStringVerifiy.isEmpty) {
        logger.w(
            '⚠️ Validasi: imageStringVerifiy dan imageOldStringVerifiy keduanya kosong dari response API');
        if (context != null) {
          ScaffoldMessenger.of(context!).showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 3),
              content: Text(
                'Peringatan: Data gambar verifikasi tidak ditemukan dari response API',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    }
  }

  /// Parse task parameters dari response
  void _parseTaskParameters(Map<String, dynamic> response) {
    listTakingSampleParameter.clear();
    incrementDetailNoPar = 0;
    final parsed = taskDataService.parseTaskParameters(response, listParameter);
    listTakingSampleParameter.addAll(parsed);
    incrementDetailNoPar = parsed.length;
  }

  /// Parse task CI dari response
  void _parseTaskCI(Map<String, dynamic> response) {
    listTakingSampleCI.clear();
    incrementDetailNoCI = 0;
    final parsed = taskDataService.parseTaskCI(response, equipmentlist);
    listTakingSampleCI.addAll(parsed);
    incrementDetailNoCI = parsed.length;
  }

  // ============================================================================
  // VALIDATION METHODS
  // ============================================================================

  /// Validasi CardTaskInfo (form fields + gambar)
  /// Mengembalikan true jika valid, false jika tidak valid
  bool validateCardTaskInfo() {
    final isNewTask =
        listTaskList?.tsnumber == null || listTaskList!.tsnumber == "";

    if (isNewTask) {
      // Task baru (tsnumber null): cek imageFiles dan imageFilesVerify
      final totalSampleImagesNew = imageFiles.length;
      final imageVerifiyLength = imageFilesVerify.length;

      return validationService.validateCardTaskInfo(
        formKey1: formKey1,
        listTaskList: listTaskList,
        totalSampleImagesNew: totalSampleImagesNew,
        totalSampleImagesOld: 0,
        totalSampleImages: totalSampleImagesNew,
        imageStringVerifiyLength: imageVerifiyLength,
        imageOldStringVerifiyLength: 0,
      );
    } else {
      // Task existing (tsnumber tidak null):
      // 1. Cek imageString dan imageStringVerifiy dulu
      // 2. Jika keduanya kosong, baru cek imageFiles dan imageFilesVerify

      final hasImageString = imageString.isNotEmpty;
      final hasImageStringVerifiy = imageStringVerifiy.isNotEmpty;

      if (hasImageString && hasImageStringVerifiy) {
        // Ada data dari API, gunakan imageString dan imageStringVerifiy
        final totalSampleImages = imageString.length + imageOldString.length;
        return validationService.validateCardTaskInfo(
          formKey1: formKey1,
          listTaskList: listTaskList,
          totalSampleImagesNew: 0,
          totalSampleImagesOld: imageOldString.length,
          totalSampleImages: totalSampleImages,
          imageStringVerifiyLength: imageStringVerifiy.length,
          imageOldStringVerifiyLength: imageOldStringVerifiy.length,
        );
      } else {
        // Tidak ada data dari API (keduanya kosong), cek imageFiles dan imageFilesVerify
        final totalSampleImagesNew = imageFiles.length;
        final imageVerifiyLength = imageFilesVerify.length;

        return validationService.validateCardTaskInfo(
          formKey1: formKey1,
          listTaskList: listTaskList,
          totalSampleImagesNew: totalSampleImagesNew,
          totalSampleImagesOld: 0,
          totalSampleImages: totalSampleImagesNew,
          imageStringVerifiyLength: imageVerifiyLength,
          imageOldStringVerifiyLength: 0,
        );
      }
    }
  }

  /// Validasi CardTaskContainer
  /// Mengembalikan true jika valid, false jika tidak valid
  bool validateCardTaskContainer() {
    return validationService.validateCardTaskContainer(
      equipmentlist: equipmentlist,
      listTakingSampleCI: listTakingSampleCI,
      listTaskList: listTaskList,
    );
  }

  /// Cek apakah semua equipment sudah masuk ke listTakingSampleCI
  bool _isAllEquipmentInList() {
    if (equipmentlist.isEmpty) return true;
    if (listTakingSampleCI.isEmpty) return false;

    final equipmentCodes = equipmentlist
        .map((e) => e.equipmentcode.toString().trim().toUpperCase())
        .toList();

    final ciEquipmentCodes = listTakingSampleCI
        .map((e) => e.equipmentcode.toString().trim().toUpperCase())
        .toList();

    return equipmentCodes.every((code) => ciEquipmentCodes.contains(code));
  }

  /// Validasi CardTaskParameter
  /// Mengembalikan true jika valid, false jika tidak valid
  bool validateCardTaskParameter() {
    return validationService.validateCardTaskParameter(
      listParameter: listParameter,
      listTakingSampleParameter: listTakingSampleParameter,
      listTaskList: listTaskList,
    );
  }

  /// Cek apakah semua parameter sudah masuk ke listTakingSampleParameter
  bool _isAllParameterInList() {
    if (listParameter.isEmpty) return true;
    if (listTakingSampleParameter.isEmpty) return false;

    final parameterCodes = listParameter
        .map((e) => e.parcode.toString().trim().toUpperCase())
        .toList();

    final sampleParameterCodes = listTakingSampleParameter
        .map((e) => e.parcode.toString().trim().toUpperCase())
        .toList();

    return parameterCodes.every((code) => sampleParameterCodes.contains(code));
  }

  /// Validasi form sebelum save
  /// Mengembalikan error message jika tidak valid, null jika valid
  String? validateBeforeSave() {
    // Validasi CardTaskInfo
    if (!validateCardTaskInfo()) {
      if (!formKey1.currentState!.validate()) {
        return AppLocalizations.of(context!)?.formTaskInfoEmpty ??
            "Form Task Info is Empty";
      }

      final isNewTask =
          listTaskList?.tsnumber == null || listTaskList!.tsnumber == "";

      if (isNewTask) {
        // Task baru (tsnumber null): cek imageFiles dan imageFilesVerify
        if (imageFiles.isEmpty) {
          return AppLocalizations.of(context!)?.imageCannotBeEmpty ??
              "Gambar sample tidak boleh kosong. Minimal harus ada 1 gambar sample.";
        }
        if (imageFilesVerify.isEmpty) {
          return AppLocalizations.of(context!)?.imageCannotBeEmpty ??
              "Gambar verifikasi tidak boleh kosong. imageFilesVerify wajib untuk task baru.";
        }
      } else {
        // Task existing (tsnumber tidak null):
        // 1. Cek imageString dan imageStringVerifiy dulu
        // 2. Jika keduanya kosong, baru cek imageFiles dan imageFilesVerify

        final hasImageString = imageString.isNotEmpty;
        final hasImageStringVerifiy = imageStringVerifiy.isNotEmpty;

        if (hasImageString && hasImageStringVerifiy) {
          // Ada data dari API, validasi imageString dan imageStringVerifiy
          if (imageString.isEmpty && imageOldString.isEmpty) {
            return AppLocalizations.of(context!)?.imageCannotBeEmpty ??
                "Gambar sample tidak boleh kosong. Minimal harus ada 1 gambar sample.";
          }
          if (imageStringVerifiy.isEmpty && imageOldStringVerifiy.isEmpty) {
            return AppLocalizations.of(context!)?.imageCannotBeEmpty ??
                "Gambar verifikasi tidak boleh kosong. imageStringVerifiy wajib untuk task existing.";
          }
        } else {
          // Tidak ada data dari API (keduanya kosong), cek imageFiles dan imageFilesVerify
          if (!hasImageString) {
            if (imageFiles.isEmpty) {
              return AppLocalizations.of(context!)?.imageCannotBeEmpty ??
                  "Gambar sample tidak boleh kosong. Minimal harus ada 1 gambar sample.";
            }
          }

          if (!hasImageStringVerifiy) {
            if (imageFilesVerify.isEmpty) {
              return AppLocalizations.of(context!)?.imageCannotBeEmpty ??
                  "Gambar verifikasi tidak boleh kosong. imageFilesVerify wajib untuk task existing.";
            }
          }
        }
      }
    }

    // Validasi CardTaskContainer
    if (!validateCardTaskContainer()) {
      if (equipmentlist.isNotEmpty && listTakingSampleCI.isEmpty) {
        return AppLocalizations.of(context!)?.formContainerInfoEmpty ??
            "Form Container Info is Empty";
      }
      if (equipmentlist.isNotEmpty && !_isAllEquipmentInList()) {
        return AppLocalizations.of(context!)?.formContainerInfoEmpty ??
            "Form Container Info is Empty";
      }
    }

    // Validasi CardTaskParameter
    if (!validateCardTaskParameter()) {
      if (listParameter.isNotEmpty && listTakingSampleParameter.isEmpty) {
        return AppLocalizations.of(context!)?.formParameterEmpty ??
            "Form Parameter is Empty";
      }
      if (listParameter.isNotEmpty && !_isAllParameterInList()) {
        return AppLocalizations.of(context!)?.formParameterEmpty ??
            "Form Parameter is Empty";
      }
    }

    return null; // Valid
  }

  /// Handle save dengan validasi
  Future<void> handleSave() async {
    final errorMessage = validateBeforeSave();
    if (errorMessage != null) {
      _showErrorSnackBar(errorMessage);
      return;
    }

    // Validasi radius lokasi sampling
    final isInRadius = await cekRadiusSamplingLocation();
    if (!isInRadius) {
      _showOutOfRadiusDialog();
      return;
    }

    // Jika semua valid, post data
    await postDataTakingSample();
  }

  /// Show error snackbar
  void _showErrorSnackBar(String message) {
    if (context == null) return;
    ScaffoldMessenger.of(context!).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// Show dialog ketika user berada di luar radius lokasi sampling
  void _showOutOfRadiusDialog() {
    if (context == null) return;
    showDialog(
      context: context!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange, size: 28),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Di Luar Jangkauan",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            "Anda berada di luar jangkauan radius lokasi sampling. "
            "Silakan pindah ke dalam radius ${radiusLocation ?? 0} meter dari lokasi sampling untuk dapat menyimpan data.",
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "OK",
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================================
  // POST DATA METHODS
  // ============================================================================

  /// Post data taking sample ke API
  Future<void> postDataTakingSample() async {
    setBusy(true);
    try {
      final userData = await localService.getUserData();
      final imageBase64List = await _prepareImageBase64List();
      final imageBase64ListVerify = await _prepareImageBase64ListVerify();

      final dataJson = saveService.buildSampleDetailData(
        userData: userData,
        imageBase64List: imageBase64List,
        imageBase64ListVerify: imageBase64ListVerify,
        description: descriptionController!.text,
        tsnumber: listTaskList?.tsnumber,
        samplingdate: '${listTaskList!.samplingdate}',
        sampleName: "${listTaskList!.sampleName}",
        sampleno: "${listTaskList!.sampleno}",
        latlang: latlang,
        longitude: longitude,
        latitude: latitude,
        address: listTaskList!.address,
        weather: weatherController?.text,
        winddirection: windDIrectionController?.text,
        temperatur: temperaturController?.text,
        sampleCode: listTaskList!.sampleCode,
        ptsnumber: listTaskList!.ptsnumber,
        buildingcode: listTaskList?.buildingcode,
        takingSampleParameters: listTakingSampleParameter,
        takingSampleCI: listTakingSampleCI,
        photoOld: imageOldString,
        photoOldVerifikasi: imageOldStringVerifiy,
      );

      final postSample = await apiService.postTakingSample(dataJson);

      if (postSample.data != null) {
        _handlePostSuccess(postSample.data['message']);
      } else {
        _handlePostError(postSample.error);
      }
    } catch (e, stackTrace) {
      _handlePostException(e, stackTrace);
    }
  }

  /// Prepare image base64 list untuk sample biasa
  Future<List<String>> _prepareImageBase64List() async {
    return await imageService.prepareImageBase64List(imageFiles, imageString);
  }

  /// Prepare image base64 list untuk verifikasi
  Future<List<String>> _prepareImageBase64ListVerify() async {
    return await imageService.prepareImageBase64ListVerify(
        imageFilesVerify, imageStringVerifiy);
  }

  /// Handle post success
  void _handlePostSuccess(String message) {
    if (context == null) return;
    ScaffoldMessenger.of(context!).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
    setBusy(false);
    Navigator.of(context!).pushReplacement(
      MaterialPageRoute(builder: (context) => BottomNavigatorView()),
    );
  }

  /// Handle post error
  void _handlePostError(String? error) {
    if (context == null) return;
    setBusy(false);
    ScaffoldMessenger.of(context!).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(error ?? "Unknown error"),
        backgroundColor: Colors.red,
      ),
    );
    notifyListeners();
  }

  /// Handle post exception
  void _handlePostException(dynamic error, StackTrace stackTrace) {
    setBusy(false);
    logger.e("Error Post Data", error: error, stackTrace: stackTrace);
    if (context == null) return;
    ScaffoldMessenger.of(context!).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(
          AppLocalizations.of(context!)?.failedPostData ??
              "Failed to post data",
        ),
        backgroundColor: Colors.red,
      ),
    );
    notifyListeners();
  }

  // ============================================================================
  // FUTURE VIEW MODEL OVERRIDE
  // ============================================================================

  @override
  Future futureToRun() async {
    try {
      if (isDetailhistory == true) {
        await _loadHistoryData();
      } else {
        await _loadNewTaskData();
      }
      notifyListeners();
    } catch (e, stackTrace) {
      logger.e('Error in futureToRun', error: e, stackTrace: stackTrace);
      setBusy(false);
      notifyListeners();
    }
  }

  /// Load history data
  Future<void> _loadHistoryData() async {
    await getOneTaskList();
    if (listTaskList?.geotag != null && listTaskList!.geotag!.isNotEmpty) {
      locationController!.text = listTaskList!.geotag!;
      latlang = listTaskList!.geotag!;
    }
  }

  /// Load new task data
  Future<void> _loadNewTaskData() async {
    await getData();
    await getOneTaskList();
  }
}
