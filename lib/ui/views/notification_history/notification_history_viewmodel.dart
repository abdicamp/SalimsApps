import 'package:flutter/material.dart';
import 'package:salims_apps_new/core/models/notification_models.dart';
import 'package:salims_apps_new/core/services/api_services.dart';
import 'package:stacked/stacked.dart';

class NotificationHistoryViewmodel extends FutureViewModel {
  BuildContext? context;
  ApiService apiService = ApiService();
  List<NotificationItem> listNotifications = [];
  List<NotificationItem> listNotificationsSearch = [];
  TextEditingController? searchController = TextEditingController();
  
  NotificationHistoryViewmodel({this.context});

  void onSearchTextChanged(String text) {
    listNotifications = text.isEmpty
        ? listNotificationsSearch
        : listNotificationsSearch
            .where(
              (item) {
                final searchText = text.toLowerCase();
                final title = item.title?.toLowerCase() ?? '';
                final description = item.description?.toLowerCase() ?? '';
                final zonacode = item.zonacode?.toLowerCase() ?? '';
                final batchId = item.batchId?.toLowerCase() ?? '';
                return title.contains(searchText) ||
                    description.contains(searchText) ||
                    zonacode.contains(searchText) ||
                    batchId.contains(searchText);
              },
            )
            .toList();

    notifyListeners();
  }

  getNotificationHistory() async {
    setBusy(true);
    try {
      final response = await apiService.getNotificationHistory();
      if (response?.data?.data != null) {
        final notificationData = response!.data!.data!.data;
        listNotifications = List.from(notificationData);
        listNotificationsSearch = List.from(notificationData);
      } else {
        listNotifications = [];
        listNotificationsSearch = [];
      }
      setBusy(false);
      notifyListeners();
    } catch (e) {
      setBusy(false);
      notifyListeners();
      // Error handled silently
    }
  }

  @override
  Future futureToRun() async {
    await getNotificationHistory();
  }
}

