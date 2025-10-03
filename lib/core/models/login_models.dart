class LoginResponse {
  final int retcode;
  final bool status;
  final String msg;
  final String accessToken;
  final String tokenType;
  final UserData data;
  final int error;

  LoginResponse({
    required this.retcode,
    required this.status,
    required this.msg,
    required this.accessToken,
    required this.tokenType,
    required this.data,
    required this.error,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      retcode: json['retcode'],
      status: json['status'],
      msg: json['msg'],
      accessToken: json['access_token'],
      tokenType: json['token_type'],
      data: UserData.fromJson(json['data']),
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "retcode": retcode,
      "status": status,
      "msg": msg,
      "access_token": accessToken,
      "token_type": tokenType,
      "data": data.toJson(),
      "error": error,
    };
  }
}

class UserData {
  final String branchcode;
  final String username;
  final String? grouptran;
  final String? addauthority;
  final String? editauthority;
  final String? delauthority;
  final String? finauthority;
  final String? prnauthority;
  final String? prsauthority;
  final String? branchauthority;
  final String? warehouseauthority;
  final String? departmentauthority;
  final String? samplinglocauthority;
  final String? buildingauthority;
  final String? description;
  final int? islogin;
  final String? userip;
  final String? labourcode;
  final String? usercreated;
  final String? datecreated;
  final String? timecreated;
  final String? usermodified;
  final String? datemodified;
  final String? timemodified;

  UserData({
    required this.branchcode,
    required this.username,
    this.grouptran,
    this.addauthority,
    this.editauthority,
    this.delauthority,
    this.finauthority,
    this.prnauthority,
    this.prsauthority,
    this.branchauthority,
    this.warehouseauthority,
    this.departmentauthority,
    this.samplinglocauthority,
    this.buildingauthority,
    this.description,
    this.islogin,
    this.userip,
    this.labourcode,
    this.usercreated,
    this.datecreated,
    this.timecreated,
    this.usermodified,
    this.datemodified,
    this.timemodified,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      branchcode: json['branchcode'] ?? "",
      username: json['usernam'] ?? "", // key di responsenya memang "usernam"
      grouptran: json['grouptran'],
      addauthority: json['addauthority'],
      editauthority: json['editauthority'],
      delauthority: json['delauthority'],
      finauthority: json['finauthority'],
      prnauthority: json['prnauthority'],
      prsauthority: json['prsauthority'],
      branchauthority: json['branchauthority'],
      warehouseauthority: json['warehouseauthority'],
      departmentauthority: json['departmentauthority'],
      samplinglocauthority: json['samplinglocauthority'],
      buildingauthority: json['buildingauthority'],
      description: json['description'],
      islogin: json['islogin'],
      userip: json['userip'],
      labourcode: json['labourcode'],
      usercreated: json['usercreated'],
      datecreated: json['datecreated'],
      timecreated: json['timecreated'],
      usermodified: json['usermodified'],
      datemodified: json['datemodified'],
      timemodified: json['timemodified'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "branchcode": branchcode,
      "usernam": username,
      "grouptran": grouptran,
      "addauthority": addauthority,
      "editauthority": editauthority,
      "delauthority": delauthority,
      "finauthority": finauthority,
      "prnauthority": prnauthority,
      "prsauthority": prsauthority,
      "branchauthority": branchauthority,
      "warehouseauthority": warehouseauthority,
      "departmentauthority": departmentauthority,
      "samplinglocauthority": samplinglocauthority,
      "buildingauthority": buildingauthority,
      "description": description,
      "islogin": islogin,
      "userip": userip,
      "labourcode": labourcode,
      "usercreated": usercreated,
      "datecreated": datecreated,
      "timecreated": timecreated,
      "usermodified": usermodified,
      "datemodified": datemodified,
      "timemodified": timemodified,
    };
  }
}
