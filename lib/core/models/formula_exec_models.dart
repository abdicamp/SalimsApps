class FormulaExecResponse {
  final int code;
  final bool status;
  final String message;
  final List<FormulaExec> data;

  FormulaExecResponse({
    required this.code,
    required this.status,
    required this.message,
    required this.data,
  });

  factory FormulaExecResponse.fromJson(Map<String, dynamic> json) {
    return FormulaExecResponse(
      code: json['code'] ?? 0,
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List?)
              ?.map((e) => FormulaExec.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'status': status,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class FormulaExec {
  final String formulacode;
  final String formulaname;
  final String refcode;
  final int formulaversion;
  final int formulalevel;
  final String? description;
  final String samplecode;
  final int version;
  final List<FormulaDetail> formula_detail;

  FormulaExec({
    required this.formulacode,
    required this.formulaname,
    required this.refcode,
    required this.formulaversion,
    required this.formulalevel,
    this.description,
    required this.samplecode,
    required this.version,
    required this.formula_detail,
  });

  factory FormulaExec.fromJson(Map<String, dynamic> json) {
    // Parse formula_detail dengan lebih robust
    // Support kedua format: 'formula_detail' (baru) dan 'details' (lama)
    List<FormulaDetail> details = [];
    
    // Cek apakah menggunakan format baru (formula_detail) atau format lama (details)
    final detailData = json['formula_detail'] ?? json['details'];
    
    if (detailData != null) {
      if (detailData is List) {
        try {
          details = (detailData as List)
              .map((e) {
                if (e is Map<String, dynamic>) {
                  return FormulaDetail.fromJson(e);
                } else {
                  return null;
                }
              })
              .whereType<FormulaDetail>()
              .toList();
        } catch (e) {
          print('Error parsing formula_detail/details: $e');
          details = [];
        }
      }
    }
    
    // Support kedua format untuk field lainnya
    return FormulaExec(
      formulacode: json['formulacode'] ?? '',
      formulaname: json['formulaname'] ?? '',
      refcode: json['refcode'] ?? '',
      formulaversion: json['formulaversion'] ?? json['version'] ?? 0,
      formulalevel: json['formulalevel'] ?? 0,
      description: json['description'],
      samplecode: json['samplecode'] ?? '',
      version: json['version'] ?? 0,
      formula_detail: details,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'formulacode': formulacode,
      'formulaname': formulaname,
      'refcode': refcode,
      'formulaversion': formulaversion,
      'formulalevel': formulalevel,
      'description': description,
      'samplecode': samplecode,
      'version': version,
      'formula_detail': formula_detail.map((e) => e.toJson()).toList(),
    };
  }
}

class FormulaDetail {
  final String samplecode;
  final String parcode;
  final String formulacode;
  final int formulaversion;
  final String? description;
  final String? lspec;
  final String? uspec;
  final int version;
  final String parameter;
  final String? simvalue;
  final int detailno;
  final String fortype;
  final bool comparespec;
  final String? formula;
  final String? simformula;
  String? simresult;

  FormulaDetail({
    required this.samplecode,
    required this.parcode,
    required this.formulacode,
    required this.formulaversion,
    this.description,
    this.lspec,
    this.uspec,
    required this.version,
    required this.parameter,
    this.simvalue,
    required this.detailno,
    required this.fortype,
    required this.comparespec,
    this.formula,
    this.simformula,
    this.simresult,
  });

  factory FormulaDetail.fromJson(Map<String, dynamic> json) {
    // Support format lama (tanpa samplecode, parcode, dll) dan format baru
    return FormulaDetail(
      samplecode: json['samplecode'] ?? '',
      parcode: json['parcode'] ?? '',
      formulacode: json['formulacode'] ?? '',
      formulaversion: json['formulaversion'] ?? 0,
      description: json['description'],
      lspec: json['lspec'],
      uspec: json['uspec'],
      version: json['version'] ?? 0,
      parameter: json['parameter'] ?? '',
      simvalue: json['simvalue']?.toString(),
      detailno: json['detailno'] ?? 0,
      fortype: json['fortype'] ?? '',
      comparespec: json['comparespec'] ?? false,
      formula: json['formula'],
      simformula: json['simformula'],
      simresult: json['simresult']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'samplecode': samplecode,
      'parcode': parcode,
      'formulacode': formulacode,
      'formulaversion': formulaversion,
      'description': description,
      'lspec': lspec,
      'uspec': uspec,
      'version': version,
      'parameter': parameter,
      'simvalue': simvalue,
      'detailno': detailno,
      'fortype': fortype,
      'comparespec': comparespec,
      'formula': formula,
      'simformula': simformula,
      'simresult': simresult,
    };
  }
}

