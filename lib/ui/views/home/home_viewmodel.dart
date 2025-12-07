import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:salims_apps_new/core/services/local_Storage_Services.dart';
import 'package:salims_apps_new/ui/views/splash_screen/splash_screen_view.dart';
import 'package:stacked/stacked.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/models/task_list_models.dart';
import '../../../core/services/api_services.dart';

class HomeViewmodel extends FutureViewModel {
  BuildContext? context;
  HomeViewmodel({this.context});
  final LocalStorageService _storage = LocalStorageService();
  ApiService apiService = new ApiService();
  String? username = '';
  int totalListTask = 0;
  List<TestingOrder> listTask = [];
  TestingOrder? dataNearestLocation;
  int totalListTaskHistory = 0;
  double? totalPerforma = 0.0;
  int? radius = 0;
  double lat = 0;
  double lng = 0;
  int newNotificationCount = 0;
  DateTimeRange? selectedRange;
  TextEditingController? dateFilterController = TextEditingController();

  getUserData() async {
    try {
      // Remove unnecessary delay for faster loading
      final getData = await _storage.getUserData();
      username = getData?.data?.username;

      notifyListeners();
    } catch (e) {
      setBusy(false);
      notifyListeners();
      print("Error get data : ${e}");
    }
  }

  getMonthlyReport() {
    final done = totalListTask;
    final total = totalListTaskHistory;
    if (total <= 0) {
      // Tidak ada data ⇒ tampilkan spinner indeterminate
      totalPerforma = 0.0;
    } else {
      final ratio = done / total; // double
      // Amankan dari NaN/Infinity dan paksa 0..1
      totalPerforma = ratio.isFinite ? ratio.clamp(0.0, 1.0) : null;
    }

    notifyListeners();
  }

  logout() async {
    try {
      setBusy(true);
      await Future.delayed(Duration(seconds: 3));
      await _storage.clear();
      Navigator.of(context!).pushReplacement(
        MaterialPageRoute(builder: (context) => SplashScreenView()),
      );
      setBusy(false);

      notifyListeners();
    } catch (e) {
      print("error : ${e}");
      setBusy(false);

      notifyListeners();
    }
  }

  runAllFunction() async {
    setBusy(true);
    notifyListeners(); // Immediately notify to show loading
    try {
      final cekToken = await apiService.cekToken();

      if (cekToken) {
        // Run getUserData in parallel with getDataTask for faster loading
        await Future.wait<void>([
          getDataTask(),
          getUserData(),
          checkNewNotifications(),
        ]);
        // getMonthlyReport depends on getDataTask, so run it after
        getMonthlyReport();
        setBusy(false);
        notifyListeners();
      } else {
        await _storage.clear();
        setBusy(false);
        notifyListeners();
        Navigator.of(context!).pushReplacement(
            new MaterialPageRoute(builder: (context) => SplashScreenView()));
      }
    } catch (e) {
      setBusy(false);
      notifyListeners();
      print("Error in runAllFunction: $e");
    }
  }

  checkNewNotifications() async {
    try {
      final response = await apiService.getNotificationHistory();
      if (response?.data?.data != null) {
        final notifications = response!.data!.data!.data;
        if (notifications.isNotEmpty) {
          // Get the latest notification ID
          final latestNotificationId = notifications.first.id ?? 0;
          
          // Get last checked notification ID from storage
          final lastCheckedId = await _storage.getLastCheckedNotificationId();
          
          // Count notifications that are newer than last checked
          if (lastCheckedId == null) {
            // First time, count all notifications
            newNotificationCount = notifications.length;
            // Save the latest notification ID as last checked
            if (latestNotificationId > 0) {
              await _storage.saveLastCheckedNotificationId(latestNotificationId);
            }
          } else {
            // Count notifications with ID greater than last checked
            newNotificationCount = notifications
                .where((notification) {
                  final notificationId = notification.id ?? 0;
                  return notificationId > lastCheckedId;
                })
                .length;
          }
        } else {
          newNotificationCount = 0;
        }
      } else {
        newNotificationCount = 0;
      }
      notifyListeners();
    } catch (e) {
      print("Error checkNewNotifications: $e");
      newNotificationCount = 0;
      notifyListeners();
    }
  }

  markNotificationsAsRead() async {
    try {
      final response = await apiService.getNotificationHistory();
      if (response?.data?.data != null) {
        final notifications = response!.data!.data!.data;
        if (notifications.isNotEmpty) {
          final latestNotificationId = notifications.first.id ?? 0;
          if (latestNotificationId > 0) {
            await _storage.saveLastCheckedNotificationId(latestNotificationId);
            newNotificationCount = 0;
            notifyListeners();
          }
        }
      }
    } catch (e) {
      print("Error markNotificationsAsRead: $e");
    }
  }

