import 'dart:convert';
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
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

  TextEditingController? locationController = TextEditingController();
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

  TextEditingController? institutController = TextEditingController();
  TextEditingController? descriptionParController = TextEditingController();
  bool? isCalibration = false;

  // ============================================================================
  // VALIDATION FLAGS
  // ============================================================================
  bool? isConfirm = false;
  bool? allExistParameter = false;

  // ============================================================================
  // IMAGE PICKER METHODS
  // ============================================================================

  /// Pick image dari gallery untuk sample biasa
  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      final newFile = File(pickedFile.path);
      final alreadyExists = imageFiles.any((f) => f.path == newFile.path);

      if (!alreadyExists) {
        imageFiles.add(newFile);
        validasiConfirm();
        notifyListeners();
      }
    }
  }

  /// Pick image untuk verifikasi (dengan geotagging jika dari camera)
  Future<void> pickImageVerify() async {
    if (context == null) return;

    final source = await _showImageSourceDialog();
    if (source == null) return;

    // Ambil lokasi jika dari camera dan belum ada
    if (source == ImageSource.camera && (latlang == null || latlang!.isEmpty)) {
      final success = await _requestLocationForCamera();
      if (!success) return;
    }

    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile == null) return;

    final processedFile = await _processImageFile(
      File(pickedFile.path),
      source,
    );

    if (!imageFilesVerify.any((f) => f.path == processedFile.path)) {
      imageFilesVerify.add(processedFile);
      if (latlang != null && latlang!.isNotEmpty) {
        locationController?.text = latlang!;
      }
      validasiConfirm();
      notifyListeners();
    }
  }

  /// Tampilkan dialog untuk memilih sumber gambar
  Future<ImageSource?> _showImageSourceDialog() async {
    return await showModalBottomSheet<ImageSource>(
      context: context!,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(
                  AppLocalizations.of(context)?.gallery ?? 'Gallery',
                ),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: Text(
                  AppLocalizations.of(context)?.camera ?? 'Camera',
                ),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Request lokasi untuk camera (dengan permission handling)
  Future<bool> _requestLocationForCamera() async {
    try {
      setBusy(true);
      final permission = await _checkAndRequestLocationPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showLocationPermissionError();
        setBusy(false);
        return false;
      }

      await _fetchCurrentLocation();

      // Validasi fake GPS setelah mendapatkan lokasi
      if (userPosition != null) {
        final isFake = await _isFakeGPS(userPosition!);
        if (isFake) {
          _showFakeGPSWarning();
          setBusy(false);
          return false;
        }
      }

      await _fetchAddressFromLocation();
      _updateLocationController();

      setBusy(false);
      return true;
    } catch (e) {
      setBusy(false);
      _showLocationError();
      return false;
    }
  }

  /// Check dan request location permission
  Future<LocationPermission> _checkAndRequestLocationPermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission;
  }

  /// Fetch current location dari GPS
  Future<void> _fetchCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Simpan position untuk validasi fake GPS
    userPosition = position;

    currentLocation = LatLng(position.latitude, position.longitude);
    latlang = '${currentLocation!.latitude},${currentLocation!.longitude}';
    latitude = '${currentLocation!.latitude}';
    longitude = '${currentLocation!.longitude}';
  }

  /// Fetch address dari koordinat (reverse geocoding)
  Future<void> _fetchAddressFromLocation() async {
    try {
      final placemarks = await placemarkFromCoordinates(
        currentLocation!.latitude,
        currentLocation!.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks[0];
        final safe = (String? val) => val ?? '';

        address = "${safe(placemark.street)}, ${safe(placemark.name)}, "
            "${safe(placemark.subLocality)}, ${safe(placemark.postalCode)}, "
            "${safe(placemark.locality)}, ${safe(placemark.subAdministrativeArea)}, "
            "${safe(placemark.administrativeArea)}, ${safe(placemark.country)}";
        namaJalan = safe(placemark.street);
      } else {
        _setDefaultAddress();
      }
    } catch (e) {
      _setDefaultAddress();
    }
  }

  /// Set default address jika geocoding gagal
  void _setDefaultAddress() {
    address = "Location: ${latlang}";
    namaJalan = "Location";
  }

  /// Update location controller dengan latlang
  void _updateLocationController() {
    if (locationController != null && latlang != null) {
      locationController!.text = latlang!;
    }
  }

  /// Cek apakah lokasi adalah fake GPS (mock location)
  Future<bool> _isFakeGPS(Position position) async {
    try {
      // 1. Cek menggunakan platform channel (Android)
      if (Platform.isAndroid) {
        try {
          const platform = MethodChannel('com.salims_apps/mock_location');
          final bool isMock = await platform.invokeMethod('isMockLocation');
          if (isMock) {
            logger.w(
                'Fake GPS detected: Platform channel detected mock location');
            return true;
          }
        } catch (e) {
          logger.w('Error checking mock location via platform channel: $e');
        }
      }

      // 2. Cek accuracy yang tidak masuk akal
      // Accuracy yang terlalu tinggi (kurang dari 1 meter) atau terlalu rendah (lebih dari 1000 meter) bisa mencurigakan
      if (position.accuracy < 1.0 || position.accuracy > 1000.0) {
        logger
            .w('Fake GPS detected: Suspicious accuracy: ${position.accuracy}');
        return true;
      }

      // 3. Cek koordinat yang tidak masuk akal (di luar range valid)
      if (position.latitude < -90 ||
          position.latitude > 90 ||
          position.longitude < -180 ||
          position.longitude > 180) {
        logger.w('Fake GPS detected: Invalid coordinates');
        return true;
      }

      // 4. Cek speed yang tidak masuk akal (jika tersedia)
      if (position.speed > 0 && position.speed > 1000) {
        // Speed lebih dari 1000 m/s (3600 km/h) tidak masuk akal
        logger.w('Fake GPS detected: Suspicious speed: ${position.speed} m/s');
        return true;
      }

      // 5. Cek timestamp yang terlalu lama (jika lokasi terlalu lama tidak update)
      final now = DateTime.now();
      final positionTime = position.timestamp;
      final timeDiff = now.difference(positionTime).inSeconds;
      if (timeDiff > 300) {
        // Jika data lokasi lebih dari 5 menit yang lalu, mencurigakan
        logger
            .w('Fake GPS detected: Stale location data: $timeDiff seconds old');
        return true;
      }

      return false;
    } catch (e) {
      logger.e('Error checking fake GPS: $e');
      // Jika terjadi error, lebih baik tidak menganggap sebagai fake GPS
      return false;
    }
  }

  /// Tampilkan warning jika terdeteksi fake GPS
  void _showFakeGPSWarning() {
    if (context == null) return;

    showDialog(
      context: context!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red, size: 28),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Peringatan Lokasi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Aplikasi mendeteksi bahwa Anda menggunakan aplikasi pihak ketiga untuk memanipulasi lokasi GPS. '
            'Silakan nonaktifkan aplikasi fake GPS dan gunakan lokasi GPS asli untuk melanjutkan.',
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'OK',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Process image file (tambah geotag jika dari camera)
  Future<File> _processImageFile(File imageFile, ImageSource source) async {
    if (source == ImageSource.camera &&
        latlang != null &&
        latlang!.isNotEmpty) {
      return await _addGeotagToImage(imageFile);
    }
    return imageFile;
  }

  /// Show error message untuk location permission
  void _showLocationPermissionError() {
    if (context == null) return;
    ScaffoldMessenger.of(context!).showSnackBar(
      const SnackBar(
        duration: Duration(seconds: 3),
        content: Text(
          'Izin lokasi diperlukan untuk mengambil foto dengan geotag. '
          'Silakan aktifkan izin lokasi di pengaturan.',
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// Show error message untuk location error
  void _showLocationError() {
    if (context == null) return;
    ScaffoldMessenger.of(context!).showSnackBar(
      const SnackBar(
        duration: Duration(seconds: 3),
        content: Text(
          'Gagal mengambil lokasi GPS. Pastikan GPS aktif dan coba lagi.',
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  // ============================================================================
  // GEOTAG IMAGE PROCESSING
  // ============================================================================

  /// Tambahkan geotag overlay ke gambar
  Future<File> _addGeotagToImage(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      if (image == null) return imageFile;

      // Konfigurasi
      const double textScale = 2.0;
      final textData = _prepareTextData();
      final overlayConfig = _calculateOverlayConfig(image, textScale);

      // Buat combined image
      final combinedImage = _createCombinedImage(image, overlayConfig);

      // Gambar teks overlay
      _drawTextOverlay(combinedImage, textData, overlayConfig, textScale);

      // Simpan file
      return await _saveProcessedImage(combinedImage, imageFile);
    } catch (e) {
      logger.e('Error adding geotag to image', error: e);
      return imageFile;
    }
  }

  /// Prepare text data untuk overlay
  Map<String, String> _prepareTextData() {
    final now = DateTime.now();
    return {
      'dateTime': DateFormat('dd MMM yyyy HH.mm.ss').format(now),
      'geotag': latlang ?? 'No location',
      'address': namaJalan ?? address ?? 'No address',
    };
  }

  /// Calculate overlay configuration
  Map<String, dynamic> _calculateOverlayConfig(
    img.Image image,
    double textScale,
  ) {
    final overlayHeight = (image.height * 0.6).round().clamp(300, 700);
    final lineSpacing = (120 * textScale).round();
    final overlayStartY = image.height - overlayHeight;
    final textX = (80 * textScale).round();

    return {
      'overlayHeight': overlayHeight,
      'lineSpacing': lineSpacing,
      'overlayStartY': overlayStartY,
      'textX': textX,
    };
  }

  /// Create combined image dengan overlay background
  img.Image _createCombinedImage(
    img.Image image,
    Map<String, dynamic> config,
  ) {
    final combinedImage = img.Image(
      width: image.width,
      height: image.height,
    );

    // Copy gambar asli
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        combinedImage.setPixel(x, y, image.getPixel(x, y));
      }
    }

    // Apply overlay background
    final overlayStartY = config['overlayStartY'] as int;

    for (int y = overlayStartY; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = combinedImage.getPixel(x, y);
        combinedImage.setPixel(
          x,
          y,
          img.ColorRgb8(
            (pixel.r * 0.3).round(),
            (pixel.g * 0.3).round(),
            (pixel.b * 0.3).round(),
          ),
        );
      }
    }

    return combinedImage;
  }

  /// Draw text overlay pada image
  void _drawTextOverlay(
    img.Image combinedImage,
    Map<String, String> textData,
    Map<String, dynamic> config,
    double textScale,
  ) {
    final overlayStartY = config['overlayStartY'] as int;
    final overlayHeight = config['overlayHeight'] as int;
    final lineSpacing = config['lineSpacing'] as int;
    final textX = config['textX'] as int;

    final dateTimeY = overlayStartY + (overlayHeight ~/ 4);
    final geotagY = dateTimeY + lineSpacing;
    final addressY = geotagY + lineSpacing;

    final offsets = _calculateOutlineOffsets(textScale);

    _drawText(
      combinedImage,
      textData['dateTime']!,
      textX,
      dateTimeY,
      offsets,
    );
    _drawText(
      combinedImage,
      textData['geotag']!,
      textX,
      geotagY,
      offsets,
    );
    _drawText(
      combinedImage,
      textData['address']!,
      textX,
      addressY,
      offsets,
    );
  }

  /// Calculate outline offsets berdasarkan scale
  List<List<int>> _calculateOutlineOffsets(double scale) {
    final s = (12 * scale).round();
    return [
      [-s, -s],
      [-s, 0],
      [-s, s],
      [0, -s],
      [0, s],
      [s, -s],
      [s, 0],
      [s, s],
    ];
  }

  /// Draw text dengan outline
  void _drawText(
    img.Image image,
    String text,
    int x,
    int y,
    List<List<int>> offsets,
  ) {
    // Draw outline hitam
    for (var offset in offsets) {
      img.drawString(
        image,
        text,
        font: img.arial48,
        x: x + offset[0],
        y: y + offset[1],
        color: img.ColorRgb8(0, 0, 0),
      );
    }

    // Draw teks putih
    img.drawString(
      image,
      text,
      font: img.arial48,
      x: x,
      y: y,
      color: img.ColorRgb8(255, 255, 255),
    );
  }

  /// Save processed image ke file baru
  Future<File> _saveProcessedImage(
    img.Image combinedImage,
    File originalFile,
  ) async {
    final directory = originalFile.parent;
    final fileName =
        'image_${DateTime.now().millisecondsSinceEpoch}_geotag.jpg';
    final newFile = File('${directory.path}/$fileName');

    await newFile.writeAsBytes(
      img.encodeJpg(combinedImage, quality: 90),
    );

    return newFile;
  }

  // ============================================================================
  // LOCATION METHODS
  // ============================================================================

  /// Set location name dari GPS
  Future<void> setLocationName() async {
    setBusy(true);
    try {
      final permission = await _checkAndRequestLocationPermission();
      if (permission == LocationPermission.deniedForever) {
        setBusy(false);
        return;
      }

      await _fetchCurrentLocation();

      // Validasi fake GPS setelah mendapatkan lokasi
      if (userPosition != null) {
        final isFake = await _isFakeGPS(userPosition!);
        if (isFake) {
          _showFakeGPSWarning();
          setBusy(false);
          return;
        }
      }

      await _fetchAddressFromLocation();
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

  // ============================================================================
  // PARAMETER METHODS
  // ============================================================================

  /// Tambahkan parameter ke list
  void addListParameter() {
    incrementDetailNoPar = (incrementDetailNoPar ?? 0) + 1;

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

    for (var parameter in listParameter) {
      if (parameter.parcode == parameterSelect?.parcode) {
        listParameter.remove(parameter);
        break;
      }
    }

    _resetParameterForm();
    validasiConfirm();
    notifyListeners();
  }

  /// Reset form parameter
  void _resetParameterForm() {
    parameterSelect = null;
    institutController?.text = "";
    descriptionParController?.text = "";
    isCalibration = false;
    dropdownKeyParameter.currentState?.clearValue();
  }

  /// Hapus parameter dari list
  void removeListPar(int index, dynamic data) {
    for (var parameter in listParameter2) {
      if (parameter.parcode == data.parcode) {
        listParameter.add(parameter);
        break;
      }
    }
    incrementDetailNoPar = 0;
    listTakingSampleParameter.removeAt(index);
    _reindexParameterList();
    validasiConfirm();
    notifyListeners();
  }

  /// Re-index parameter list
  void _reindexParameterList() {
    for (int i = 0; i < listTakingSampleParameter.length; i++) {
      listTakingSampleParameter[i].detailno = i.toString();
      incrementDetailNoPar = incrementDetailNoPar! + 1;
    }
  }

  // ============================================================================
  // CONTAINER INFO (CI) METHODS
  // ============================================================================

  /// Tambahkan CI ke list
  void addListCI() {
    incrementDetailNoCI = incrementDetailNoCI! + 1;
    listTakingSampleCI.add(
      TakingSampleCI(
        key: "",
        detailno: "${incrementDetailNoCI}",
        equipmentcode: '${equipmentSelect?.equipmentcode}',
        equipmentname: '${equipmentSelect?.equipmentname}',
        conqty: int.parse(conQTYController!.text),
        conuom: '${conSelect?.name}',
        volqty: int.parse(volQTYController!.text),
        voluom: '${volSelect?.name}',
        description: '${descriptionCIController?.text}',
      ),
    );

    // Remove equipment dari list setelah ditambahkan
    for (var equipment in equipmentlist) {
      if (equipment.equipmentcode == equipmentSelect?.equipmentcode) {
        equipmentlist.remove(equipment);
        break;
      }
    }

    _resetCIForm();
    validasiConfirm();
    notifyListeners();
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
    // Restore equipment ke list
    for (var equipment in equipmentlist2) {
      if (equipment.equipmentcode == data.equipmentcode) {
        equipmentlist.add(equipment);
        break;
      }
    }

    incrementDetailNoCI = 0;
    listTakingSampleCI.removeAt(index);
    _reindexCIList();
    validasiConfirm();
    notifyListeners();
  }

  /// Re-index CI list
  void _reindexCIList() {
    for (int i = 0; i < listTakingSampleCI.length; i++) {
      listTakingSampleCI[i].detailno = i.toString();
      incrementDetailNoCI = incrementDetailNoCI! + 1;
    }
  }

  // ============================================================================
  // IMAGE CONVERSION METHODS
  // ============================================================================

  /// Convert image file ke base64
  Future<String> convertImageToBase64(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final base64String = base64Encode(bytes);
    final ext = imageFile.path.split('.').last.toLowerCase();

    final mimeType = _getMimeType(ext);
    return 'data:$mimeType;base64,$base64String';
  }

  /// Convert image URL ke base64
  Future<String> convertImageUrlToBase64(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        final base64Image = base64Encode(response.bodyBytes);
        return "data:image/jpeg;base64,$base64Image";
      } else {
        throw Exception('Gagal mengambil gambar: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error converting image URL to base64', error: e);
      return '';
    }
  }

  /// Get MIME type berdasarkan extension
  String _getMimeType(String ext) {
    switch (ext.toLowerCase()) {
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      default:
        return 'image/jpeg';
    }
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
    final dataPars = response?.data?['data']?['testing_order_parameters'];

    if (dataPars is List) {
      listParameter = dataPars
          .map((e) => TestingOrderParameter.fromJson(e as Map<String, dynamic>))
          .toList();
      listParameter2 = List.from(listParameter);
    } else {
      listParameter = [];
      listParameter2 = [];
    }
  }

  /// Parse equipment data dari response
  void _parseEquipmentData(dynamic response) {
    final dataEquipments = response?.data?['data']?['testing_order_equipment'];

    if (dataEquipments is List) {
      equipmentlist = dataEquipments
          .map((e) => Equipment.fromJson(e as Map<String, dynamic>))
          .toList();
      equipmentlist2 = List.from(equipmentlist);
    } else {
      equipmentlist = [];
      equipmentlist2 = [];
    }
  }

  /// Initialize location data
  void _initializeLocationData() {
    if (listTaskList?.geotag != null) {
      locationController!.text = listTaskList!.geotag!;
      latlang = listTaskList!.geotag!;
    }
  }

  /// Validate parameters
  void _validateParameters() {
    if (listTaskList?.tsnumber == '' || listParameter.isEmpty) {
      if (listTakingSampleCI.isNotEmpty) {
        isConfirm = true;
      }
      return;
    }

    final groupedData = groupBy(
      listTakingSampleParameter,
      (item) => item.parcode.toString().trim().toUpperCase(),
    );

    final groupedKeys = groupedData.keys.toList();
    final parameterCodes = listParameter
        .map((e) => e.parcode.toString().trim().toUpperCase())
        .toList();

    allExistParameter =
        parameterCodes.every((code) => groupedKeys.contains(code));
    isConfirm = listTakingSampleCI.isNotEmpty && allExistParameter == true;
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
  }

  /// Parse task parameters dari response
  void _parseTaskParameters(Map<String, dynamic> response) {
    listTakingSampleParameter.clear();
    incrementDetailNoPar = 0;

    if (response['taking_sample_parameters'] != null &&
        response['taking_sample_parameters'] is List) {
      for (var item in response['taking_sample_parameters']) {
        try {
          listTakingSampleParameter.add(TakingSampleParameter.fromJson(item));
          incrementDetailNoPar = incrementDetailNoPar! + 1;

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
  }

  /// Parse task CI dari response
  void _parseTaskCI(Map<String, dynamic> response) {
    listTakingSampleCI.clear();
    incrementDetailNoCI = 0;

    if (response['taking_sample_ci'] != null &&
        response['taking_sample_ci'] is List) {
      for (var item in response['taking_sample_ci']) {
        try {
          listTakingSampleCI.add(TakingSampleCI.fromJson(item));
          incrementDetailNoCI = incrementDetailNoCI! + 1;

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
  }

  // ============================================================================
  // VALIDATION METHODS
  // ============================================================================

  /// Validasi CardTaskInfo (form fields + gambar)
  /// Mengembalikan true jika valid, false jika tidak valid
  bool validateCardTaskInfo() {
    // Validasi form task info
    if (!formKey1.currentState!.validate()) {
      return false;
    }

    // Cek apakah task baru atau existing
    final isNewTask =
        listTaskList?.tsnumber == null || listTaskList?.tsnumber == "";

    // Validasi gambar
    if (isNewTask) {
      if (imageFiles.isEmpty || imageFilesVerify.isEmpty) {
        return false;
      }
    } else {
      if (imageString.isEmpty || imageStringVerifiy.isEmpty) {
        return false;
      }
    }

    return true;
  }

  /// Validasi CardTaskContainer
  /// Mengembalikan true jika valid, false jika tidak valid
  bool validateCardTaskContainer() {
    // Jika tidak ada equipment list, tidak perlu validasi
    if (equipmentlist.isEmpty) {
      return true;
    }

    // Cek apakah tsnumber ada (task existing)
    final hasTsnumber =
        listTaskList?.tsnumber != null && listTaskList!.tsnumber != "";

    if (hasTsnumber) {
      // Untuk task existing, cek apakah listTakingSampleCI tidak kosong
      // dan semua equipment sudah masuk
      if (listTakingSampleCI.isEmpty) {
        return false;
      }
      // Cek apakah semua equipment sudah masuk ke listTakingSampleCI
      return _isAllEquipmentInList();
    } else {
      // Untuk task baru, cukup cek apakah ada data di listTakingSampleCI
      return listTakingSampleCI.isNotEmpty;
    }
  }

  /// Cek apakah semua equipment sudah masuk ke listTakingSampleCI
  bool _isAllEquipmentInList() {
    if (equipmentlist.isEmpty) return true;
    if (listTakingSampleCI.isEmpty) return false;

    // Ambil semua equipmentcode dari equipmentlist
    final equipmentCodes = equipmentlist
        .map((e) => e.equipmentcode.toString().trim().toUpperCase())
        .toList();

    // Ambil semua equipmentcode dari listTakingSampleCI
    final ciEquipmentCodes = listTakingSampleCI
        .map((e) => e.equipmentcode.toString().trim().toUpperCase())
        .toList();

    // Cek apakah semua equipmentcode dari equipmentlist ada di listTakingSampleCI
    return equipmentCodes.every((code) => ciEquipmentCodes.contains(code));
  }

  /// Validasi CardTaskParameter
  /// Mengembalikan true jika valid, false jika tidak valid
  bool validateCardTaskParameter() {
    // Jika tidak ada parameter list, tidak perlu validasi
    if (listParameter.isEmpty) {
      return true;
    }

    // Cek apakah tsnumber ada (task existing)
    final hasTsnumber =
        listTaskList?.tsnumber != null && listTaskList!.tsnumber != "";

    if (hasTsnumber) {
      // Untuk task existing, cek apakah listTakingSampleParameter tidak kosong
      // dan semua parameter sudah masuk
      if (listTakingSampleParameter.isEmpty) {
        return false;
      }
      // Cek apakah semua parameter sudah masuk ke listTakingSampleParameter
      return _isAllParameterInList();
    } else {
      // Untuk task baru, cukup cek apakah ada data di listTakingSampleParameter
      return listTakingSampleParameter.isNotEmpty;
    }
  }

  /// Cek apakah semua parameter sudah masuk ke listTakingSampleParameter
  bool _isAllParameterInList() {
    if (listParameter.isEmpty) return true;
    if (listTakingSampleParameter.isEmpty) return false;

    // Ambil semua parcode dari listParameter
    final parameterCodes = listParameter
        .map((e) => e.parcode.toString().trim().toUpperCase())
        .toList();

    // Ambil semua parcode dari listTakingSampleParameter
    final sampleParameterCodes = listTakingSampleParameter
        .map((e) => e.parcode.toString().trim().toUpperCase())
        .toList();

    // Cek apakah semua parcode dari listParameter ada di listTakingSampleParameter
    return parameterCodes.every((code) => sampleParameterCodes.contains(code));
  }

  /// Validasi semua card untuk menentukan apakah tombol Confirm muncul
  /// Mengembalikan true jika semua validasi terpenuhi
  bool validateAllCards() {
    return validateCardTaskInfo() &&
        validateCardTaskContainer() &&
        validateCardTaskParameter();
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
        if (imageFiles.isEmpty || imageFilesVerify.isEmpty) {
          return AppLocalizations.of(context!)?.imageCannotBeEmpty ??
              "Gambar tidak boleh kosong";
        }
      } else {
        if (imageString.isEmpty || imageStringVerifiy.isEmpty) {
          if (imageFiles.isEmpty || imageFilesVerify.isEmpty) {
            return AppLocalizations.of(context!)?.imageCannotBeEmpty ??
                "Gambar tidak boleh kosong";
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

  /// Validasi konfirmasi - update isConfirm berdasarkan validasi semua card
  Future<void> validasiConfirm() async {
    try {
      // Update isConfirm berdasarkan validasi semua card
      isConfirm = validateAllCards();

      // Update allExistParameter untuk backward compatibility
      if (listParameter.isNotEmpty) {
        allExistParameter = _isAllParameterInList();
      } else {
        allExistParameter = true;
      }

      notifyListeners();
    } catch (e) {
      logger.e('Error validating confirm', error: e);
    }
  }

  // ============================================================================
  // POST DATA METHODS
  // ============================================================================

  /// Confirm post dengan validasi location range
  Future<void> confirmPost() async {
    try {
      setBusy(true);
      if (isChangeLocation == true) {
        await postDataTakingSample();
      } else {
        final isInRange = await cekRangeLocation();
        if (!isInRange) {
          _showOutOfRangeError();
          setBusy(false);
          notifyListeners();
          return;
        }
      }
      notifyListeners();
    } catch (e) {
      _showConfirmError(e);
      setBusy(false);
      notifyListeners();
    }
  }

  /// Show out of range error
  void _showOutOfRangeError() {
    if (context == null) return;
    ScaffoldMessenger.of(context!).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(
          AppLocalizations.of(context!)?.outOfLocationRange ??
              "You are out of location range",
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// Show confirm error
  void _showConfirmError(dynamic error) {
    if (context == null) return;
    ScaffoldMessenger.of(context!).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(
          "${AppLocalizations.of(context!)?.failedConfirm ?? "Failed to confirm"}: $error",
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// Post data taking sample ke API
  Future<void> postDataTakingSample() async {
    setBusy(true);
    try {
      final userData = await localService.getUserData();
      final imageBase64List = await _prepareImageBase64List();
      final imageBase64ListVerify = await _prepareImageBase64ListVerify();

      final dataJson = _buildSampleDetailData(
        userData,
        imageBase64List,
        imageBase64ListVerify,
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
    final List<String> imageBase64List = [];

    // Convert file images
    for (var file in imageFiles) {
      final base64Str = await convertImageToBase64(file);
      imageBase64List.add(base64Str);
    }

    // Convert URL images
    if (imageString.isNotEmpty) {
      for (var url in imageString) {
        final base64Str = await convertImageUrlToBase64(url);
        if (base64Str.isNotEmpty) {
          imageBase64List.add(base64Str);
        }
      }
    }

    return imageBase64List;
  }

  /// Prepare image base64 list untuk verifikasi
  Future<List<String>> _prepareImageBase64ListVerify() async {
    final List<String> imageBase64ListVerify = [];

    // Convert file images
    for (var file in imageFilesVerify) {
      final base64Str = await convertImageToBase64(file);
      imageBase64ListVerify.add(base64Str);
    }

    // Convert URL images
    if (imageStringVerifiy.isNotEmpty) {
      for (var url in imageStringVerifiy) {
        final base64Str = await convertImageUrlToBase64(url);
        if (base64Str.isNotEmpty) {
          imageBase64ListVerify.add(base64Str);
        }
      }
    }

    return imageBase64ListVerify;
  }

  /// Build SampleDetail data untuk POST
  SampleDetail _buildSampleDetailData(
    dynamic userData,
    List<String> imageBase64List,
    List<String> imageBase64ListVerify,
  ) {
    return SampleDetail(
      description: descriptionController!.text,
      tsnumber: "${listTaskList?.tsnumber ?? ''}",
      tranidx: "1203",
      periode: DateFormat('yyyyMM').format(
        DateTime.parse('${listTaskList!.samplingdate}'),
      ),
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
      branchcode: "${userData?.data?.branchcode}",
      samplecode: "${listTaskList!.sampleCode}",
      ptsnumber: "${listTaskList!.ptsnumber}",
      usercreated: "${userData?.data?.username}",
      samplingby: "${userData?.data?.username}",
      buildingcode: "${listTaskList?.buildingcode}",
      takingSampleParameters: listTakingSampleParameter,
      takingSampleCI: listTakingSampleCI,
      photoOld: imageOldString,
      uploadFotoSample: imageBase64List,
      photoOldVerifikasi: imageOldStringVerifiy,
      uploadFotoVerifikasi: imageBase64ListVerify,
    );
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

  /// Confirm task (update status)
  Future<void> confirm() async {
    setBusy(true);
    try {
      await handleSave();
      final dataJson = {
        'tsnumber': '${listTaskList?.tsnumber}',
        'tsdate': '${listTaskList?.tsdate}',
        'ptsnumber': '${listTaskList?.ptsnumber}',
        'sampleno': '${listTaskList?.sampleno}',
      };

      final response = await apiService.updateStatus(dataJson);

      if (response.data['status'] == true) {
        _handleConfirmSuccess(response.data['message']);
      } else {
        _handleConfirmError(response.data['message']);
      }
    } catch (e) {
      logger.e('Error confirming task', error: e);
      setBusy(false);
      notifyListeners();
    }
  }

  /// Handle confirm success
  void _handleConfirmSuccess(String message) {
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
    notifyListeners();
  }

  /// Handle confirm error
  void _handleConfirmError(String message) {
    if (context == null) return;
    ScaffoldMessenger.of(context!).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
    setBusy(false);
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
    await validasiConfirm();
  }
}
