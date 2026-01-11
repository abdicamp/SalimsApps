import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import '../../../core/models/sample_models.dart';

/// Service untuk menangani save dan post data
class SaveService {
  final Logger logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  /// Build SampleDetail data untuk POST
  SampleDetail buildSampleDetailData({
    required dynamic userData,
    required List<String> imageBase64List,
    required List<String> imageBase64ListVerify,
    required String description,
    required String? tsnumber,
    required String samplingdate,
    required String sampleName,
    required String sampleno,
    required String? latlang,
    required String? longitude,
    required String? latitude,
    required String? address,
    required String? weather,
    required String? winddirection,
    required String? temperatur,
    required String? sampleCode,
    required String? ptsnumber,
    required String? buildingcode,
    required List<TakingSampleParameter> takingSampleParameters,
    required List<TakingSampleCI> takingSampleCI,
    required List<String> photoOld,
    required List<String> photoOldVerifikasi,
  }) {
    return SampleDetail(
      description: description,
      tsnumber: tsnumber ?? '',
      tranidx: "1203",
      periode: DateFormat('yyyyMM').format(DateTime.parse(samplingdate)),
      tsdate: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      samplename: sampleName,
      sampleno: sampleno,
      geoTag: latlang ?? '',
      longtitude: longitude ?? '',
      latitude: latitude ?? '',
      address: address ?? '',
      weather: weather ?? '',
      winddirection: winddirection ?? '',
      temperatur: temperatur ?? '',
      branchcode: userData?.data?.branchcode ?? '',
      samplecode: sampleCode ?? '',
      ptsnumber: ptsnumber ?? '',
      usercreated: userData?.data?.username ?? '',
      samplingby: userData?.data?.username ?? '',
      buildingcode: buildingcode ?? '',
      takingSampleParameters: takingSampleParameters,
      takingSampleCI: takingSampleCI,
      photoOld: photoOld,
      uploadFotoSample: imageBase64List,
      photoOldVerifikasi: photoOldVerifikasi,
      uploadFotoVerifikasi: imageBase64ListVerify,
    );
  }
}

