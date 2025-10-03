import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';

class TaskListViewmodel extends FutureViewModel {
  BuildContext? context;
  TextEditingController? tanggalCtrl = new TextEditingController();
  DateTimeRange? selectedRange;
  TaskListViewmodel({this.context});

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
      notifyListeners();
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy/MM/dd').format(date);
  }

  @override
  Future futureToRun() async {}
}
