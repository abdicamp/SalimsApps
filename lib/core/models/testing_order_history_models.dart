class TestingOrderHistoryModel {
  String status;
  String code;
  String message;
  List<TestingOrderData> data;
  String error;

  TestingOrderHistoryModel({
    required this.status,
    required this.code,
    required this.message,
    required this.data,
    required this.error,
  });

  factory TestingOrderHistoryModel.fromJson(Map<String, dynamic> json) {
    return TestingOrderHistoryModel(
      status: json['status'].toString(),
      code: json['code'].toString(),
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => TestingOrderData.fromJson(e))
          .toList() ??
          [],
      error: json['error']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'code': code,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
      'error': error,
    };
  }
}

class TestingOrderData {
  String ReqNumber;
  String PtsNumber;
  String SampleNo;
  String SampleCategory;
  String Samplecatname;
  String ServiceType;
  String ZonaCode;
  String ZonaName;
  String SubZonaCode;
  String SubZonaName;
  String Address;
  String SamplingDate;
  String TsDate;

  TestingOrderData({
    required this.ReqNumber,
    required this.PtsNumber,
    required this.SampleNo,
    required this.SampleCategory,
    required this.Samplecatname,
    required this.ServiceType,
    required this.ZonaCode,
    required this.ZonaName,
    required this.SubZonaCode,
    required this.SubZonaName,
    required this.Address,
    required this.SamplingDate,
    required this.TsDate,
  });

  factory TestingOrderData.fromJson(Map<String, dynamic> json) {
    return TestingOrderData(
      ReqNumber: json['reqnumber']?.toString() ?? '',
      PtsNumber: json['ptsnumber']?.toString() ?? '',
      Samplecatname: json['samplecatname']?.toString() ?? '',
      SampleNo: json['sampleno']?.toString() ?? '',
      SampleCategory: json['samplecategory']?.toString() ?? '',
      ServiceType: json['servicetype']?.toString() ?? '',
      ZonaCode: json['zonacode']?.toString() ?? '',
      ZonaName: json['zonaname']?.toString() ?? '',
      SubZonaCode: json['subzonacode']?.toString() ?? '',
      SubZonaName: json['subzonaname']?.toString() ?? '',
      Address: json['address']?.toString() ?? '',
      TsDate: json['tsdate']?.toString() ?? '',
      SamplingDate: json['samplingdate']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reqnumber': ReqNumber,
      'ptsnumber': PtsNumber,
      'sampleno': SampleNo,
      'samplecategory': SampleCategory,
      'samplecatname': Samplecatname,
      'servicetype': ServiceType,
      'zonacode': ZonaCode,
      'zonaname': ZonaName,
      'subzonacode': SubZonaCode,
      'subzonaname': SubZonaName,
      'address': Address,
      'samplingdate': SamplingDate,
      'tsdate': TsDate,
    };
  }
}
