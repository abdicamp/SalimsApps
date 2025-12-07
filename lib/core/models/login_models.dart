class LoginResponse {
  int? retcode;
  bool? status;
  String? msg;
  String? accessToken;
  String? tokenType;
  String? tokenFCM;
  UserData? data;
  int? error;

  LoginResponse({
    this.retcode,
    this.status,
    this.msg,
    this.accessToken,
    this.tokenType,
    this.tokenFCM,
    this.data,
    this.error,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      retcode: json['retcode'],
      status: json['status'],
      msg: json['msg'],
      accessToken: json['access_token'],
      tokenFCM: json['token_fcm'],
      tokenType: json['token_type'],
      data: json['data'] != null ? UserData.fromJson(json['data']) : null,
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
      "token_fcm": tokenFCM,
      "data": data?.toJson(),
      "error": error,
    };
  }
}

class UserData {
  final String branchcode;
  final String username;
  final String? grouptran;
  final String? groupcode;
  final String? addauthority;
  final String? editauthority;
  final String? delauthority;
  final String? viewauthority;
  final String? finauthority;
  final String? prnauthority;
  final String? prsauthority;
  final String? branchauthority;
  final String? warehouseauthority;
  final String? departmentauthority;
  final String? samplinglocauthority;
  final String? buildingauthority;
  final String? zonaauthority;
  final String? description;
  final bool? islogin;
  final String? userip;
  final String? labourcode;
  final String? logincode;
  final String? usercreated;
  final String? datecreated;
  final String? timecreated;
  final String? usermodified;
  final String? datemodified;
  final String? timemodified;
  final bool? isadmin;
  final bool? issuspend;

  UserData({
    required this.branchcode,
    required this.username,
    this.grouptran,
    this.groupcode,
    this.addauthority,
    this.editauthority,
    this.delauthority,
    this.viewauthority,
    this.finauthority,
    this.prnauthority,
    this.prsauthority,
    this.branchauthority,
    this.warehouseauthority,
    this.departmentauthority,
    this.samplinglocauthority,
    this.buildingauthority,
    this.zonaauthority,
    this.description,
    this.islogin,
    this.userip,
    this.labourcode,
    this.logincode,
    this.usercreated,
    this.datecreated,
    this.timecreated,
    this.usermodified,
    this.datemodified,
    this.timemodified,
    this.isadmin,
    this.issuspend,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      branchcode: json['branchcode'] ?? "",
      username: json['usernam'] ?? "", // key di responsenya memang "usernam"
      grouptran: json['grouptran'],
      groupcode: json['groupcode'],
      addauthority: json['addauthority'],
      editauthority: json['editauthority'],
      delauthority: json['delauthority'],
      viewauthority: json['viewauthority'],
      finauthority: json['finauthority'],
      prnauthority: json['prnauthority'],
      prsauthority: json['prsauthority'],
      branchauthority: json['branchauthority'],
      warehouseauthority: json['warehouseauthority'],
      departmentauthority: json['departmentauthority'],
      samplinglocauthority: json['samplinglocauthority'],
      buildingauthority: json['buildingauthority'],
      zonaauthority: json['zonaauthority'],
      description: json['description'],
      islogin: json['islogin'],
      userip: json['userip'],
      labourcode: json['labourcode'],
      logincode: json['logincode'],
      usercreated: json['usercreated'],
      datecreated: json['datecreated'],
      timecreated: json['timecreated'],
      usermodified: json['usermodified'],
      datemodified: json['datemodified'],
      timemodified: json['timemodified'],
      isadmin: json['isadmin'],
      issuspend: json['issuspend'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "branchcode": branchcode,
      "groupcode": groupcode,
      "usernam": username,
      "grouptran": grouptran,
      "addauthority": addauthority,
      "editauthority": editauthority,
      "delauthority": delauthority,
      "viewauthority": viewauthority,
      "finauthority": finauthority,
      "prnauthority": prnauthority,
      "prsauthority": prsauthority,
      "branchauthority": branchauthority,
      "warehouseauthority": warehouseauthority,
      "departmentauthority": departmentauthority,
      "samplinglocauthority": samplinglocauthority,
      "buildingauthority": buildingauthority,
      "zonaauthority": zonaauthority,
      "description": description,
      "islogin": islogin,
      "userip": userip,
      "labourcode": labourcode,
      "logincode": logincode,
      "usercreated": usercreated,
      "datecreated": datecreated,
      "timecreated": timecreated,
      "usermodified": usermodified,
      "datemodified": datemodified,
      "timemodified": timemodified,
      "isadmin": isadmin,
      "issuspend": issuspend,
    };
  }
}
