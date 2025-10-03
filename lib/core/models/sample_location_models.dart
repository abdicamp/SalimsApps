class SampleLocationResponse {
  final bool status;
  final int code;
  final String message;
  final List<SampleLocation> data;
  final String? error;

  SampleLocationResponse({
    required this.status,
    required this.code,
    required this.message,
    required this.data,
    this.error,
  });

  factory SampleLocationResponse.fromJson(Map<String, dynamic> json) {
    return SampleLocationResponse(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => SampleLocation.fromJson(e))
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

class SampleLocation {
  final String locationcode;
  final String locationname;
  final String description;

  SampleLocation({
    required this.locationcode,
    required this.locationname,
    required this.description,
  });

  factory SampleLocation.fromJson(Map<String, dynamic> json) {
    return SampleLocation(
      locationcode: json['locationcode'] ?? '',
      locationname: json['locationname'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'locationcode': locationcode,
      'locationname': locationname,
      'description': description,
    };
  }
}
