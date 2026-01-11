import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

/// Service untuk menangani semua operasi image processing
/// Termasuk: pick image, geotagging, conversion, dll
class ImageProcessingService {
  final Logger logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  /// Tampilkan dialog untuk memilih sumber gambar
  Future<ImageSource?> showImageSourceDialog(BuildContext context) async {
    return await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Tampilkan dialog untuk memilih sumber gambar verifikasi (hanya camera)
  Future<ImageSource?> showImageSourceDialogVerify(BuildContext context) async {
    return await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Process image file (tambah geotag jika dari camera)
  Future<File> processImageFile(
    File imageFile,
    ImageSource source,
    String? latlang, {
    String? address,
    String? namaJalan,
  }) async {
    if (source == ImageSource.camera && latlang != null && latlang.isNotEmpty) {
      return await addGeotagToImage(
        imageFile,
        latlang,
        address: address,
        namaJalan: namaJalan,
      );
    }
    return imageFile;
  }

  /// Tambahkan geotag overlay ke gambar
  Future<File> addGeotagToImage(
    File imageFile,
    String latlang, {
    String? address,
    String? namaJalan,
  }) async {
    try {
      logger.i('Memulai proses geotagging gambar...');
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      if (image == null) return imageFile;

      logger.i(
          'Gambar berhasil di-decode, ukuran: ${image.width}x${image.height}');

      // Konfigurasi default
      const double textScale = 5.5;
      const double layoutScale = 2.0;
      final textData = _prepareTextData(latlang, address: address, namaJalan: namaJalan);
      final overlayConfig =
          _calculateOverlayConfig(image, textScale, layoutScale);

      logger.i('Memproses overlay gambar...');
      final combinedImage =
          await Future(() => _createCombinedImage(image, overlayConfig));

      logger.i('Menambahkan text overlay...');
      logger.i('Text data yang akan ditampilkan:');
      logger.i('  - Address: ${textData['address']}');
      logger.i('  - Geotag: ${textData['geotag']}');
      _drawTextOverlay(
          combinedImage, textData, overlayConfig, textScale, layoutScale);

      logger.i('Menyimpan gambar yang sudah diproses...');
      final savedFile = await _saveProcessedImage(combinedImage, imageFile);
      logger.i('Gambar berhasil diproses dan disimpan');
      return savedFile;
    } catch (e) {
      logger.e('Error adding geotag to image', error: e);
      return imageFile;
    }
  }

  /// Prepare text data untuk overlay
  Map<String, String> _prepareTextData(
    String latlang, {
    String? address,
    String? namaJalan,
  }) {
    final now = DateTime.now();

    bool isCoordinate(String? str) {
      if (str == null || str.isEmpty) return false;
      final parts = str.split(',');
      if (parts.length != 2) return false;
      final lat = double.tryParse(parts[0].trim());
      final lng = double.tryParse(parts[1].trim());
      return lat != null &&
          lng != null &&
          lat >= -90 &&
          lat <= 90 &&
          lng >= -180 &&
          lng <= 180;
    }

    String addressText = 'No address';

    logger.i('Mempersiapkan text data untuk overlay...');
    logger.i('address: $address');
    logger.i('namaJalan: $namaJalan');
    logger.i('latlang: $latlang');

    if (address != null &&
        address.isNotEmpty &&
        address != 'Location unavailable' &&
        !address.startsWith('Location:') &&
        !isCoordinate(address)) {
      addressText = address;
      logger.i('✅ Menggunakan alamat lengkap: $addressText');
    } else if (namaJalan != null &&
        namaJalan.isNotEmpty &&
        namaJalan != 'Location' &&
        namaJalan != 'Location unavailable' &&
        !isCoordinate(namaJalan)) {
      addressText = namaJalan;
      logger.i('✅ Menggunakan nama jalan: $addressText');
    } else {
      logger.w(
          '⚠️ Geocoding gagal, tidak ada alamat yang valid. Menggunakan "No address"');
      addressText = 'No address';
    }

    return {
      'dateTime': DateFormat('dd MMM yyyy HH.mm.ss').format(now),
      'geotag': latlang,
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
    final combinedImage = img.Image(
      width: image.width,
      height: image.height,
    );

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

    final textX = (10 * layoutScale).round();
    final bottomMargin = (5 * layoutScale).round();
    final addressY = imageHeight - bottomMargin;
    final geotagY = addressY - lineSpacing;

    final font = img.arial48;
    final textHeight = (48 * textScale).round();
    final padding = (12 * layoutScale).round();

    final geotagWidth =
        _calculateTextWidth(textData['geotag']!, font, textScale);
    final addressWidth =
        _calculateTextWidth(textData['address']!, font, textScale);

    final maxTextWidth =
        geotagWidth > addressWidth ? geotagWidth : addressWidth;

    final boxWidth = maxTextWidth + (padding * 2);
    final boxHeight = lineSpacing + textHeight + padding;
    final boxX = textX - padding;
    final boxY = geotagY - textHeight - (padding ~/ 2);

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

  /// Calculate text width berdasarkan font dan scale
  int _calculateTextWidth(String text, img.BitmapFont font, double textScale) {
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

  /// Convert image file ke base64
  Future<String> convertImageToBase64(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();

      final originalImage = img.decodeImage(bytes);
      if (originalImage == null) {
        final base64String = base64Encode(bytes);
        final ext = imageFile.path.split('.').last.toLowerCase();
        final mimeType = _getMimeType(ext);
        return 'data:$mimeType;base64,$base64String';
      }

      img.Image processedImage = originalImage;
      if (originalImage.width > 1920 || originalImage.height > 1920) {
        processedImage = img.copyResize(
          originalImage,
          width: originalImage.width > originalImage.height ? 1920 : null,
          height: originalImage.height > originalImage.width ? 1920 : null,
          interpolation: img.Interpolation.linear,
        );
      }

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

        final originalImage = img.decodeImage(bytes);
        if (originalImage == null) {
          final base64Image = base64Encode(bytes);
          return "data:image/jpeg;base64,$base64Image";
        }

        img.Image processedImage = originalImage;
        if (originalImage.width > 1920 || originalImage.height > 1920) {
          processedImage = img.copyResize(
            originalImage,
            width: originalImage.width > originalImage.height ? 1920 : null,
            height: originalImage.height > originalImage.width ? 1920 : null,
            interpolation: img.Interpolation.linear,
          );
        }

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

  /// Prepare image base64 list untuk sample biasa
  Future<List<String>> prepareImageBase64List(
    List<File> imageFiles,
    List<String> imageString,
  ) async {
    final List<Future<String>> futures = [];

    for (var file in imageFiles) {
      futures.add(convertImageToBase64(file));
    }

    if (imageString.isNotEmpty) {
      for (var url in imageString) {
        futures.add(
            convertImageUrlToBase64(url).then((str) => str.isEmpty ? '' : str));
      }
    }

    final results = await Future.wait(futures);
    return results.where((str) => str.isNotEmpty).toList();
  }

  /// Prepare image base64 list untuk verifikasi
  Future<List<String>> prepareImageBase64ListVerify(
    List<File> imageFilesVerify,
    List<String> imageStringVerifiy,
  ) async {
    final List<Future<String>> futures = [];

    for (var file in imageFilesVerify) {
      futures.add(convertImageToBase64(file));
    }

    if (imageStringVerifiy.isNotEmpty) {
      for (var url in imageStringVerifiy) {
        futures.add(
            convertImageUrlToBase64(url).then((str) => str.isEmpty ? '' : str));
      }
    }

    final results = await Future.wait(futures);
    return results.where((str) => str.isNotEmpty).toList();
  }
}

