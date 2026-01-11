class ParameterModels {
  final bool status;
  final int code;
  final String message;
  final List<TestingOrderParameter> data;
  final String? error;

  ParameterModels({
    required this.status,
    required this.code,
    required this.message,
    required this.data,
    this.error,
  });

  factory ParameterModels.fromJson(Map<String, dynamic> json) {
    return ParameterModels(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? "",
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => TestingOrderParameter.fromJson(e))
              .toList() ??
          [],
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "status": status,
      "code": code,
      "message": message,
      "data": data.map((e) => e.toJson()).toList(),
      "error": error,
    };
  }
}

class ParameterEquipmentDetail {
  final String equipmentcode;
  final String equipmentname;
  final String? equipmentversion;
  final String? duedatecalibration;
  final String? equipmenttype;

  ParameterEquipmentDetail({
    required this.equipmentcode,
    required this.equipmentname,
    this.equipmentversion,
    this.duedatecalibration,
    this.equipmenttype,
  });

  factory ParameterEquipmentDetail.fromJson(Map<String, dynamic> json) {
    return ParameterEquipmentDetail(
      equipmentcode: json['equipmentcode'] ?? "",
      equipmentname: json['equipmentname'] ?? "",
      equipmentversion: json['equipmentversion']?.toString(),
      duedatecalibration: json['duedatecalibration']?.toString(),
      equipmenttype: json['equipmenttype']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "equipmentcode": equipmentcode,
      "equipmentname": equipmentname,
      "equipmentversion": equipmentversion,
      "duedatecalibration": duedatecalibration,
      "equipmenttype": equipmenttype,
    };
  }
}

class TestingOrderParameter {
  final String reqnumber;
  final String sampleno;
  final String parcode;
  final String parname;
  final String methodid;
  final bool insitu;
  final List<ParameterEquipmentDetail>? detail;

  TestingOrderParameter({
    required this.reqnumber,
    required this.sampleno,
    required this.parcode,
    required this.parname,
    required this.methodid,
    required this.insitu,
    this.detail,
  });

  factory TestingOrderParameter.fromJson(Map<String, dynamic> json) {
    return TestingOrderParameter(
      reqnumber: json['reqnumber'] ?? "",
      sampleno: json['sampleno'] ?? "",
      parcode: json['parcode'] ?? "",
      parname: json['parname'] ?? "",
      methodid: json['methodid'] ?? "",
      insitu: json['insitu'] ?? false,
      detail: json['detail'] != null
          ? (json['detail'] as List<dynamic>)
              .map((e) => ParameterEquipmentDetail.fromJson(e))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "reqnumber": reqnumber,
      "sampleno": sampleno,
      "parcode": parcode,
      "parname": parname,
      "methodid": methodid,
      "insitu": insitu,
      "detail": detail?.map((e) => e.toJson()).toList(),
    };
  }
}
