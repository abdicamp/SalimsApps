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

  getUserData() async {

    try {
      await Future.delayed(Duration(seconds: 1));
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
    totalPerforma = totalListTask / totalListTaskHistory;
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
    try {

      final cekToken = await apiService.cekToken();

      if (cekToken) {
        await getDataTask();
        await getMonthlyReport();
        await getUserData();
        setBusy(false);
        notifyListeners();
      } else {
        await _storage.clear();
        Navigator.of(context!).pushReplacement(
            new MaterialPageRoute(builder: (context) => SplashScreenView()));
        notifyListeners();
        setBusy(false);
      }
    }catch (e) {
      setBusy(false);
    }
  }

  Future<void> openMap(double lat, double lng) async {
    final Uri googleUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');

    if (await canLaunchUrl(googleUrl)) {
      await launchUrl(googleUrl, mode: LaunchMode.externalApplication);
    } else {
      throw 'Tidak dapat membuka Google Maps.';
    }
  }

  getDataTask() async {
    final now = DateTime.now();
    final fromDate = DateTime(now.year, now.month, 1); // 1 tanggal awal bulan
    final toDate = now; // hari ini
    final dateFormat = DateFormat('yyyy-MM-dd');
    final fromDateStr = dateFormat.format(fromDate);
    final toDateStr = dateFormat.format(toDate);

    final responseTaskList = await apiService.getTaskList('${fromDateStr}-${toDateStr}');
    final responseTaskListHistory = await apiService.getTaskListHistory(fromDateStr, toDateStr);
    totalListTask = responseTaskList!.data!.data.length;
    totalListTaskHistory = responseTaskListHistory!.data!.data.length;
    listTask = List.from(responseTaskList.data!.data);
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

      for (var place in listTask) {
        String? latlong = place.geotag;
        var latLngSplit = latlong?.split(',');

         lat = double.tryParse(latLngSplit![0]) ?? 0.0;
         lng = double.tryParse(latLngSplit[1]) ?? 0.0;
        print("data location : ${lat},${lng}");
        double distance = Geolocator.distanceBetween(
          current.latitude,
          current.longitude,
          lat!,
          lng!,
        );

        if (distance < minDistance) {
          minDistance = distance;
          nearestPlace = place;
        }
      }
      radius = minDistance.round();
      print("Lokasi terdekat: ${nearestPlace?.subzonaname} (${minDistance.round()
      } m) , Current Location : ${current.latitude},${current.longitude} , data location : ${nearestPlace?.geotag}");
      return nearestPlace;

    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  @override
  Future futureToRun() async {
    await runAllFunction();
  }
}
