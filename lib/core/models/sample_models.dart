class SampleDetail {
  final String tsnumber;
  final String tranidx;
  final String periode;
  final String tsdate;
  String? samplename;
  final String sampleno;
  final String geoTag;
  final String longtitude;
  final String latitude;
  final String address;
  final String weather;
  final String winddirection;
  final String temperatur;
  final String branchcode;
  final String samplecode;
  final String samplingby;
  final String ptsnumber;
  final String usercreated;
  final String description;
  final String buildingcode;
  final List<String>? uploadFotoSample; // ✅ Tambah ini
  final List<String>? uploadFotoVerifikasi; // ✅ Tambah ini
  final List<String>? photoOld;
  final List<String>? photoOldVerifikasi;
  final List<TakingSampleParameter> takingSampleParameters;
  final List<TakingSampleCI> takingSampleCI;

  SampleDetail({
    required this.tsnumber,
    required this.tranidx,
    required this.periode,
    required this.tsdate,
    this.samplename,
    required this.sampleno,
    required this.samplingby,
    required this.latitude,
    required this.longtitude,
    required this.geoTag,
    required this.address,
    required this.weather,
    required this.winddirection,
    required this.temperatur,
    required this.branchcode,
    required this.samplecode,
    required this.ptsnumber,
    required this.usercreated,
    required this.description,
    required this.buildingcode,
    required this.takingSampleParameters,
    required this.takingSampleCI,
    this.uploadFotoSample, // ✅ Tambah ini juga
    this.uploadFotoVerifikasi, // ✅ Tambah ini juga
    this.photoOld, // ✅ Tambah ini juga
    this.photoOldVerifikasi, // ✅ Tambah ini juga
  });

  factory SampleDetail.fromJson(Map<String, dynamic> json) {
    return SampleDetail(
      tsnumber: json['tsnumber'] ?? '',
      tranidx: json['tranidx'] ?? '',
      periode: json['periode'] ?? '',
      tsdate: json['tsdate'],
      samplename: json['samplename'] ?? '',
      sampleno: json['sampleno'] ?? '',
      geoTag: json['geotag'] ?? '',
      latitude: json['latitude'] ?? '',
      longtitude: json['longtitude'] ?? '',
      address: json['address'] ?? '',
      weather: json['weather'] ?? '',
      winddirection: json['winddirection'] ?? '',
      temperatur: json['temperatur'] ?? '',
      samplingby: json['samplingby'] ?? '',
      branchcode: json['branchcode'] ?? '',
      samplecode: json['samplecode'] ?? '',
      ptsnumber: json['ptsnumber'] ?? '',
      usercreated: json['usercreated'] ?? '',
      buildingcode: json['buildingcode'] ?? '',
      description: json['description'] ?? '',
      takingSampleParameters:
          (json['taking_sample_parameters'] as List<dynamic>?)
                  ?.map((e) => TakingSampleParameter.fromJson(e))
                  .toList() ??
              [],
      takingSampleCI: (json['taking_sample_ci'] as List<dynamic>?)
              ?.map((e) => TakingSampleCI.fromJson(e))
              .toList() ??
          [],
      uploadFotoSample: json['upload_foto_sample'] != null
          ? List<String>.from(json['upload_foto_sample'])
          : [], // ✅ Parsing URL list
      uploadFotoVerifikasi: json['upload_foto_verifikasi'] != null
          ? List<String>.from(json['upload_foto_verifikasi'])
          : [], // ✅ Parsing URL list
      photoOld: json['photo_old'] != null
          ? List<String>.from(json['photo_old'])
          : [], // ✅ Parsing URL list
      photoOldVerifikasi: json['photo_verifikasi_old'] != null
          ? List<String>.from(json['photo_verifikasi_old'])
          : [], // ✅ Parsing URL list
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tsnumber': tsnumber,
      'tranidx': tranidx,
      'periode': periode,
      'tsdate': tsdate,
      'samplename': samplename,
      'sampleno': sampleno,
      'geotag': geoTag,
      'latitude': latitude,
      'longtitude': longtitude,
      'address': address,
      'weather': weather,
      'winddirection': winddirection,
      'temperatur': temperatur,
      'branchcode': branchcode,
      'samplecode': samplecode,
      'samplingby': samplingby,
      'ptsnumber': ptsnumber,
      'usercreated': usercreated,
      'buildingcode': buildingcode,
      'description': description,
      'taking_sample_parameters':
          takingSampleParameters.map((e) => e.toJson()).toList(),
      'taking_sample_ci': takingSampleCI.map((e) => e.toJson()).toList(),
      "upload_foto_sample": uploadFotoSample, // ✅ pastikan ikut di toJson
      "upload_foto_verifikasi":
          uploadFotoVerifikasi, // ✅ pastikan ikut di toJson
      "photo_old": photoOld, // ✅ pastikan ikut di toJson
      "photo_verifikasi_old": photoOldVerifikasi, // ✅ pastikan ikut di toJson
    };
  }
}

