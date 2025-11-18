import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:salims_apps_new/core/models/task_list_history_models.dart';
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
  List<TestingOrderData> listTaskHistory = [];
  List<TestingOrderData> listTaskHistorySearch = [];
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
                  item.ReqNumber.toString().toLowerCase().contains(
                        text.toLowerCase(),
                      ) ||
                  item.PtsNumber.toString().toLowerCase().contains(
                        text.toLowerCase(),
                      ) ||
                  item.ZonaName.toString().toLowerCase().contains(
                        text.toLowerCase(),
                      ),
            )
            .toList();

    notifyListeners();
  }

  getDataTaskHistory() async {
    setBusy(true);
    try {
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

  @override
  Future futureToRun() async {
    await getDataTaskHistory();
  }
}
