class TaskListHistoryModels {
  final bool status;
  final int code;
  final String message;
  final List<TaskListHistoryResponse> data;
  final String? error;

  TaskListHistoryModels({
    required this.status,
    required this.code,
    required this.message,
    required this.data,
    this.error,
  });

  factory TaskListHistoryModels.fromJson(Map<String, dynamic> json) {
    return TaskListHistoryModels(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? "",
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => TaskListHistoryResponse.fromJson(e))
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

class TaskListHistoryResponse {
  final String reqnumber;
  final String ptsnumber;
  final String sampleno;
  final String samplecategory;
  final String servicetype;
  final String zonacode;
  final String zonaname;
  final String subzonacode;
  final String subzonaname;
  final String? address;
  final String samplingdate;

  TaskListHistoryResponse({
    required this.reqnumber,
    required this.ptsnumber,
    required this.sampleno,
    required this.samplecategory,
    required this.servicetype,
    required this.zonacode,
    required this.zonaname,
    required this.subzonacode,
    required this.subzonaname,
    this.address,
    required this.samplingdate,
  });

  factory TaskListHistoryResponse.fromJson(Map<String, dynamic> json) {
    return TaskListHistoryResponse(
      reqnumber: json['reqnumber'] ?? "",
      ptsnumber: json['ptsnumber'] ?? "",
      sampleno: json['sampleno'] ?? "",
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
      "reqnumber": reqnumber,
      "ptsnumber": ptsnumber,
      "sampleno": sampleno,
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
