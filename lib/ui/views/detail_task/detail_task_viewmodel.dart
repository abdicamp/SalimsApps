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
    try {
      setBusy(true);
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
      final source = await _showImageSourceDialog();
      if (source == null) return;

      // Ambil lokasi jika dari camera dan belum ada
      if (source == ImageSource.camera && (latlang == null || latlang!.isEmpty)) {
        final success = await _requestLocationForCamera();
        if (!success) {
          setBusy(false);
          return;
        }
        // Pastikan geocoding selesai dan alamat sudah di-set
        logger.i('Lokasi dan alamat sudah diambil sebelum mengambil foto');
        logger.i('Alamat: $address');
        logger.i('Nama jalan: $namaJalan');
      } else if (source == ImageSource.camera && (address == null || address!.isEmpty || namaJalan == null || namaJalan!.isEmpty)) {
        // Jika lokasi sudah ada tapi alamat belum, coba ambil alamat lagi
        logger.i('Lokasi sudah ada tapi alamat belum, mencoba geocoding lagi...');
        if (currentLocation != null) {
          await _fetchAddressFromLocation();
        }
      }

      setBusy(true);
      notifyListeners();

      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile == null) {
        setBusy(false);
        return;
      }

      // Proses gambar dengan geotag (ini yang lama)
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

      // Pastikan alamat sudah di-set setelah geocoding
      logger.i('Setelah geocoding:');
      logger.i('  - address: $address');
      logger.i('  - namaJalan: $namaJalan');
      logger.i('  - latlang: $latlang');

      // Jika geocoding gagal, coba sekali lagi dengan delay
      if ((address == null || address!.isEmpty || address == 'Location unavailable' || address!.startsWith('Location:')) &&
          (namaJalan == null || namaJalan!.isEmpty || namaJalan == 'Location' || namaJalan == 'Location unavailable')) {
        logger.w('Geocoding pertama gagal, mencoba sekali lagi...');
        await Future.delayed(const Duration(seconds: 1));
        await _fetchAddressFromLocation();
        logger.i('Setelah retry geocoding:');
        logger.i('  - address: $address');
        logger.i('  - namaJalan: $namaJalan');
      }

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

  /// Fetch address dari koordinat (reverse geocoding) dengan retry
  Future<void> _fetchAddressFromLocation() async {
    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        logger.i('Memulai reverse geocoding (attempt ${retryCount + 1}/$maxRetries)...');
        logger.i('Koordinat: ${currentLocation!.latitude}, ${currentLocation!.longitude}');

        final placemarks = await placemarkFromCoordinates(
          currentLocation!.latitude,
          currentLocation!.longitude,
        ).timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            logger.w('Geocoding timeout setelah 15 detik');
            return <Placemark>[];
          },
        );

        if (placemarks.isNotEmpty) {
          final placemark = placemarks[0];
          final safe = (String? val) => val ?? '';

          // Buat alamat lengkap
          final street = safe(placemark.street);
          final name = safe(placemark.name);
          final subLocality = safe(placemark.subLocality);
          final locality = safe(placemark.locality);
          final administrativeArea = safe(placemark.administrativeArea);
          final country = safe(placemark.country);

          // Buat alamat yang lebih informatif
          List<String> addressParts = [];
          if (street.isNotEmpty) addressParts.add(street);
          if (name.isNotEmpty && name != street) addressParts.add(name);
          if (subLocality.isNotEmpty) addressParts.add(subLocality);
          if (locality.isNotEmpty) addressParts.add(locality);
          if (administrativeArea.isNotEmpty) addressParts.add(administrativeArea);
          if (country.isNotEmpty && country != 'Indonesia') addressParts.add(country);
          
          if (addressParts.isNotEmpty) {
            address = addressParts.join(', ');
            namaJalan = street.isNotEmpty
                ? street
                : (name.isNotEmpty
                    ? name
                    : (locality.isNotEmpty ? locality : 'Location'));

            logger.i('✅ Alamat berhasil didapat: $address');
            logger.i('✅ Nama jalan: $namaJalan');
            return; // Berhasil, keluar dari loop
          } else {
            logger.w('Placemark ditemukan tapi tidak ada data alamat');
          }
        } else {
          logger.w('Tidak ada placemark ditemukan');
        }
      } catch (e, stackTrace) {
        logger.e('Error fetching address (attempt ${retryCount + 1}/$maxRetries)',
            error: e, stackTrace: stackTrace);
      }

      retryCount++;
      if (retryCount < maxRetries) {
        logger.i('Retry geocoding dalam 2 detik...');
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    // Jika semua retry gagal, coba menggunakan OpenStreetMap Nominatim API
    logger.w('Geocoding package gagal setelah $maxRetries attempts, mencoba OpenStreetMap API...');
    try {
      await _fetchAddressFromOpenStreetMap();
    } catch (e) {
      logger.e('OpenStreetMap API juga gagal', error: e);
      _setDefaultAddress();
    }
  }

  /// Fetch address menggunakan OpenStreetMap Nominatim API (fallback)
  Future<void> _fetchAddressFromOpenStreetMap() async {
    try {
      logger.i('Mencoba geocoding menggunakan OpenStreetMap Nominatim API...');
      final lat = currentLocation!.latitude;
      final lng = currentLocation!.longitude;

      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&addressdetails=1',
      );
      
      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'SalimsApps/1.0', // Required by Nominatim
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final addressData = data['address'] as Map<String, dynamic>?;

        if (addressData != null) {
          final safe = (dynamic val) => val?.toString() ?? '';

          // Ambil bagian alamat yang relevan
          final road = safe(addressData['road']);
          final houseNumber = safe(addressData['house_number']);
          final suburb = safe(addressData['suburb']);
          final city = safe(addressData['city'] ?? addressData['town'] ?? addressData['village']);
          final state = safe(addressData['state']);
          final country = safe(addressData['country']);
          
          // Buat alamat lengkap
          List<String> addressParts = [];
          if (houseNumber.isNotEmpty && road.isNotEmpty) {
            addressParts.add('$houseNumber $road');
          } else if (road.isNotEmpty) {
            addressParts.add(road);
          }
          if (suburb.isNotEmpty) addressParts.add(suburb);
          if (city.isNotEmpty) addressParts.add(city);
          if (state.isNotEmpty) addressParts.add(state);
          if (country.isNotEmpty && country != 'Indonesia') addressParts.add(country);
          
          if (addressParts.isNotEmpty) {
            address = addressParts.join(', ');
            namaJalan = road.isNotEmpty
                ? road
                : (city.isNotEmpty ? city : 'Location');

            logger.i('✅ Alamat berhasil didapat dari OpenStreetMap: $address');
            logger.i('✅ Nama jalan: $namaJalan');
            return;
          }
        }
      }

      logger.w('OpenStreetMap API tidak mengembalikan alamat yang valid');
      _setDefaultAddress();
    } catch (e, stackTrace) {
      logger.e('Error fetching address from OpenStreetMap', error: e, stackTrace: stackTrace);
      _setDefaultAddress();
    }
  }

  /// Set default address jika geocoding gagal
  void _setDefaultAddress() {
    logger.w('Geocoding gagal, menggunakan default address');
    if (latlang != null && latlang!.isNotEmpty) {
      // Jangan set namaJalan ke koordinat, biarkan null atau kosong
      address = "Location: ${latlang}";
      namaJalan = null; // Jangan set ke koordinat agar tidak muncul sebagai alamat
    } else {
      address = "Location unavailable";
      namaJalan = null;
    }
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
      // Proses geotagging (ini yang memakan waktu)
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
      logger.i('Memulai proses geotagging gambar...');
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      if (image == null) return imageFile;

      logger.i('Gambar berhasil di-decode, ukuran: ${image.width}x${image.height}');

      // Konfigurasi default
      const double textScale = 5.5; // Scale untuk ukuran font teks
      const double layoutScale = 2.0; // Scale untuk spacing, padding, margin
      final textData = _prepareTextData();
      final overlayConfig = _calculateOverlayConfig(image, textScale, layoutScale);

      logger.i('Memproses overlay gambar...');
      // Buat combined image (proses ini yang lama)
      final combinedImage = await Future(() => _createCombinedImage(image, overlayConfig));

      logger.i('Menambahkan text overlay...');
      logger.i('Text data yang akan ditampilkan:');
      logger.i('  - Address: ${textData['address']}');
      logger.i('  - Geotag: ${textData['geotag']}');
      // Gambar teks overlay
      _drawTextOverlay(combinedImage, textData, overlayConfig, textScale, layoutScale);

      logger.i('Menyimpan gambar yang sudah diproses...');
      // Simpan file
      final savedFile = await _saveProcessedImage(combinedImage, imageFile);
      logger.i('Gambar berhasil diproses dan disimpan');
      return savedFile;
    } catch (e) {
      logger.e('Error adding geotag to image', error: e);
      return imageFile;
    }
  }

  /// Prepare text data untuk overlay
  Map<String, String> _prepareTextData() {
    final now = DateTime.now();
    
    // Helper untuk cek apakah string adalah koordinat (format: "lat,lng")
    bool isCoordinate(String? str) {
      if (str == null || str.isEmpty) return false;
      final parts = str.split(',');
      if (parts.length != 2) return false;
      final lat = double.tryParse(parts[0].trim());
      final lng = double.tryParse(parts[1].trim());
      // Cek apakah nilai masuk akal untuk koordinat (lat: -90 to 90, lng: -180 to 180)
      return lat != null && lng != null && 
             lat >= -90 && lat <= 90 && 
             lng >= -180 && lng <= 180;
    }
    
    // Pastikan alamat selalu ada nilai - JANGAN gunakan koordinat sebagai alamat
    String addressText = 'No address';
    
    logger.i('Mempersiapkan text data untuk overlay...');
    logger.i('address: $address');
    logger.i('namaJalan: $namaJalan');
    logger.i('latlang: $latlang');
    
    // Prioritas 1: Alamat lengkap (bukan koordinat, bukan "Location:")
    if (address != null && 
        address!.isNotEmpty && 
        address! != 'Location unavailable' && 
        !address!.startsWith('Location:') &&
        !isCoordinate(address)) {
      addressText = address!;
      logger.i('✅ Menggunakan alamat lengkap: $addressText');
    } 
    // Prioritas 2: Nama jalan (bukan koordinat, bukan "Location")
    else if (namaJalan != null && 
             namaJalan!.isNotEmpty && 
             namaJalan! != 'Location' && 
             namaJalan! != 'Location unavailable' &&
             !isCoordinate(namaJalan)) {
      addressText = namaJalan!;
      logger.i('✅ Menggunakan nama jalan: $addressText');
    } 
    // JANGAN gunakan koordinat sebagai alamat - biarkan "No address"
    else {
      logger.w('⚠️ Geocoding gagal, tidak ada alamat yang valid. Menggunakan "No address"');
      addressText = 'No address';
    }
    
    return {
      'dateTime': DateFormat('dd MMM yyyy HH.mm.ss').format(now),
      'geotag': latlang ?? 'No location',
      'address': addressText,
    };
  }

  /// Calculate overlay configuration
  Map<String, dynamic> _calculateOverlayConfig(
    img.Image image,
    double textScale,
    double layoutScale,
  ) {
    final overlayHeight = (image.height * 0.6).round().clamp(300, 700);
    final lineSpacing = (35 * layoutScale).round();
    final overlayStartY = image.height - overlayHeight;
    final textX = (10 * layoutScale).round();

    return {
      'overlayHeight': overlayHeight,
      'lineSpacing': lineSpacing,
      'overlayStartY': overlayStartY,
      'textX': textX,
    };
  }

  /// Create combined image tanpa overlay background gelap
  img.Image _createCombinedImage(
    img.Image image,
    Map<String, dynamic> config,
  ) {
    // Copy gambar asli tanpa overlay gelap
    final combinedImage = img.Image(
      width: image.width,
      height: image.height,
    );

    // Copy semua pixel dari gambar asli
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        combinedImage.setPixel(x, y, image.getPixel(x, y));
      }
    }

    return combinedImage;
  }

  /// Draw text overlay pada image dengan satu background box hitam di pojok kiri bawah
  void _drawTextOverlay(
    img.Image combinedImage,
    Map<String, String> textData,
    Map<String, dynamic> config,
    double textScale,
    double layoutScale,
  ) {
    final imageHeight = combinedImage.height;
    final imageWidth = combinedImage.width;
    final lineSpacing = config['lineSpacing'] as int;

    // Positioning di pojok kiri bawah dengan margin minimal
    final textX = (10 * layoutScale).round();
    final bottomMargin = (5 * layoutScale).round();
    final addressY = imageHeight - bottomMargin;
    final geotagY = addressY - lineSpacing;

    // Hitung ukuran box untuk semua teks
    final font = img.arial48;
    final textHeight = (48 * textScale).round();
    final padding = (12 * layoutScale).round();

    // Hitung lebar teks untuk setiap baris
    final geotagWidth = _calculateTextWidth(textData['geotag']!, font, textScale);
    final addressWidth = _calculateTextWidth(textData['address']!, font, textScale);

    // Ambil lebar terpanjang
    final maxTextWidth = geotagWidth > addressWidth ? geotagWidth : addressWidth;

    // Ukuran box disesuaikan dengan teks + padding
    final boxWidth = maxTextWidth + (padding * 2);
    final boxHeight = lineSpacing + textHeight + padding;
    final boxX = textX - padding;
    final boxY = geotagY - textHeight - (padding ~/ 2);

    // Draw background box hitam transparan (50% opacity)
    for (int by = boxY; by < boxY + boxHeight && by < imageHeight; by++) {
      if (by < 0) continue;
      for (int bx = boxX; bx < boxX + boxWidth && bx < imageWidth; bx++) {
        if (bx < 0) continue;
        final originalPixel = combinedImage.getPixel(bx, by);
        combinedImage.setPixel(
          bx,
          by,
          img.ColorRgb8(
            ((originalPixel.r * 0.5) + (0 * 0.5)).round(),
            ((originalPixel.g * 0.5) + (0 * 0.5)).round(),
            ((originalPixel.b * 0.5) + (0 * 0.5)).round(),
          ),
        );
      }
    }

    // Draw teks (address di baris pertama, geotag di baris kedua)
    final textOffsetY = (30 * layoutScale).round();
    _drawText(
      combinedImage,
      textData['address']!,
      textX,
      geotagY - textOffsetY,
    );
    _drawText(
      combinedImage,
      textData['geotag']!,
      textX,
      addressY - textOffsetY,
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

  /// Calculate text width berdasarkan font dan scale
  int _calculateTextWidth(String text, img.BitmapFont font, double textScale) {
    // Arial48 memiliki karakter width sekitar 26 pixel per karakter
    final avgCharWidth = 26.0;
    return (text.length * avgCharWidth * textScale).round();
  }

  /// Draw text tanpa outline
  void _drawText(
    img.Image image,
    String text,
    int x,
    int y,
  ) {
    final font = img.arial48;
    img.drawString(
      image,
      text,
      font: font,
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
    try {
      final bytes = await imageFile.readAsBytes();
      
      // Decode image untuk kompresi
      final originalImage = img.decodeImage(bytes);
      if (originalImage == null) {
        // Jika decode gagal, gunakan original
        final base64String = base64Encode(bytes);
        final ext = imageFile.path.split('.').last.toLowerCase();
        final mimeType = _getMimeType(ext);
        return 'data:$mimeType;base64,$base64String';
      }

      // Resize jika terlalu besar (max 1920x1920)
      img.Image processedImage = originalImage;
      if (originalImage.width > 1920 || originalImage.height > 1920) {
        processedImage = img.copyResize(
          originalImage,
          width: originalImage.width > originalImage.height ? 1920 : null,
          height: originalImage.height > originalImage.width ? 1920 : null,
          interpolation: img.Interpolation.linear,
        );
      }

      // Encode dengan kualitas 85% untuk mengurangi ukuran
      final ext = imageFile.path.split('.').last.toLowerCase();
      final mimeType = _getMimeType(ext);
      List<int> encodedBytes;

      if (mimeType == 'image/png') {
        encodedBytes = img.encodePng(processedImage);
      } else {
        encodedBytes = img.encodeJpg(processedImage, quality: 85);
      }

      final base64String = base64Encode(encodedBytes);
      return 'data:$mimeType;base64,$base64String';
    } catch (e) {
      logger.e('Error converting image to base64', error: e);
      // Fallback ke original jika error
      final bytes = await imageFile.readAsBytes();
      final base64String = base64Encode(bytes);
      final ext = imageFile.path.split('.').last.toLowerCase();
      final mimeType = _getMimeType(ext);
      return 'data:$mimeType;base64,$base64String';
    }
  }

  /// Convert image URL ke base64
  Future<String> convertImageUrlToBase64(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        
        // Decode image untuk kompresi
        final originalImage = img.decodeImage(bytes);
        if (originalImage == null) {
          // Jika decode gagal, gunakan original
          final base64Image = base64Encode(bytes);
          return "data:image/jpeg;base64,$base64Image";
        }

        // Resize jika terlalu besar (max 1920x1920)
        img.Image processedImage = originalImage;
        if (originalImage.width > 1920 || originalImage.height > 1920) {
          processedImage = img.copyResize(
            originalImage,
            width: originalImage.width > originalImage.height ? 1920 : null,
            height: originalImage.height > originalImage.width ? 1920 : null,
            interpolation: img.Interpolation.linear,
          );
        }

        // Encode dengan kualitas 85% untuk mengurangi ukuran
        final encodedBytes = img.encodeJpg(processedImage, quality: 85);
        final base64Image = base64Encode(encodedBytes);
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
      // Task baru: harus ada gambar baru
      if (imageFiles.isEmpty || imageFilesVerify.isEmpty) {
        return false;
      }
    } else {
      // Task existing: harus ada minimal gambar (baru atau bawaan)
      // Cek gambar sample biasa: imageFiles, imageString, atau imageOldString
      final hasSampleImage = imageFiles.isNotEmpty ||
          imageString.isNotEmpty ||
          imageOldString.isNotEmpty;
      
      // Cek gambar verifikasi: imageFilesVerify, imageStringVerifiy, atau imageOldStringVerifiy
      final hasVerifyImage = imageFilesVerify.isNotEmpty ||
          imageStringVerifiy.isNotEmpty ||
          imageOldStringVerifiy.isNotEmpty;
      
      if (!hasSampleImage || !hasVerifyImage) {
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
        // Task existing: harus ada minimal gambar (baru atau bawaan)
        final hasSampleImage = imageFiles.isNotEmpty ||
            imageString.isNotEmpty ||
            imageOldString.isNotEmpty;
        
        final hasVerifyImage = imageFilesVerify.isNotEmpty ||
            imageStringVerifiy.isNotEmpty ||
            imageOldStringVerifiy.isNotEmpty;
        
        if (!hasSampleImage || !hasVerifyImage) {
          return AppLocalizations.of(context!)?.imageCannotBeEmpty ??
              "Gambar tidak boleh kosong";
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
    final List<Future<String>> futures = [];

    // Convert file images secara parallel
    for (var file in imageFiles) {
      futures.add(convertImageToBase64(file));
    }

    // Convert URL images secara parallel
    if (imageString.isNotEmpty) {
      for (var url in imageString) {
        futures.add(convertImageUrlToBase64(url).then((str) => str.isEmpty ? '' : str));
      }
    }

    // Wait semua proses selesai secara parallel
    final results = await Future.wait(futures);
    
    // Filter out empty strings
    return results.where((str) => str.isNotEmpty).toList();
  }

  /// Prepare image base64 list untuk verifikasi
  Future<List<String>> _prepareImageBase64ListVerify() async {
    final List<Future<String>> futures = [];

    // Convert file images secara parallel
    for (var file in imageFilesVerify) {
      futures.add(convertImageToBase64(file));
    }

    // Convert URL images secara parallel
    if (imageStringVerifiy.isNotEmpty) {
      for (var url in imageStringVerifiy) {
        futures.add(convertImageUrlToBase64(url).then((str) => str.isEmpty ? '' : str));
      }
    }

    // Wait semua proses selesai secara parallel
    final results = await Future.wait(futures);
    
    // Filter out empty strings
    return results.where((str) => str.isNotEmpty).toList();
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
