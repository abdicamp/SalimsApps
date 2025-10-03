// lib/state/global_loading_state.dart
import 'package:flutter/material.dart';

class GlobalLoadingState with ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void show() {
    _isLoading = true;
    notifyListeners();
  }

  void hide() {
    _isLoading = false;
    notifyListeners();
  }
}
