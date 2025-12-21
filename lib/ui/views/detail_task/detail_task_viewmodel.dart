import 'dart:convert';
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  String? subLocality; // Kampung/Kelurahan
  String? locality; // Kecamatan
  String? subAdministrativeArea; // Kabupaten
  String? administrativeArea; // Provinsi
  String? country; // Negara
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
  List<TakingSampleParameter> listTakingSampleParameter = [];
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

  // Platform channel untuk cek mock location (Android)
  static const MethodChannel _channel =
      MethodChannel('com.salims_apps/mock_location');

  /// Validasi apakah lokasi GPS adalah fake/mock location
  /// Returns true jika terdeteksi fake GPS, false jika lokasi asli
  Future<bool> _isFakeGPS(Position position) async {
    try {
      logger.d("_isFakeGPS: Checking for fake GPS...");

      // 1. Cek mock location untuk Android menggunakan platform channel
      if (Platform.isAndroid) {
        try {
          final bool? isMockLocation =
              await _channel.invokeMethod<bool>('isMockLocation');
          if (isMockLocation == true) {
            logger.w("_isFakeGPS: Mock location detected via platform channel");
            return true;
          }
        } catch (e) {
          logger.w(
              "_isFakeGPS: Could not check mock location via platform channel: $e");
          // Jika platform channel tidak tersedia, lanjutkan dengan metode lain
        }
      }

      // 2. Cek accuracy yang tidak realistis (terlalu tinggi/rendah)
      // Accuracy 0 atau sangat kecil (< 1 meter) bisa jadi indikator fake GPS
      if (position.accuracy <= 0 ||
          (position.accuracy > 0 && position.accuracy < 1)) {
        logger.w(
            "_isFakeGPS: Suspicious accuracy detected: ${position.accuracy}");
        // Accuracy terlalu sempurna bisa jadi fake, tapi tidak selalu
      }

      // 3. Cek apakah lokasi di koordinat yang tidak mungkin (0,0 atau null island)
      if ((position.latitude == 0.0 && position.longitude == 0.0) ||
          (position.latitude.abs() > 90) ||
          (position.longitude.abs() > 180)) {
        logger.w(
            "_isFakeGPS: Invalid coordinates detected: ${position.latitude}, ${position.longitude}");
        return true;
      }

      // 4. Cek speed yang tidak realistis (jika tersedia)
      if (position.speed > 0 && position.speed > 1000) {
        // Speed lebih dari 1000 m/s (3600 km/h) tidak realistis
        logger
            .w("_isFakeGPS: Unrealistic speed detected: ${position.speed} m/s");
        return true;
      }

      // 5. Cek timestamp yang tidak wajar
      final now = DateTime.now();
      final positionTime = position.timestamp;
      final timeDiff = now.difference(positionTime).abs();
      if (timeDiff.inDays > 1) {
        // Timestamp lebih dari 1 hari berbeda dengan waktu sekarang
        logger.w(
            "_isFakeGPS: Suspicious timestamp detected: $positionTime, current: $now");
      }

      logger.d("_isFakeGPS: No fake GPS detected, location seems valid");
      return false;
    } catch (e, stackTrace) {
      logger.e("_isFakeGPS: Error checking fake GPS",
          error: e, stackTrace: stackTrace);
      // Jika error, anggap lokasi valid (jangan block user)
      return false;
    }
  }

  /// Tampilkan dialog warning jika terdeteksi fake GPS
  Future<void> _showFakeGPSWarning() async {
    if (context == null) return;

    return showDialog<void>(
      context: context!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Fake GPS Terdeteksi',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Fake GPS atau mock location terdeteksi. Silakan nonaktifkan aplikasi fake GPS dan gunakan lokasi asli untuk melanjutkan.',
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> pickImage() async {
    if (context == null) {
      logger.w("pickImage: context is null");
      return;
    }

    logger.d("pickImage: Starting image picker");

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

    if (source == null) {
      logger.d("pickImage: User cancelled image source selection");
      return;
    }

    logger.d(
        "pickImage: Selected source: ${source == ImageSource.camera ? 'Camera' : 'Gallery'}");
    logger.d("pickImage: Current latlang value: $latlang");

    // Jika memilih camera dan latlang belum ada, ambil lokasi saat ini terlebih dahulu
    if (source == ImageSource.camera && (latlang == null || latlang!.isEmpty)) {
      logger.d(
          "pickImage: Camera selected but latlang is empty, fetching location...");
      try {
        LocationPermission permission = await Geolocator.checkPermission();
        logger.d("pickImage: Current permission status: $permission");

        if (permission == LocationPermission.denied) {
          logger.d("pickImage: Permission denied, requesting permission...");
          permission = await Geolocator.requestPermission();
          logger.d("pickImage: Permission request result: $permission");
        }

        if (permission != LocationPermission.denied &&
            permission != LocationPermission.deniedForever) {
          logger
              .d("pickImage: Permission granted, getting current position...");
          Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );

          logger.d(
              "pickImage: Position obtained - Lat: ${position.latitude}, Lng: ${position.longitude}");

          // Validasi fake GPS
          bool isFakeGPS = await _isFakeGPS(position);
          if (isFakeGPS) {
            logger.w("pickImage: Fake GPS detected, showing warning");
            await _showFakeGPSWarning();
            // Tetap set lokasi, tapi user sudah diingatkan
          }

          currentLocation = LatLng(position.latitude, position.longitude);
          latlang =
              '${currentLocation!.latitude},${currentLocation!.longitude}';
          latitude = '${currentLocation!.latitude}';
          longitude = '${currentLocation!.longitude}';

          logger.d(
              "pickImage: Location set - latlang: $latlang, latitude: $latitude, longitude: $longitude");

          // Ambil alamat dari koordinat (reverse geocoding)
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
              subLocality = safe(placemark.subLocality);
              locality = safe(placemark.locality);
              subAdministrativeArea = safe(placemark.subAdministrativeArea);
              administrativeArea = safe(placemark.administrativeArea);
              country = safe(placemark.country);
              logger.d("pickImage: Address obtained - namaJalan: $namaJalan");
            } else {
              // Jika tidak ada placemark, set default address
              address = "Location: ${latlang}";
              namaJalan = "Location";
              subLocality = "";
              locality = "";
              subAdministrativeArea = "";
              administrativeArea = "";
              country = "";
              logger.d("pickImage: No placemark found, using default address");
            }
          } catch (e) {
            // Handle geocoding error
            address = "Location: ${latlang}";
            namaJalan = "Location";
            logger.w("pickImage: Failed to get address: $e");
          }

          // Update location controller jika belum di-set
          if (locationController != null &&
              (locationController!.text.isEmpty ||
                  locationController!.text == listTaskList?.geotag)) {
            locationController!.text = latlang!;
            logger.d("pickImage: Location controller updated");
          }
        } else {
          logger.w("pickImage: Location permission denied or denied forever");
        }
      } catch (e, stackTrace) {
        // Jika gagal mengambil lokasi, tetap lanjutkan tanpa geotag
        logger.e("pickImage: Failed to get location for geotag",
            error: e, stackTrace: stackTrace);
      }
    } else if (source == ImageSource.camera) {
      logger
          .d("pickImage: Camera selected and latlang already exists: $latlang");
    }

    logger.d("pickImage: Opening image picker...");
    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      logger.d("pickImage: Image picked from path: ${pickedFile.path}");
      File processedFile;

      // Jika gambar diambil dari camera, tambahkan teks geotag
      if (source == ImageSource.camera &&
          latlang != null &&
          latlang!.isNotEmpty) {
        logger.d("pickImage: Processing camera image with geotag: $latlang");
        processedFile = await _addGeotagToImage(File(pickedFile.path));
        logger.d(
            "pickImage: Geotag added, processed file path: ${processedFile.path}");
      } else {
        // Jika dari gallery, gunakan file asli
        logger.d("pickImage: Using original file (gallery or no geotag)");
        processedFile = File(pickedFile.path);
      }

      // Pastikan file baru tidak sudah ada di list
      bool alreadyExists = imageFiles.any((f) => f.path == processedFile.path);
      logger.d("pickImage: File already exists in list: $alreadyExists");

      if (!alreadyExists) {
        imageFiles.add(processedFile);
        logger.d(
            "pickImage: File added to list. Total files: ${imageFiles.length}");
        notifyListeners();
      } else {
        logger.w("pickImage: File already exists, not adding to list");
      }
    } else {
      logger.d("pickImage: No image was picked");
    }
  }

  Future<File> _addGeotagToImage(File imageFile) async {
    logger.d(
        "_addGeotagToImage: Starting geotag process for file: ${imageFile.path}");
    logger.d("_addGeotagToImage: latlang value: $latlang");

    try {
      // Baca file gambar
      logger.d("_addGeotagToImage: Reading image file...");
      final Uint8List imageBytes = await imageFile.readAsBytes();
      logger.d(
          "_addGeotagToImage: Image bytes read, size: ${imageBytes.length} bytes");

      img.Image? image = img.decodeImage(imageBytes);
      logger.d(
          "_addGeotagToImage: Image decoded, result: ${image != null ? 'Success' : 'Failed'}");

      if (image == null) {
        logger.e(
            "_addGeotagToImage: Failed to decode image, returning original file");
        return imageFile; // Return original file if decode fails
      }

      logger.d(
          "_addGeotagToImage: Image dimensions - Width: ${image.width}, Height: ${image.height}");

      // Buat teks dengan format seperti contoh: tanggal, geotag, alamat lengkap
      final now = DateTime.now();
      final dateTimeText = DateFormat('dd MMM yyyy HH.mm.ss').format(now);
      final geotagText = latlang ?? 'No location';
      final streetText = namaJalan ?? 'No street';
      final subLocalityText = subLocality ?? '';
      final localityText = locality ?? '';
      final subAdminText = subAdministrativeArea ?? '';
      final adminText = administrativeArea ?? '';

      // Buat list teks yang akan ditampilkan
      List<String> textLines = [];
      textLines.add(dateTimeText);
      // Tambahkan geotag (koordinat GPS)
      if (geotagText.isNotEmpty && geotagText != 'No location') {
        textLines.add(geotagText);
      }
      if (streetText.isNotEmpty && streetText != 'No street') {
        textLines.add(streetText);
      }
      if (subLocalityText.isNotEmpty) {
        textLines.add(subLocalityText);
      }
      if (localityText.isNotEmpty) {
        textLines.add(localityText);
      }
      if (subAdminText.isNotEmpty) {
        textLines.add(subAdminText);
      }
      if (adminText.isNotEmpty) {
        textLines.add(adminText);
      }

      logger.d("_addGeotagToImage: Text lines: $textLines");

      // Ukuran dan spacing untuk overlay teks di atas gambar - diperbesar
      final lineCount = textLines.length;
      final lineSpacing = 80; // Spasi antar baris - diperbesar
      final textPadding = 40; // Padding dari tepi - diperbesar
      final overlayHeight = (lineCount * lineSpacing) + (textPadding * 2);

      logger.d(
          "_addGeotagToImage: Overlay height: $overlayHeight, line count: $lineCount");

      // Gunakan gambar asli langsung (tidak perlu menambah tinggi)
      logger.d("_addGeotagToImage: Using original image as base...");
      final combinedImage = img.Image(
        width: image.width,
        height: image.height,
      );

      // Copy gambar asli
      for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
          final pixel = image.getPixel(x, y);
          combinedImage.setPixel(x, y, pixel);
        }
      }
      logger.d("_addGeotagToImage: Original image copied");

      // Buat overlay background semi-transparan di pojok bawah
      // Hitung posisi overlay (di bagian bawah gambar)
      final overlayStartY = image.height - overlayHeight;
      logger.d(
          "_addGeotagToImage: Creating overlay background at Y: $overlayStartY");

      for (int y = overlayStartY; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
          // Blend background hitam semi-transparan dengan gambar asli
          final originalPixel = combinedImage.getPixel(x, y);
          final bgAlpha = 180; // Alpha untuk background overlay
          final blendAlpha = (bgAlpha / 255.0);

          // Blend hitam dengan gambar asli
          final r = (originalPixel.r * (1 - blendAlpha)).round();
          final g = (originalPixel.g * (1 - blendAlpha)).round();
          final b = (originalPixel.b * (1 - blendAlpha)).round();

          combinedImage.setPixel(x, y, img.ColorRgb8(r, g, b));
        }
      }
      logger.d("_addGeotagToImage: Overlay background created");

      // Posisi teks di pojok bawah kiri dengan padding
      final textX = textPadding;
      final startY = overlayStartY +
          textPadding +
          50; // Mulai dari dalam overlay - offset lebih besar untuk font besar
      logger.d(
          "_addGeotagToImage: Text start position - X: $textX, Y: $startY (image height: ${image.height})");

      // Draw text menggunakan teknik outline untuk efek bold tanpa blur
      // Gambar outline hitam tebal sekali, lalu teks putih di atasnya
      logger.d("_addGeotagToImage: Drawing text with outline technique...");
      try {
        // Outline offsets untuk efek bold yang jelas (tanpa blur)
        // Gunakan offset yang lebih besar untuk teks yang lebih besar
        final outlineOffsets = [
          [-5, -5],
          [-5, 0],
          [-5, 5],
          [0, -5],
          [0, 5],
          [5, -5],
          [5, 0],
          [5, 5],
          [-4, -4],
          [-4, 0],
          [-4, 4],
          [0, -4],
          [0, 4],
          [4, -4],
          [4, 0],
          [4, 4],
          [-3, -3],
          [-3, 3],
          [3, -3],
          [3, 3]
        ];

        // Gambar setiap baris teks dengan outline
        int currentY = startY;
        for (int i = 0; i < textLines.length; i++) {
          final lineText = textLines[i];

          // Gambar outline hitam untuk setiap baris
          for (var offset in outlineOffsets) {
            img.drawString(
              combinedImage,
              lineText,
              font: img.arial48,
              x: textX + offset[0],
              y: currentY + offset[1],
              color: img.ColorRgb8(0, 0, 0), // Outline hitam
            );
          }

          // Gambar teks utama (putih) di atas outline
          img.drawString(
            combinedImage,
            lineText,
            font: img.arial48,
            x: textX,
            y: currentY,
            color: img.ColorRgb8(255, 255, 255), // Warna putih
          );

          // Pindah ke baris berikutnya
          currentY += lineSpacing;
        }

        logger.d(
            "_addGeotagToImage: All text lines drawn successfully with outline technique (no blur)");
      } catch (fontError48) {
        logger.w(
            "_addGeotagToImage: Failed to use arial48 font, trying arial24",
            error: fontError48);
        try {
          // Coba dengan arial24, juga dengan efek bold lebih besar
          // Gunakan teknik outline yang sama untuk arial24
          final outlineOffsets24 = [
            [-4, -4],
            [-4, 0],
            [-4, 4],
            [0, -4],
            [0, 4],
            [4, -4],
            [4, 0],
            [4, 4],
            [-3, -3],
            [-3, 3],
            [3, -3],
            [3, 3]
          ];

          // Gambar setiap baris teks dengan outline (format sama seperti arial48)
          int currentY24 = startY;
          for (int i = 0; i < textLines.length; i++) {
            final lineText = textLines[i];

            // Gambar outline hitam untuk setiap baris
            for (var offset in outlineOffsets24) {
              img.drawString(
                combinedImage,
                lineText,
                font: img.arial24,
                x: textX + offset[0],
                y: currentY24 + offset[1],
                color: img.ColorRgb8(0, 0, 0), // Outline hitam
              );
            }

            // Gambar teks utama (putih) di atas outline
            img.drawString(
              combinedImage,
              lineText,
              font: img.arial24,
              x: textX,
              y: currentY24,
              color: img.ColorRgb8(255, 255, 255), // Warna putih
            );

            // Pindah ke baris berikutnya
            currentY24 += lineSpacing;
          }

          logger.d(
              "_addGeotagToImage: All text lines drawn successfully with arial24 font (outline technique)");
        } catch (fontError24) {
          logger.w(
              "_addGeotagToImage: Failed to use arial24 font, trying arial14",
              error: fontError24);
          // Jika font tidak tersedia, coba dengan font lain atau buat teks manual
          try {
            // Coba dengan arial14 sebagai alternatif
            // Gambar setiap baris teks
            int currentY14 = startY;
            for (int i = 0; i < textLines.length; i++) {
              final lineText = textLines[i];
              img.drawString(
                combinedImage,
                lineText,
                font: img.arial14,
                x: textX,
                y: currentY14,
                color: img.ColorRgb8(255, 255, 255),
              );
              currentY14 += lineSpacing;
            }
            logger.d(
                "_addGeotagToImage: All text lines drawn successfully with arial14 font");
          } catch (e2) {
            logger.w(
                "_addGeotagToImage: All font methods failed, drawing simple text",
                error: e2);
            // Fallback: gambar teks secara manual dengan pixel
            int currentYManual = startY;
            for (int i = 0; i < textLines.length; i++) {
              final lineText = textLines[i];
              _drawTextManually(combinedImage, lineText, textX, currentYManual);
              currentYManual += lineSpacing;
            }
            logger.d("_addGeotagToImage: All text lines drawn manually");
          }
        }
      }

      // Simpan ke file baru
      final directory = imageFile.parent;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newFileName = 'image_${timestamp}_geotag.jpg';
      final newFile = File('${directory.path}/$newFileName');
      logger.d("_addGeotagToImage: New file path: ${newFile.path}");

      // Encode dan simpan
      logger.d("_addGeotagToImage: Encoding image to JPEG...");
      final encodedImage = img.encodeJpg(combinedImage, quality: 90);
      logger.d(
          "_addGeotagToImage: Image encoded, size: ${encodedImage.length} bytes");

      logger.d("_addGeotagToImage: Writing file to disk...");
      await newFile.writeAsBytes(encodedImage);
      logger.d("_addGeotagToImage: File saved successfully: ${newFile.path}");
      logger.d("_addGeotagToImage: File exists: ${await newFile.exists()}");

      return newFile;
    } catch (e, stackTrace) {
      // Jika terjadi error, return file asli
      logger.e("_addGeotagToImage: Error occurred while processing image",
          error: e, stackTrace: stackTrace);
      return imageFile;
    }
  }

  // Method untuk menggambar teks secara manual jika font tidak tersedia
  void _drawTextManually(img.Image image, String text, int x, int y) {
    logger.d("_drawTextManually: Drawing text manually: $text at ($x, $y)");
    try {
      // Coba dengan arial24 sebagai fallback (lebih besar dari sebelumnya)
      img.drawString(
        image,
        text,
        font: img.arial24,
        x: x,
        y: y,
        color: img.ColorRgb8(255, 255, 255),
      );
      logger.d("_drawTextManually: Text drawn successfully with arial24");
    } catch (e) {
      logger.e("_drawTextManually: Failed to draw text manually", error: e);
      // Jika masih gagal, coba dengan arial14
      try {
        img.drawString(
          image,
          text,
          font: img.arial14,
          x: x,
          y: y,
          color: img.ColorRgb8(255, 255, 255),
        );
        logger.d("_drawTextManually: Text drawn successfully with arial14");
      } catch (e2) {
        logger.w("_drawTextManually: Using pixel fallback method", error: e2);
        // Jika masih gagal, set beberapa pixel sebagai indikator (fallback terakhir)
        // Ini hanya untuk debugging, seharusnya tidak terjadi
        for (int i = 0; i < text.length * 8 && x + i < image.width; i++) {
          if (y < image.height) {
            image.setPixel(x + i, y, img.ColorRgb8(255, 255, 255));
          }
        }
      }
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
            (item) => item.parcode.toString().trim().toUpperCase(),
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

      // Validasi fake GPS
      bool isFakeGPS = await _isFakeGPS(userPosition!);
      if (isFakeGPS) {
        logger.w("setLocationName: Fake GPS detected, showing warning");
        await _showFakeGPSWarning();
        // Tetap set lokasi, tapi user sudah diingatkan
      }

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
          subLocality = safe(placemark.subLocality);
          locality = safe(placemark.locality);
          subAdministrativeArea = safe(placemark.subAdministrativeArea);
          administrativeArea = safe(placemark.administrativeArea);
          country = safe(placemark.country);

          addressController?.text = namaJalan!;
          isChangeLocation = true;
        } else {
          // Jika tidak ada placemark, set default address
          address = "Location: ${latlang}";
          namaJalan = "Location";
          subLocality = "";
          locality = "";
          subAdministrativeArea = "";
          administrativeArea = "";
          country = "";
          addressController?.text = namaJalan!;
          isChangeLocation = true;
        }
      } catch (e) {
        // Handle geocoding error (permission denied, network error, etc.)
        // Set default address dengan koordinat
        address = "Location: ${latlang}";
        namaJalan = "Location";
        subLocality = "";
        locality = "";
        subAdministrativeArea = "";
        administrativeArea = "";
        country = "";
        addressController?.text = namaJalan!;
        isChangeLocation = true;
      }
    } catch (e) {
      // Set default values jika gagal mendapatkan lokasi
      address = "Location unavailable";
      namaJalan = "Location";
      subLocality = "";
      locality = "";
      subAdministrativeArea = "";
      administrativeArea = "";
      country = "";
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
      List<String> imageBase64List = [];
      for (var file in imageFiles) {
        String base64Str = await convertImageToBase64(file);
        imageBase64List.add(base64Str);
      }

      // 🔹 Gabungkan dengan URL lama jika ada
      if (imageString.isNotEmpty) {
        for (var file in imageString) {
          String base64Str = await convertImageUrlToBase64(file);
          imageBase64List.add(base64Str);
        }
      }

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
          takingSampleParameters: listTakingSampleParameter,
          takingSampleCI: listTakingSampleCI,
          photoOld: imageOldString,
          uploadFotoSample: imageBase64List);

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

      // Validasi fake GPS
      bool isFakeGPS = await _isFakeGPS(userPositions);
      if (isFakeGPS) {
        logger.w("cekRangeLocation: Fake GPS detected");
        await _showFakeGPSWarning();
        // Tetap lanjutkan validasi, tapi user sudah diingatkan
      }

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
      if (response['documents'] != null && response['documents'] is List) {
        for (var url in response['documents']) {
          if (url != null && url['pathname'] != null) {
            imageString.add(url['pathname'].toString());
            imageOldString.add(url['pathname'].toString());
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
      logger.e("getOneTaskList: Error occurred",
          error: e, stackTrace: stackTrace);
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
            (item) => item.parcode.toString().trim().toUpperCase(),
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
      logger.e("futureToRun: Error occurred", error: e, stackTrace: stackTrace);
      setBusy(false);
      notifyListeners();
    }
    // await setLocationName();
  }
}
