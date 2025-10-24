class TaskListModels {
  final bool status;
  final int code;
  final String message;
  final List<TestingOrder> data;
  final String? error;

  TaskListModels({
    required this.status,
    required this.code,
    required this.message,
    required this.data,
    this.error,
  });

  factory TaskListModels.fromJson(Map<String, dynamic> json) {
    return TaskListModels(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? "",
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => TestingOrder.fromJson(e))
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

class TestingOrder {
  final String reqnumber;
  final String tsnumber;
  final String ptsnumber;
  String? geotag;
  final String tsdate;
  final String sampleno;
  final String sampleCode;
  final String sampleName;
  final String samplecategory;
  final String servicetype;
  final String zonacode;
  final String zonaname;
  final String subzonacode;
  final String subzonaname;
  final String? address;
  final String samplingdate;

  TestingOrder({
     this.geotag,
    required this.reqnumber,
    required this.ptsnumber,
    required this.tsnumber,
    required this.tsdate,
    required this.sampleno,
    required this.sampleCode,
    required this.sampleName,
    required this.samplecategory,
    required this.servicetype,
    required this.zonacode,
    required this.zonaname,
    required this.subzonacode,
    required this.subzonaname,
    this.address,
    required this.samplingdate,
  });

  factory TestingOrder.fromJson(Map<String, dynamic> json) {
    return TestingOrder(
      geotag: json['geotag'] ?? "",
      reqnumber: json['reqnumber'] ?? "",
      ptsnumber: json['ptsnumber'] ?? "",
      tsnumber: json['tsnumber'] ?? "",
      tsdate: json['tsdate'] ?? "",
      sampleno: json['sampleno'] ?? "",
      sampleCode: json['samplecode'] ?? "",
      sampleName: json['samplename'] ?? "",
      samplecategory: json['samplecategory'] ?? "",
      servicetype: json['servicetype'] ?? "",
      zonacode: json['zonacode'] ?? "",
      zonaname: json['zonaname'] ?? "",
      subzonacode: json['subzonacode'] ?? "",
      subzonaname: json['subzonaname'] ?? "",
      address: json['address'],
      samplingdate: json['samplingdate'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "geotag": geotag,
      "reqnumber": reqnumber,
      "ptsnumber": ptsnumber,
      "tsnumber": tsnumber,
      "tsdate": tsdate,
      "sampleno": sampleno,
      "samplecode": sampleCode,
      "samplename": sampleName,
      "samplecategory": samplecategory,
      "servicetype": servicetype,
      "zonacode": zonacode,
      "zonaname": zonaname,
      "subzonacode": subzonacode,
      "subzonaname": subzonaname,
      "address": address,
      "samplingdate": samplingdate,
    };
  }
}
