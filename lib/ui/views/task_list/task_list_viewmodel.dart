import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:salims_apps_new/core/models/parameter_models.dart';
import 'package:salims_apps_new/core/services/api_services.dart';
import 'package:salims_apps_new/core/models/task_list_models.dart';
import 'package:salims_apps_new/core/services/local_Storage_Services.dart';
import 'package:salims_apps_new/core/services/location_service.dart';
import 'package:salims_apps_new/core/utils/radius_calculate.dart';
import 'package:salims_apps_new/ui/views/detail_task/detail_task_view.dart';
import 'package:stacked/stacked.dart';

class TaskListViewmodel extends FutureViewModel {
  BuildContext? context;
  TextEditingController? tanggalCtrl = new TextEditingController();
  DateTimeRange? selectedRange;
  TaskListViewmodel({this.context});
  final ApiService _apiServices = ApiService();
  final LocalStorageService localStorageService = LocalStorageService();
  final LocationService locationService = LocationService();
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
  List<TestingOrder> listTask = [];
  List<dynamic> listTaskParameterAndEquipment = [];
  List<TestingOrder> listTaskSearch = [];
  String? dateFrom;
  String? dateTo;
  
  Position? userPosition;
  LatLng? currentLocation;

  void pickDateRange() async {
    DateTimeRange? newRange = await showDateRangePicker(
      context: context!,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: selectedRange,
    );

    if (newRange != null) {
      selectedRange = newRange;
      tanggalCtrl!.text =
          '${_formatDate(selectedRange!.start)} - ${_formatDate(selectedRange!.end)}';
      dateFrom = _formatDate(selectedRange!.start);
      dateTo = _formatDate(selectedRange!.end);
      getListTask();
      notifyListeners();
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  void onSearchTextChangedMyRequest(String text) {
    listTask = text.isEmpty || text == 'All'
        ? listTaskSearch
        : listTaskSearch
            .where(
              (item) =>
                  item.reqnumber.toString().toLowerCase().contains(
                        text.toLowerCase(),
                      ) ||
                  item.ptsnumber.toString().toLowerCase().contains(
                        text.toLowerCase(),
                      ) ||
                  item.zonaname.toString().toLowerCase().contains(
                        text.toLowerCase(),
                      ),
            )
            .toList();

    notifyListeners();
  }

  getListTask() async {
    setBusy(true);
    try {
      // final response = await _apiServices.getTaskList(tanggalCtrl?.text ?? '${DateFormat('yyyy-MM-dd').format(DateTime.now())} - ${DateFormat('yyyy-MM-dd').format(DateTime.now())}');
       if (selectedRange != null) {
      dateFrom = _formatDate(selectedRange!.start);
      dateTo = _formatDate(selectedRange!.end);
    } else {  
      final now = DateTime.now();
      dateFrom = _formatDate(DateTime(now.year, now.month, 1)); // 1 tanggal awal bulan
      dateTo = _formatDate(now); // hari ini
    }
      
      final response = await _apiServices.getTaskList(dateFrom!, dateTo!);
      print("response: ${response?.data?.data}");
      if (response != null && response.data != null) {
        listTask = response.data!.data ?? [];
        listTaskSearch = response.data!.data ?? [];
        if (listTask.isNotEmpty) {
          listTaskParameterAndEquipment.clear();
          for (var item in listTask) {
            final responseParameterAndEquipment =
                await _apiServices.getParameterAndEquipment(
                    '${item.ptsnumber}', '${item.sampleno}');
            final dataPars = responseParameterAndEquipment?.data?['data'];
            listTaskParameterAndEquipment.add(dataPars);
          }
        }
      } else {
        listTask = [];
        listTaskSearch = [];
      }

      notifyListeners();
      setBusy(false);
    } catch (e) {

      logger.e('Error getting list task', error: e);
      print("Error getting list task: $e");
    }
    setBusy(false);
    notifyListeners();
  }

  getOneTaskList(String? tsNumber) async {
    setBusy(true);
    try {
      final getData = await localStorageService.getUserData();
      final response = await _apiServices.getOneTaskList(tsNumber);

      final dataUpdate = {
        ...response,
        'appstatus': 'APPROVED',
        'user': '${getData?.data?.username}',
        'appdescription': '',
      };

      setBusy(false);
      notifyListeners();
    } catch (e) {
      // Error handled silently
    }
  }

  getDate() async {
    final now = DateTime.now();
    final fromDate = DateTime(now.year, now.month, 1); // 1 tanggal awal bulan
    final toDate = now; // hari ini
    final dateFormat = DateFormat('yyyy-MM-dd');
    final fromDateStr = dateFormat.format(fromDate);
    final toDateStr = dateFormat.format(toDate);

    tanggalCtrl?.text = '';
    await getListTask();
    notifyListeners();
  }

  /// Cek apakah lokasi saat ini berada dalam radius lokasi sampling
  Future<bool> cekRadiusSamplingLocation(TestingOrder task) async {
    try {
      // Ambil radius dari task
      final radiusLocation = task.samplingradius;
      
      // Jika radiusLocation tidak ada atau 0, skip validasi
      if (radiusLocation == null || radiusLocation == 0) {
        return true;
      }

      // Ambil lokasi sampling dari task (prioritas: latlong > gps_subzone > geotag)
      String? samplingLocation;
      if (task.latlong != null && task.latlong!.isNotEmpty) {
        samplingLocation = task.latlong!;
      } else if (task.gps_subzone != null && task.gps_subzone.isNotEmpty) {
        samplingLocation = task.gps_subzone;
      } else if (task.geotag != null && task.geotag!.isNotEmpty) {
        samplingLocation = task.geotag!;
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
      double currentLat;
      double currentLng;
      
      if (currentLocation != null) {
        currentLat = currentLocation!.latitude;
        currentLng = currentLocation!.longitude;
      } else if (userPosition != null) {
        currentLat = userPosition!.latitude;
        currentLng = userPosition!.longitude;
      } else {
        // Ambil lokasi saat ini jika currentLocation belum di-set
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        userPosition = position;
        currentLocation = LatLng(position.latitude, position.longitude);
        currentLat = position.latitude;
        currentLng = position.longitude;
      }

      // Hitung jarak
      final distance = RadiusCalculate.calculateDistanceInMeter(
        currentLat,
        currentLng,
        samplingLat,
        samplingLng,
      );

      // Cek apakah dalam radius
      return distance <= radiusLocation;
    } catch (e) {
      logger.e('Error checking radius sampling location', error: e);
      return false;
    }
  }

  /// Show dialog ketika user berada di luar radius lokasi sampling
  void showOutOfRadiusDialog(int radiusLocation) {
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
            "Silakan pindah ke dalam radius $radiusLocation meter dari lokasi sampling untuk dapat membuka task ini.",
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

  /// Handle navigasi ke detail task dengan validasi lokasi
  Future<void> navigateToDetailTask(TestingOrder task, BuildContext context) async {
    try {
      setBusy(true);
      
      // Cek permission lokasi
      final permission = await locationService.checkAndRequestLocationPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (context != null) {
          locationService.showLocationPermissionError(context);
        }
        setBusy(false);
        return;
      }

      // Ambil lokasi saat ini
      final position = await locationService.fetchCurrentLocation();
      userPosition = position;
      currentLocation = LatLng(position.latitude, position.longitude);

      // Cek fake GPS
      final isFake = await locationService.isFakeGPS(position);
      if (isFake) {
        if (context != null) {
          locationService.showFakeGPSWarning(context);
        }
        setBusy(false);
        return;
      }

      // Validasi radius lokasi sampling
      final isInRadius = await cekRadiusSamplingLocation(task);
      setBusy(false);
      
      if (!isInRadius) {
        showOutOfRadiusDialog(task.samplingradius ?? 0);
        return;
      }

      // Jika valid, navigasi ke detail task
      if (context != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DetailTaskView(
              listData: task,
              isDetailhistory: false,
            ),
          ),
        );
      }
    } catch (e) {
      logger.e('Error navigating to detail task', error: e);
      setBusy(false);
      if (context != null) {
        locationService.showLocationError(context);
      }
    }
  }

  @override
  Future futureToRun() async {
    await getDate();
    // await getListTask();
  }
}
