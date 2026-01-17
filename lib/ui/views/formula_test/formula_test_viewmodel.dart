import 'dart:convert';
import 'package:stacked/stacked.dart';
import '../../../core/models/formula_exec_models.dart';

class FormulaTestViewModel extends BaseViewModel {
  List<FormulaExec> formulaExecList = [];
  Set<int> expandedIndices = {};

  void toggleExpand(int index) {
    if (expandedIndices.contains(index)) {
      expandedIndices.remove(index);
    } else {
      expandedIndices.add(index);
    }
    notifyListeners();
  }

  bool isExpanded(int index) {
    return expandedIndices.contains(index);
  }

  void loadTestData() {
    final jsonString = '''
    {
      "code": 200,
      "status": true,
      "message": "Success get Formula Data",
      "data": [
        {
          "formulacode": "FO0022",
          "formulaname": "Kalibrasi",
          "refcode": "Kekeruhan",
          "formulaversion": 1,
          "formulalevel": 1,
          "description": null,
          "samplecode": "SM0001",
          "version": 3,
          "formula_detail": [
            {
              "samplecode": "SM0001",
              "parcode": "PA0148",
              "formulacode": "FO0022",
              "formulaversion": 1,
              "description": null,
              "lspec": null,
              "uspec": null,
              "version": 3,
              "parameter": "@LARUTANSTD@",
              "simvalue": "1",
              "detailno": 1,
              "fortype": "Parameter",
              "comparespec": false,
              "formula": null,
              "simformula": null,
              "simresult": "1"
            },
            {
              "samplecode": "SM0001",
              "parcode": "PA0148",
              "formulacode": "FO0022",
              "formulaversion": 1,
              "description": null,
              "lspec": null,
              "uspec": null,
              "version": 3,
              "parameter": "@TOLERANSI@",
              "simvalue": "1",
              "detailno": 2,
              "fortype": "Parameter",
              "comparespec": false,
              "formula": null,
              "simformula": null,
              "simresult": "1"
            },
            {
              "samplecode": "SM0001",
              "parcode": "PA0148",
              "formulacode": "FO0022",
              "formulaversion": 1,
              "description": null,
              "lspec": null,
              "uspec": null,
              "version": 3,
              "parameter": "@HASIL@",
              "simvalue": "1",
              "detailno": 3,
              "fortype": "ResultSupport1",
              "comparespec": false,
              "formula": null,
              "simformula": null,
              "simresult": "1"
            }
          ]
        },
        {
          "formulacode": "FO0023",
          "formulaname": "Kekeruhan",
          "refcode": "Kekeruhan",
          "formulaversion": 1,
          "formulalevel": 2,
          "description": null,
          "samplecode": "SM0001",
          "version": 3,
          "formula_detail": [
            {
              "samplecode": "SM0001",
              "parcode": "PA0148",
              "formulacode": "FO0023",
              "formulaversion": 1,
              "description": null,
              "lspec": null,
              "uspec": null,
              "version": 3,
              "parameter": "@HASIL@",
              "simvalue": "1",
              "detailno": 1,
              "fortype": "Result",
              "comparespec": true,
              "formula": null,
              "simformula": null,
              "simresult": "0.2"
            }
          ]
        },
        {
          "formulacode": "FO0024",
          "formulaname": "Kekeruhan Duplo",
          "refcode": "Kekeruhan",
          "formulaversion": 1,
          "formulalevel": 3,
          "description": null,
          "samplecode": "SM0001",
          "version": 3,
          "formula_detail": [
            {
              "samplecode": "SM0001",
              "parcode": "PA0148",
              "formulacode": "FO0024",
              "formulaversion": 1,
              "description": null,
              "lspec": null,
              "uspec": null,
              "version": 3,
              "parameter": "\$HASIL\$",
              "simvalue": "1",
              "detailno": 1,
              "fortype": "Reference",
              "comparespec": false,
              "formula": "AVG(#FO0023;@HASIL@;1#, #FO0023;@HASIL@;2#)",
              "simformula": "AVG(0.20 0.22)",
              "simresult": "0.21"
            }
          ]
        },
        {
          "formulacode": "FO0025",
          "formulaname": "%RPD Kekeruhan",
          "refcode": "Kekeruhan",
          "formulaversion": 1,
          "formulalevel": 4,
          "description": null,
          "samplecode": "SM0001",
          "version": 3,
          "formula_detail": [
            {
              "samplecode": "SM0001",
              "parcode": "PA0148",
              "formulacode": "FO0025",
              "formulaversion": 1,
              "description": null,
              "lspec": null,
              "uspec": null,
              "version": 3,
              "parameter": "@BATAS_RPD@",
              "simvalue": "0.1",
              "detailno": 1,
              "fortype": "Reference",
              "comparespec": false,
              "formula": null,
              "simformula": null,
              "simresult": "0.1"
            },
            {
              "samplecode": "SM0001",
              "parcode": "PA0148",
              "formulacode": "FO0025",
              "formulaversion": 1,
              "description": null,
              "lspec": null,
              "uspec": null,
              "version": 3,
              "parameter": "@U95%@",
              "simvalue": "0.01",
              "detailno": 2,
              "fortype": "Reference",
              "comparespec": false,
              "formula": null,
              "simformula": null,
              "simresult": "0.01"
            },
            {
              "samplecode": "SM0001",
              "parcode": "PA0148",
              "formulacode": "FO0025",
              "formulaversion": 1,
              "description": null,
              "lspec": null,
              "uspec": null,
              "version": 3,
              "parameter": "\$EVALUASIU95%\$",
              "simvalue": null,
              "detailno": 3,
              "fortype": "ResultSupport2",
              "comparespec": false,
              "formula": "IF( @U95%@ > @BATAS_RPD@,\\"Evaluasi\\",\\"Diterima\\")",
              "simformula": "IF(0.01 > 0.1, \\"Evaluasi\\", \\"Diterima\\")",
              "simresult": "Diterima"
            }
          ]
        }
      ]
    }
    ''';

    try {
      final jsonData = jsonDecode(jsonString);
      final response = FormulaExecResponse.fromJson(jsonData);
      formulaExecList = response.data;
      notifyListeners();
    } catch (e) {
      print("Error loading test data: $e");
    }
  }

  void updateSimResult(int formulaIndex, int detailIndex, String newValue) {
    if (formulaIndex >= 0 &&
        formulaIndex < formulaExecList.length &&
        detailIndex >= 0 &&
        detailIndex < formulaExecList[formulaIndex].formula_detail.length) {
      formulaExecList[formulaIndex].formula_detail[detailIndex].simresult = newValue;
      notifyListeners();
    }
  }

  void printUpdatedData() {
    final jsonData = FormulaExecResponse(
      code: 200,
      status: true,
      message: "Success get Formula Data",
      data: formulaExecList,
    );
    print(jsonEncode(jsonData.toJson()));
  }
}