class TakingSampleParameter {
  String? key;
  dynamic detailno;
  final String parcode;
  final String parname;
  final String equipmentcode;
  final String equipmentname;
  final String description;
  List<dynamic>? ls_t_ts_fo; // Menyimpan data formula

  TakingSampleParameter({
    this.key,
    this.detailno,
    required this.parcode,
    required this.parname,
    required this.equipmentcode,
    required this.equipmentname,
    required this.description,
    this.ls_t_ts_fo,
  });

  factory TakingSampleParameter.fromJson(Map<String, dynamic> json) {
    // Parse taking_sample_fo dari response API ke ls_t_ts_fo
    List<dynamic>? ls_t_ts_fo;
    if (json['taking_sample_fo'] != null && json['taking_sample_fo'] is List) {
      // Konversi dari format API ke format yang disimpan
      ls_t_ts_fo = (json['taking_sample_fo'] as List).map((formulaJson) {
        if (formulaJson is Map<String, dynamic>) {
          // Format sesuai dengan struktur yang disimpan
          final detailList = (formulaJson['detail'] as List<dynamic>?)
              ?.map((detailJson) {
                if (detailJson is Map<String, dynamic>) {
                  return {
                    "detailno": (detailJson['detailno'] is int 
                        ? detailJson['detailno'].toString() 
                        : detailJson['detailno']?.toString() ?? ""),
                    "formulacode": detailJson['formulacode']?.toString() ?? "",
                    "formulaversion": (detailJson['formulaversion'] is int 
                        ? detailJson['formulaversion'].toString() 
                        : detailJson['formulaversion']?.toString() ?? ""),
                    "parameter": detailJson['parameter']?.toString() ?? "",
                    "formula": detailJson['formula']?.toString() ?? "",
                    "parameterresult": detailJson['parameterresult']?.toString() ?? "",
                    "comparespec": (detailJson['comparespec'] is bool 
                        ? detailJson['comparespec'].toString() 
                        : detailJson['comparespec']?.toString() ?? ""),
                    "lspec": detailJson['lspec']?.toString() ?? "",
                    "uspec": detailJson['uspec']?.toString() ?? "",
                  };
                }
                return null;
              })
              .whereType<Map<String, dynamic>>()
              .toList() ?? [];
          
          return {
            "detailno": (formulaJson['detailno'] is int 
                ? formulaJson['detailno'].toString() 
                : formulaJson['detailno']?.toString() ?? ""),
            "formulacode": formulaJson['formulacode']?.toString() ?? "",
            "formulaversion": (formulaJson['formulaversion'] is int 
                ? formulaJson['formulaversion'].toString() 
                : formulaJson['formulaversion']?.toString() ?? ""),
            "formulalevel": (formulaJson['formulalevel'] is int 
                ? formulaJson['formulalevel'].toString() 
                : formulaJson['formulalevel']?.toString() ?? ""),
            "description": formulaJson['description']?.toString() ?? "",
            "detail": detailList,
          };
        }
        return null;
      }).whereType<Map<String, dynamic>>().toList();
    } else if (json['ls_t_ts_fo'] != null && json['ls_t_ts_fo'] is List) {
      // Fallback untuk format lama
      ls_t_ts_fo = json['ls_t_ts_fo'] as List<dynamic>;
    }
    
    return TakingSampleParameter(
      key: json['key'] ?? '',
      detailno: json['detailno'] ?? '',
      parcode: json['parcode'] ?? '',
      parname: json['parname'] ?? '',
      equipmentcode: json['equipmentcode'] ?? '',
      equipmentname: json['equipmentname'] ?? '',
      description: json['description'] ?? '',
      ls_t_ts_fo: ls_t_ts_fo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'detailno': detailno,
      'parcode': parcode,
      'parname': parname,
      'equipmentcode': equipmentcode,
      'equipmentname': equipmentname,
      'description': description,
      'ls_t_ts_fo': ls_t_ts_fo,
    };
  }
}

class TakingSampleCI {
  String? key;
  dynamic detailno;
  final String equipmentcode;
  final String equipmentname;
  final int conqty;
  final String conuom;
  final int volqty;
  final String voluom;
  final String description;

  TakingSampleCI({
    this.key,
    this.detailno,
    required this.equipmentcode,
    required this.equipmentname,
    required this.conqty,
    required this.conuom,
    required this.volqty,
    required this.voluom,
    required this.description,
  });

  factory TakingSampleCI.fromJson(Map<String, dynamic> json) {
    return TakingSampleCI(
      key: json['key'] ?? '',
      detailno: json['detailno'] ?? '',
      equipmentcode: json['equipmentcode'] ?? '',
      equipmentname: json['equipmentname'] ?? '',
      conqty: json['conqty'] ?? 0,
      conuom: json['conuom'] ?? '',
      volqty: json['volqty'] ?? 0,
      voluom: json['voluom'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'detailno': detailno,
      'equipmentcode': equipmentcode,
      'equipmentname': equipmentname,
      'conqty': conqty,
      'conuom': conuom,
      'volqty': volqty,
      'voluom': voluom,
      'description': description,
    };
  }
}
