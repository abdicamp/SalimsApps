class UnitResponse {
  final bool status;
  final int code;
  final String message;
  final List<Unit> data;
  final String? error;

  UnitResponse({
    required this.status,
    required this.code,
    required this.message,
    required this.data,
    this.error,
  });

  factory UnitResponse.fromJson(Map<String, dynamic> json) {
    return UnitResponse(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => Unit.fromJson(e))
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

class Unit {
  final String code;
  final String name;

  Unit({required this.code, required this.name});

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(code: json['code'] ?? '', name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'code': code, 'name': name};
  }
}
