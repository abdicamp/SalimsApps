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
  final String? tsnumber;
  final String ptsnumber;
  String? geotag;
  final String? tsdate;
  final String gps_subzone;
  final dynamic samplingradius;
  final String sampleno;
  final String buildingcode;
  final String sampleCode;
  final String sampleName;
  final dynamic sampleVersion;
  final String? samplecategory;
  final String samplecatname;
  final String? samplecatcode;
  final String servicetype;
  final String zonacode;
  final String zonaname;
  final String subzonacode;
  final String subzonaname;
  final String? address;
  final String samplingdate;
  final String? gps_ts;
  final String? latlong;
  final String? tsappstatus;
  final String? labourcode;
  final String? labourname;
  final String? branchcode_setup;
  final List<dynamic>? documents;
  final List<dynamic>? identitynumbers;
  final String? documentid;
  final String? documentname;
  final String? documentpath;
  final String? documenttype;
  final String? documentrefno;
  final String? identitynumber;

  TestingOrder({
    this.geotag,
    required this.reqnumber,
    required this.ptsnumber,
    this.tsnumber,
    this.tsdate,
    required this.gps_subzone,
    required this.samplingradius,
    required this.buildingcode,
    required this.sampleVersion,
    required this.sampleno,
    required this.sampleCode,
    required this.sampleName,
    this.samplecategory,  
    required this.samplecatname,
    this.samplecatcode,
    required this.servicetype,
    required this.zonacode,
    required this.zonaname,
    required this.subzonacode,
    required this.subzonaname,
    this.address,
    required this.samplingdate,
    this.gps_ts,
    this.latlong,
    this.tsappstatus,
    this.labourcode,
    this.labourname,
    this.branchcode_setup,
    this.documents,
    this.identitynumbers,
    this.documentid,
    this.documentname,
    this.documentpath,
    this.documenttype,
    this.documentrefno,
    this.identitynumber,
  });

  factory TestingOrder.fromJson(Map<String, dynamic> json) {
    return TestingOrder(
      geotag: json['geotag'],
      reqnumber: json['reqnumber'] ?? "",
      ptsnumber: json['ptsnumber'] ?? "",
      tsnumber: json['tsnumber'],
      tsdate: json['tsdate'],
      buildingcode: json['buildingcode'] ?? "",
      gps_subzone: json['gps_subzone'] ?? "",
      samplingradius: json['samplingradius'],
      sampleno: json['sampleno'] ?? "",
      sampleCode: json['samplecode'] ?? "",
      sampleName: json['samplename'] ?? "",
      sampleVersion: json['sampleversion'],
      samplecategory: json['samplecategory'],
      servicetype: json['servicetype'] ?? "",
      zonacode: json['zonacode'] ?? "",
      zonaname: json['zonaname'] ?? "",
      subzonacode: json['subzonacode'] ?? "",
      subzonaname: json['subzonaname'] ?? "",
      address: json['address'],
      samplingdate: json['samplingdate'] ?? "",
      samplecatname: json['samplecatname'] ?? "",
      samplecatcode: json['samplecatcode'],
      gps_ts: json['gps_ts'],
      latlong: json['latlong'],
      tsappstatus: json['tsappstatus'],
      labourcode: json['labourcode'],
      labourname: json['labourname'],
      branchcode_setup: json['branchcode_setup'],
      documents: json['documents'] != null ? List<dynamic>.from(json['documents']) : null,
      identitynumbers: json['identitynumbers'] != null ? List<dynamic>.from(json['identitynumbers']) : null,
      documentid: json['documentid'],
      documentname: json['documentname'],
      documentpath: json['documentpath'],
      documenttype: json['documenttype'],
      documentrefno: json['documentrefno'],
      identitynumber: json['identitynumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "geotag": geotag,
      "reqnumber": reqnumber,
      "ptsnumber": ptsnumber,
      "tsnumber": tsnumber,
      "buildingcode": buildingcode,
      "tsdate": tsdate,
      "gps_subzone": gps_subzone,
      "samplingradius": samplingradius,
      "sampleno": sampleno,
      "samplecode": sampleCode,
      "samplename": sampleName,
      "sampleversion": sampleVersion,
      "samplecategory": samplecategory,
      "samplecatcode": samplecatcode,
      "servicetype": servicetype,
      "zonacode": zonacode,
      "zonaname": zonaname,
      "subzonacode": subzonacode,
      "subzonaname": subzonaname,
      "address": address,
      "samplingdate": samplingdate,
      "samplecatname": samplecatname,
      "gps_ts": gps_ts,
      "latlong": latlong,
      "tsappstatus": tsappstatus,
      "labourcode": labourcode,
      "labourname": labourname,
      "branchcode_setup": branchcode_setup,
      "documents": documents,
      "identitynumbers": identitynumbers,
      "documentid": documentid,
      "documentname": documentname,
      "documentpath": documentpath,
      "documenttype": documenttype,
      "documentrefno": documentrefno,
      "identitynumber": identitynumber,
    };
  }
}
