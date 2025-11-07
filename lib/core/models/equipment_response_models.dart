class EquipmentResponse {
  final bool status;
  final int code;
  final String message;
  final List<Equipment> data;
  final String? error;

  EquipmentResponse({
    required this.status,
    required this.code,
    required this.message,
    required this.data,
    this.error,
  });

  factory EquipmentResponse.fromJson(Map<String, dynamic> json) {
    return EquipmentResponse(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => Equipment.fromJson(e))
              .toList() ??
          [],
      error: json['error'],
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

class Equipment {
  final String branchcode;
  final String equipmentcode;
  final String equipmentname;
  final String type;
  final String serialnumber;
  final String duedatecalibration;
  final String dateofuse;
  final String dateofavailable;
  final int version;
  final bool isqctools;

  Equipment({
    required this.branchcode,
    required this.equipmentcode,
    required this.equipmentname,
    required this.type,
    required this.serialnumber,
    required this.duedatecalibration,
    required this.dateofuse,
    required this.dateofavailable,
    required this.version,
    required this.isqctools,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      branchcode: json['branchcode'] ?? '',
      equipmentcode: json['equipmentcode'] ?? '',
      equipmentname: json['equipmentname'] ?? '',
      type: json['type'] ?? '',
      serialnumber: json['serialnumber'] ?? '',
      duedatecalibration: json['duedatecalibration'] ?? '',
      dateofuse: json['dateofuse'] ?? '',
      dateofavailable: json['dateofavailable'] ?? '',
      version: json['version'] ?? 0,
      isqctools: json['isqctools'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'branchcode': branchcode,
      'equipmentcode': equipmentcode,
      'equipmentname': equipmentname,
      'type': type,
      'serialnumber': serialnumber,
      'duedatecalibration': duedatecalibration,
      'dateofuse': dateofuse,
      'dateofavailable': dateofavailable,
      'version': version,
      'isqctools': isqctools,
    };
  }
}
