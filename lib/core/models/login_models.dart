class LoginResponse {
  int? retcode;
  bool? status;
  String? msg;
  String? message;
  String? accessToken;
  String? tokenType;
  String? tokenFCM;
  UserData? data;
  int? error;

  LoginResponse({
    this.retcode,
    this.status,
    this.msg,
    this.message,
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
      msg: json['msg'] ?? json['message'],
      message: json['message'] ?? json['msg'],
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
      "msg": msg ?? message,
      "message": message ?? msg,
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
  final int? id;
  final String? name;
  final String? email;
  final String? emailVerifiedAt;
  final String? pzn;
  final String? role;
  final String? profileImage;
  final int? status;
  final String? loginAt;
  final int? isLogin;
  final String? slug;
  final String? createdAt;
  final String? updatedAt;
  final String? phone;
  final UserDetail? detail;

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
    this.id,
    this.name,
    this.email,
    this.emailVerifiedAt,
    this.pzn,
    this.role,
    this.profileImage,
    this.status,
    this.loginAt,
    this.isLogin,
    this.slug,
    this.createdAt,
    this.updatedAt,
    this.phone,
    this.detail,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      branchcode: json['branchcode'] ?? "",
      username: json['username'] ?? json['usernam'] ?? "", // handle both username and usernam
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
      id: json['id'],
      name: json['name'],
      email: json['email'],
      emailVerifiedAt: json['email_verified_at'],
      pzn: json['pzn'],
      role: json['role'],
      profileImage: json['profile_image'],
      status: json['status'],
      loginAt: json['login_at'],
      isLogin: json['is_login'],
      slug: json['slug'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      phone: json['phone'],
      detail: json['detail'] != null ? UserDetail.fromJson(json['detail']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "branchcode": branchcode,
      "groupcode": groupcode,
      "usernam": username,
      "username": username,
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
      "id": id,
      "name": name,
      "email": email,
      "email_verified_at": emailVerifiedAt,
      "pzn": pzn,
      "role": role,
      "profile_image": profileImage,
      "status": status,
      "login_at": loginAt,
      "is_login": isLogin,
      "slug": slug,
      "created_at": createdAt,
      "updated_at": updatedAt,
      "phone": phone,
      "detail": detail?.toJson(),
    };
  }
}

class UserDetail {
  final String? username;
  final bool? islogin;
  final String? userip;
  final String? groupcode;
  final String? addauthority;
  final String? editauthority;
  final String? delauthority;
  final String? viewauthority;
  final String? branchauthority;
  final String? warehouseauthority;
  final String? departmentauthority;
  final String? samplinglocauthority;
  final String? buildingauthority;
  final String? zonaauthority;
  final bool? isadmin;
  final String? description;
  final String? branchcode;
  final bool? issuspend;
  final String? labourcode;
  final String? usercreated;
  final String? datecreated;
  final String? timecreated;
  final String? usermodified;
  final String? datemodified;
  final String? timemodified;
  final String? name;
  final String? password;
  final String? pzn;
  final int? status;
  final int? isLogin;
  final String? loginAt;
  final String? slug;
  final String? createdAt;
  final String? tokenFcm;
  final String? phone;
  final String? email;
  final String? profileImage;
  final String? emailVerifiedAt;
  final String? rememberToken;

  UserDetail({
    this.username,
    this.islogin,
    this.userip,
    this.groupcode,
    this.addauthority,
    this.editauthority,
    this.delauthority,
    this.viewauthority,
    this.branchauthority,
    this.warehouseauthority,
    this.departmentauthority,
    this.samplinglocauthority,
    this.buildingauthority,
    this.zonaauthority,
    this.isadmin,
    this.description,
    this.branchcode,
    this.issuspend,
    this.labourcode,
    this.usercreated,
    this.datecreated,
    this.timecreated,
    this.usermodified,
    this.datemodified,
    this.timemodified,
    this.name,
    this.password,
    this.pzn,
    this.status,
    this.isLogin,
    this.loginAt,
    this.slug,
    this.createdAt,
    this.tokenFcm,
    this.phone,
    this.email,
    this.profileImage,
    this.emailVerifiedAt,
    this.rememberToken,
  });

  factory UserDetail.fromJson(Map<String, dynamic> json) {
    return UserDetail(
      username: json['username'],
      islogin: json['islogin'],
      userip: json['userip'],
      groupcode: json['groupcode'],
      addauthority: json['addauthority'],
      editauthority: json['editauthority'],
      delauthority: json['delauthority'],
      viewauthority: json['viewauthority'],
      branchauthority: json['branchauthority'],
      warehouseauthority: json['warehouseauthority'],
      departmentauthority: json['departmentauthority'],
      samplinglocauthority: json['samplinglocauthority'],
      buildingauthority: json['buildingauthority'],
      zonaauthority: json['zonaauthority'],
      isadmin: json['isadmin'],
      description: json['description'],
      branchcode: json['branchcode'],
      issuspend: json['issuspend'],
      labourcode: json['labourcode'],
      usercreated: json['usercreated'],
      datecreated: json['datecreated'],
      timecreated: json['timecreated'],
      usermodified: json['usermodified'],
      datemodified: json['datemodified'],
      timemodified: json['timemodified'],
      name: json['name'],
      password: json['password'],
      pzn: json['pzn'],
      status: json['status'],
      isLogin: json['is_login'],
      loginAt: json['login_at'],
      slug: json['slug'],
      createdAt: json['created_at'],
      tokenFcm: json['token_fcm'],
      phone: json['phone'],
      email: json['email'],
      profileImage: json['profile_image'],
      emailVerifiedAt: json['email_verified_at'],
      rememberToken: json['remember_token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "username": username,
      "islogin": islogin,
      "userip": userip,
      "groupcode": groupcode,
      "addauthority": addauthority,
      "editauthority": editauthority,
      "delauthority": delauthority,
      "viewauthority": viewauthority,
      "branchauthority": branchauthority,
      "warehouseauthority": warehouseauthority,
      "departmentauthority": departmentauthority,
      "samplinglocauthority": samplinglocauthority,
      "buildingauthority": buildingauthority,
      "zonaauthority": zonaauthority,
      "isadmin": isadmin,
      "description": description,
      "branchcode": branchcode,
      "issuspend": issuspend,
      "labourcode": labourcode,
      "usercreated": usercreated,
      "datecreated": datecreated,
      "timecreated": timecreated,
      "usermodified": usermodified,
      "datemodified": datemodified,
      "timemodified": timemodified,
      "name": name,
      "password": password,
      "pzn": pzn,
      "status": status,
      "is_login": isLogin,
      "login_at": loginAt,
      "slug": slug,
      "created_at": createdAt,
      "token_fcm": tokenFcm,
      "phone": phone,
      "email": email,
      "profile_image": profileImage,
      "email_verified_at": emailVerifiedAt,
      "remember_token": rememberToken,
    };
  }
}
