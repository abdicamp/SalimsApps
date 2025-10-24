class SampleDetail {
  final String tsnumber;
  final String tranidx;
  final String periode;
  final String tsdate;
  String? samplename;
  final String sampleno;
  final String geoTag;
  final String address;
  final String weather;
  final String winddirection;
  final String temperatur;
  final String branchcode;
  final String samplecode;
  final String ptsnumber;
  final String usercreated;
  final String description;
  final List<TakingSampleParameter> takingSampleParameters;
  final List<TakingSampleCI> takingSampleCI;

  SampleDetail({
    required this.tsnumber,
    required this.tranidx,
    required this.periode,
    required this.tsdate,
    this.samplename,
    required this.sampleno,
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
    required this.takingSampleParameters,
    required this.takingSampleCI,
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
      address: json['address'] ?? '',
      weather: json['weather'] ?? '',
      winddirection: json['winddirection'] ?? '',
      temperatur: json['temperatur'] ?? '',
      branchcode: json['branchcode'] ?? '',
      samplecode: json['samplecode'] ?? '',
      ptsnumber: json['ptsnumber'] ?? '',
      usercreated: json['usercreated'] ?? '',
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
      'address': address,
      'weather': weather,
      'winddirection': winddirection,
      'temperatur': temperatur,
      'branchcode': branchcode,
      'samplecode': samplecode,
      'ptsnumber': ptsnumber,
      'usercreated': usercreated,
      'description': description,
      'taking_sample_parameters':
          takingSampleParameters.map((e) => e.toJson()).toList(),
      'taking_sample_ci': takingSampleCI.map((e) => e.toJson()).toList(),
    };
  }
}

class TakingSampleParameter {
  String? key;
  dynamic detailno;
  final String parcode;
  final String parname;
  final bool iscalibration;
  final String insituresult;
  final String description;


  TakingSampleParameter({
    this.key,
    this.detailno,
    required this.parcode,
    required this.parname,
    required this.iscalibration,
    required this.insituresult,
    required this.description,
  });

  factory TakingSampleParameter.fromJson(Map<String, dynamic> json) {
    return TakingSampleParameter(
      key: json['key'] ?? '',
      detailno: json['detailno'] ?? '',
      parcode: json['parcode'] ?? '',
      parname: json['parname'] ?? '',
      iscalibration: json['iscalibration'] ?? false,
      insituresult: json['insituresult'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'detailno': detailno,
      'parcode': parcode,
      'parname': parname,
      'iscalibration': iscalibration,
      'insituresult': insituresult,
      'description': description,
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
