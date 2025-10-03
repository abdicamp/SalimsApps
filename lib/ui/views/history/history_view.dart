import 'package:flutter/material.dart';
import 'package:salims_apps_new/ui/views/history/history_viewmodel.dart';
import 'package:stacked/stacked.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => HistoryViewmodel(),
      builder: (context, vm, child) {
        return Scaffold();
      },
    );
  }
}
