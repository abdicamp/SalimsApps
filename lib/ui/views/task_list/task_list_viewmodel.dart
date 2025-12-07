import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:salims_apps_new/core/services/api_services.dart';
import 'package:salims_apps_new/core/models/task_list_models.dart';
import 'package:salims_apps_new/core/services/local_Storage_Services.dart';
import 'package:stacked/stacked.dart';

class TaskListViewmodel extends FutureViewModel {
  BuildContext? context;
  TextEditingController? tanggalCtrl = new TextEditingController();
  DateTimeRange? selectedRange;
  TaskListViewmodel({this.context});
  final ApiService _apiServices = ApiService();
  final LocalStorageService localStorageService = LocalStorageService();
  List<TestingOrder> listTask = [];
  List<TestingOrder> listTaskSearch = [];

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
      print("pickDateRange tanggalCtrl?.text: ${tanggalCtrl?.text}");
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
          ) ,
    )
        .toList();

    notifyListeners();
  }

  getListTask() async {
    setBusy(true);
    try {
      print("getListTask tanggalCtrl?.text: ${tanggalCtrl?.text}");
      // final response = await _apiServices.getTaskList(tanggalCtrl?.text ?? '${DateFormat('yyyy-MM-dd').format(DateTime.now())} - ${DateFormat('yyyy-MM-dd').format(DateTime.now())}');
      final response = await _apiServices.getTaskList(tanggalCtrl?.text ?? '');
      listTask = response!.data!.data;
      print("jsondecode getListTask :${jsonEncode(listTask)}");
      listTaskSearch = response.data!.data;
      notifyListeners();
      setBusy(false);
    } catch (e) {}
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

      print("data update : ${dataUpdate}");

      setBusy(false);
      notifyListeners();
    }catch (e) {
      print("error get one task : ${e}");
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
    await  getListTask();
    notifyListeners();
  }

  @override
  Future futureToRun() async {
    await getDate();
    // await getListTask();
  }
}
