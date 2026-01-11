import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

/// Service untuk menangani semua operasi location
class LocationService {
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

  /// Check dan request location permission
  Future<LocationPermission> checkAndRequestLocationPermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission;
  }

  /// Fetch current location dari GPS
  Future<Position> fetchCurrentLocation() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Fetch address dari koordinat (reverse geocoding) dengan retry
  Future<Map<String, String?>> fetchAddressFromLocation(
    LatLng currentLocation,
  ) async {
    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        logger.i(
            'Memulai reverse geocoding (attempt ${retryCount + 1}/$maxRetries)...');
        logger.i(
            'Koordinat: ${currentLocation.latitude}, ${currentLocation.longitude}');

        final placemarks = await placemarkFromCoordinates(
          currentLocation.latitude,
          currentLocation.longitude,
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

          final street = safe(placemark.street);
          final name = safe(placemark.name);
          final subLocality = safe(placemark.subLocality);
          final locality = safe(placemark.locality);
          final administrativeArea = safe(placemark.administrativeArea);
          final country = safe(placemark.country);

          List<String> addressParts = [];
          if (street.isNotEmpty) addressParts.add(street);
          if (name.isNotEmpty && name != street) addressParts.add(name);
          if (subLocality.isNotEmpty) addressParts.add(subLocality);
          if (locality.isNotEmpty) addressParts.add(locality);
          if (administrativeArea.isNotEmpty)
            addressParts.add(administrativeArea);
          if (country.isNotEmpty && country != 'Indonesia')
            addressParts.add(country);

          if (addressParts.isNotEmpty) {
            final address = addressParts.join(', ');
            final namaJalan = street.isNotEmpty
                ? street
                : (name.isNotEmpty
                    ? name
                    : (locality.isNotEmpty ? locality : 'Location'));

            logger.i('✅ Alamat berhasil didapat: $address');
            logger.i('✅ Nama jalan: $namaJalan');
            return {'address': address, 'namaJalan': namaJalan};
          }
        }
      } catch (e, stackTrace) {
        logger.e(
            'Error fetching address (attempt ${retryCount + 1}/$maxRetries)',
            error: e,
            stackTrace: stackTrace);
      }

      retryCount++;
      if (retryCount < maxRetries) {
        logger.i('Retry geocoding dalam 2 detik...');
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    logger.w(
        'Geocoding package gagal setelah $maxRetries attempts, mencoba OpenStreetMap API...');
    try {
      return await fetchAddressFromOpenStreetMap(currentLocation);
    } catch (e) {
      logger.e('OpenStreetMap API juga gagal', error: e);
      return {'address': null, 'namaJalan': null};
    }
  }

  /// Fetch address menggunakan OpenStreetMap Nominatim API (fallback)
  Future<Map<String, String?>> fetchAddressFromOpenStreetMap(
    LatLng currentLocation,
  ) async {
    try {
      logger.i('Mencoba geocoding menggunakan OpenStreetMap Nominatim API...');
      final lat = currentLocation.latitude;
      final lng = currentLocation.longitude;

      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&addressdetails=1',
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'SalimsApps/1.0',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final addressData = data['address'] as Map<String, dynamic>?;

        if (addressData != null) {
          final safe = (dynamic val) => val?.toString() ?? '';

          final road = safe(addressData['road']);
          final houseNumber = safe(addressData['house_number']);
          final suburb = safe(addressData['suburb']);
          final city = safe(addressData['city'] ??
              addressData['town'] ??
              addressData['village']);
          final state = safe(addressData['state']);
          final country = safe(addressData['country']);

          List<String> addressParts = [];
          if (houseNumber.isNotEmpty && road.isNotEmpty) {
            addressParts.add('$houseNumber $road');
          } else if (road.isNotEmpty) {
            addressParts.add(road);
          }
          if (suburb.isNotEmpty) addressParts.add(suburb);
          if (city.isNotEmpty) addressParts.add(city);
          if (state.isNotEmpty) addressParts.add(state);
          if (country.isNotEmpty && country != 'Indonesia')
            addressParts.add(country);

          if (addressParts.isNotEmpty) {
            final address = addressParts.join(', ');
            final namaJalan =
                road.isNotEmpty ? road : (city.isNotEmpty ? city : 'Location');

            logger.i('✅ Alamat berhasil didapat dari OpenStreetMap: $address');
            logger.i('✅ Nama jalan: $namaJalan');
            return {'address': address, 'namaJalan': namaJalan};
          }
        }
      }

      logger.w('OpenStreetMap API tidak mengembalikan alamat yang valid');
      return {'address': null, 'namaJalan': null};
    } catch (e, stackTrace) {
      logger.e('Error fetching address from OpenStreetMap',
          error: e, stackTrace: stackTrace);
      return {'address': null, 'namaJalan': null};
    }
  }

  /// Cek apakah lokasi adalah fake GPS (mock location)
  Future<bool> isFakeGPS(Position position) async {
    try {
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

      if (position.accuracy < 1.0 || position.accuracy > 1000.0) {
        logger
            .w('Fake GPS detected: Suspicious accuracy: ${position.accuracy}');
        return true;
      }

      if (position.latitude < -90 ||
          position.latitude > 90 ||
          position.longitude < -180 ||
          position.longitude > 180) {
        logger.w('Fake GPS detected: Invalid coordinates');
        return true;
      }

      if (position.speed > 0 && position.speed > 1000) {
        logger.w('Fake GPS detected: Suspicious speed: ${position.speed} m/s');
        return true;
      }

      final now = DateTime.now();
      final positionTime = position.timestamp;
      final timeDiff = now.difference(positionTime).inSeconds;
      if (timeDiff > 300) {
        logger
            .w('Fake GPS detected: Stale location data: $timeDiff seconds old');
        return true;
      }

      return false;
    } catch (e) {
      logger.e('Error checking fake GPS: $e');
      return false;
    }
  }

  /// Tampilkan warning jika terdeteksi fake GPS
  void showFakeGPSWarning(BuildContext context) {
    showDialog(
      context: context,
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

  /// Show error message untuk location permission
  void showLocationPermissionError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
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
  void showLocationError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        duration: Duration(seconds: 3),
        content: Text(
          'Gagal mengambil lokasi GPS. Pastikan GPS aktif dan coba lagi.',
        ),
        backgroundColor: Colors.red,
      ),
    );
  }
}

