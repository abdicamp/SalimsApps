import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:salims_apps_new/core/models/task_list_history_models.dart';
import 'package:salims_apps_new/core/models/task_list_models.dart';
import 'package:salims_apps_new/core/services/api_services.dart';
import 'package:stacked/stacked.dart';

import '../../../core/models/testing_order_history_models.dart';

class HistoryViewmodel extends FutureViewModel {
  BuildContext? context;
  ApiService apiService = new ApiService();
  String? fromDate;
  String? toDate;
  DateTimeRange? selectedRange;
  TextEditingController? tanggalCtrl = new TextEditingController();
  List<TestingOrder> listTaskHistory = [];
  List<TestingOrder> listTaskHistorySearch = [];
  HistoryViewmodel({this.context});

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
          '${_formatDate(selectedRange!.start)}-${_formatDate(selectedRange!.end)}';

      notifyListeners();
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  void onSearchTextChangedMyRequest(String text) {
    listTaskHistory = text.isEmpty || text == 'All'
        ? listTaskHistorySearch
        : listTaskHistorySearch
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

  getDataTaskHistory() async {
    setBusy(true);
    try {
      tanggalCtrl?.text = '${DateFormat('yyyy-MM-dd').format(DateTime.now())}-${DateFormat('yyyy-MM-dd').format(DateTime.now())}';
      final response = await apiService.getTaskListHistory(tanggalCtrl?.text ?? '${DateFormat('yyyy-MM-dd').format(DateTime.now())}-${DateFormat('yyyy-MM-dd').format(DateTime.now())}');
      listTaskHistory = List.from(response!.data!.data ?? []);
      print("listTaskHistory : ${jsonEncode(listTaskHistory)}");
      print("listTaskHistory length : ${listTaskHistory.length}");
      listTaskHistorySearch = List.from(response!.data!.data ?? []);
      setBusy(false);
      notifyListeners();
    } catch (e) {
      setBusy(false);
      notifyListeners();
    }
  }

  getDate() async {
    final now = DateTime.now();
    final fromDate = DateTime(now.year, now.month, 1); // 1 tanggal awal bulan
    final toDate = now; // hari ini
    final dateFormat = DateFormat('yyyy-MM-dd');
    final fromDateStr = dateFormat.format(fromDate);
    final toDateStr = dateFormat.format(toDate);

    tanggalCtrl?.text = '${fromDateStr}-${toDateStr}';
    await getDataTaskHistory();
    notifyListeners();
  }

  @override
  Future futureToRun() async {
    await getDate();

  }
}