  Future<void> openMap(double lat, double lng) async {
    final Uri googleUrl =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');

    if (await canLaunchUrl(googleUrl)) {
      await launchUrl(googleUrl, mode: LaunchMode.externalApplication);
    } else {
      throw 'Tidak dapat membuka Google Maps.';
    }
  }

  void pickDateRange() async {
    final now = DateTime.now();
    final initialRange = selectedRange ?? 
        DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: now,
        );
    
    DateTimeRange? newRange = await showDateRangePicker(
      context: context!,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: initialRange,
    );

    if (newRange != null) {
      selectedRange = newRange;
      dateFilterController!.text =
          '${_formatDate(selectedRange!.start)} - ${_formatDate(selectedRange!.end)}';
      getDataTask();
      notifyListeners();
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  void resetDateFilter() {
    selectedRange = null;
    dateFilterController!.clear();
    getDataTask();
    notifyListeners();
  }

  getDataTask() async {
    DateTime fromDate;
    DateTime toDate;
    
    if (selectedRange != null) {
      fromDate = selectedRange!.start;
      toDate = selectedRange!.end;
    } else {
      final now = DateTime.now();
      fromDate = DateTime(now.year, now.month, 1); // 1 tanggal awal bulan
      toDate = now; // hari ini
    }
    
    final dateFormat = DateFormat('yyyy-MM-dd');
    final fromDateStr = dateFormat.format(fromDate);
    final toDateStr = dateFormat.format(toDate);

    final responseTaskList =
        await apiService.getTaskList('${fromDateStr} - ${toDateStr}');
    final responseTaskListHistory =
        await apiService.getTaskListHistory('${fromDateStr} - ${toDateStr}');
    
    if (responseTaskList?.data?.data != null) {
      totalListTask = responseTaskList!.data!.data.length;
      listTask = List.from(responseTaskList.data!.data);
    } else {
      totalListTask = 0;
      listTask = [];
    }
    
    // Handle responseTaskListHistory - bisa status false dengan data kosong
    if (responseTaskListHistory?.data != null) {
      totalListTaskHistory = responseTaskListHistory!.data!.data.length;
    } else {
      totalListTaskHistory = 0;
      if (responseTaskListHistory?.error != null) {
        print("Error getTaskListHistory: ${responseTaskListHistory!.error}");
      }
    }
    dataNearestLocation = await getNearestLocation();
    notifyListeners();
  }

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Pastikan service aktif
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    // Minta izin
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    // Ambil posisi sekarang
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<TestingOrder?> getNearestLocation() async {
    try {
      Position current = await getCurrentLocation();

      double minDistance = double.infinity;
      TestingOrder? nearestPlace;
      print("listTask : ${listTask}");
      
      // Jika listTask kosong, return null
      if (listTask.isEmpty) {
        radius = 0;
        return null;
      }
      
      for (var place in listTask) {
        String? latlong = place.geotag;
        if (latlong == null || latlong.isEmpty) {
          continue; // Skip jika geotag null atau empty
        }
        
        var latLngSplit = latlong.split(',');
        if (latLngSplit.length < 2) {
          continue; // Skip jika format tidak valid
        }

        lat = double.tryParse(latLngSplit[0]) ?? 0.0;
        lng = double.tryParse(latLngSplit[1]) ?? 0.0;
        
        if (lat == 0.0 && lng == 0.0) {
          continue; // Skip jika parsing gagal
        }
        
        print("data location : ${lat},${lng}");
        double distance = Geolocator.distanceBetween(
          current.latitude,
          current.longitude,
          lat,
          lng,
        );

        if (distance < minDistance) {
          minDistance = distance;
          nearestPlace = place;
        }
      }
      
      // Cek apakah minDistance masih infinity (tidak ada tempat yang valid ditemukan)
      if (minDistance.isInfinite || minDistance.isNaN) {
        radius = 0;
        return null;
      }
      
      radius = minDistance.round();
      print(
          "Lokasi terdekat: ${nearestPlace?.subzonaname} (${minDistance.round()} m) , Current Location : ${current.latitude},${current.longitude} , data location : ${nearestPlace?.geotag}");
      return nearestPlace;
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  @override
  Future futureToRun() async {
    setBusy(true);
    // Initialize date filter controller
    if (dateFilterController == null) {
      dateFilterController = TextEditingController();
    }
    await runAllFunction();
  }
}
