import 'package:salims_apps_new/core/models/task_list_history_models.dart';
import 'package:salims_apps_new/core/services/api_services.dart';
import 'package:stacked/stacked.dart';

class HistoryViewmodel extends FutureViewModel {
  ApiService apiService = new ApiService();
  List<TaskListHistoryResponse> listTaskHistory = [];

  getDataTaskHistory() async {
    setBusy(true);
    try {
      final response = await apiService.getTaskListHistory();
      listTaskHistory = [
        TaskListHistoryResponse(
            reqnumber: "TO0001",
            ptsnumber: "PTS0001",
            sampleno: "MS001",
            samplecategory: "Product category 1",
            servicetype: "Testing and Taking Sample",
            zonacode: "MZO001",
            zonaname: "JAKARTA",
            subzonacode: "MSZ001",
            subzonaname: "TEST",
            address: null,
            samplingdate: "2024-11-01"),
        TaskListHistoryResponse(
            reqnumber: "TO0001",
            ptsnumber: "PTS0001",
            sampleno: "MS001",
            samplecategory: "Product category 1",
            servicetype: "Testing and Taking Sample",
            zonacode: "MZO001",
            zonaname: "JAKARTA",
            subzonacode: "MSZ001",
            subzonaname: "TEST",
            address: null,
            samplingdate: "2024-11-01")
      ];

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
