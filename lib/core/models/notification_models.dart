class NotificationHistoryModels {
  final bool status;
  final int code;
  final String message;
  final NotificationData? data;
  final String? error;

  NotificationHistoryModels({
    required this.status,
    required this.code,
    required this.message,
    this.data,
    this.error,
  });

  factory NotificationHistoryModels.fromJson(Map<String, dynamic> json) {
    return NotificationHistoryModels(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? "",
      data: json['data'] != null ? NotificationData.fromJson(json['data']) : null,
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "status": status,
      "code": code,
      "message": message,
      "data": data?.toJson(),
      "error": error,
    };
  }
}

class NotificationData {
  final List<NotificationItem> data;
  final Pagination? pagination;

  NotificationData({
    required this.data,
    this.pagination,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => NotificationItem.fromJson(e))
              .toList() ??
          [],
      pagination: json['pagination'] != null 
          ? Pagination.fromJson(json['pagination']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "data": data.map((e) => e.toJson()).toList(),
      "pagination": pagination?.toJson(),
    };
  }
}

class Pagination {
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;
  final int from;
  final int to;

  Pagination({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
    required this.from,
    required this.to,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['current_page'] ?? 0,
      perPage: json['per_page'] ?? 0,
      total: json['total'] ?? 0,
      lastPage: json['last_page'] ?? 0,
      from: json['from'] ?? 0,
      to: json['to'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "current_page": currentPage,
      "per_page": perPage,
      "total": total,
      "last_page": lastPage,
      "from": from,
      "to": to,
    };
  }
}

class NotificationItem {
  final int? id;
  final String? batchId;
  final String? zonacode;
  final String? subzonacode;
  final RequestData? requestData;
  final String? description;
  final String? title;
  final String? screen;
  final String? callbackUrl;
  final String? status;
  final String? statusMessage;
  final String? errorMessage;
  final String? errorTrace;
  final int? userCount;
  final int? successCount;
  final int? failureCount;
  final int? skippedCount;
  final String? startedAt;
  final String? completedAt;
  final String? createdAt;
  final String? updatedAt;

  NotificationItem({
    this.id,
    this.batchId,
    this.zonacode,
    this.subzonacode,
    this.requestData,
    this.description,
    this.title,
    this.screen,
    this.callbackUrl,
    this.status,
    this.statusMessage,
    this.errorMessage,
    this.errorTrace,
    this.userCount,
    this.successCount,
    this.failureCount,
    this.skippedCount,
    this.startedAt,
    this.completedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] is int ? json['id'] : (json['id'] != null ? int.tryParse(json['id'].toString()) : null),
      batchId: json['batch_id'],
      zonacode: json['zonacode'],
      subzonacode: json['subzonacode'],
      requestData: json['request_data'] != null 
          ? RequestData.fromJson(json['request_data']) 
          : null,
      description: json['description'],
      title: json['title'],
      screen: json['screen'],
      callbackUrl: json['callback_url'],
      status: json['status'],
      statusMessage: json['status_message'],
      errorMessage: json['error_message'],
      errorTrace: json['error_trace'],
      userCount: json['user_count'] is int ? json['user_count'] : (json['user_count'] != null ? int.tryParse(json['user_count'].toString()) : null),
      successCount: json['success_count'] is int ? json['success_count'] : (json['success_count'] != null ? int.tryParse(json['success_count'].toString()) : null),
      failureCount: json['failure_count'] is int ? json['failure_count'] : (json['failure_count'] != null ? int.tryParse(json['failure_count'].toString()) : null),
      skippedCount: json['skipped_count'] is int ? json['skipped_count'] : (json['skipped_count'] != null ? int.tryParse(json['skipped_count'].toString()) : null),
      startedAt: json['started_at'],
      completedAt: json['completed_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "batch_id": batchId,
      "zonacode": zonacode,
      "subzonacode": subzonacode,
      "request_data": requestData?.toJson(),
      "description": description,
      "title": title,
      "screen": screen,
      "callback_url": callbackUrl,
      "status": status,
      "status_message": statusMessage,
      "error_message": errorMessage,
      "error_trace": errorTrace,
      "user_count": userCount,
      "success_count": successCount,
      "failure_count": failureCount,
      "skipped_count": skippedCount,
      "started_at": startedAt,
      "completed_at": completedAt,
      "created_at": createdAt,
      "updated_at": updatedAt,
    };
  }
}

class RequestData {
  final List<dynamic>? attributes;
  final List<dynamic>? request;
  final List<dynamic>? query;
  final List<dynamic>? server;
  final List<dynamic>? files;
  final List<dynamic>? cookies;
  final List<dynamic>? headers;

  RequestData({
    this.attributes,
    this.request,
    this.query,
    this.server,
    this.files,
    this.cookies,
    this.headers,
  });

  factory RequestData.fromJson(Map<String, dynamic> json) {
    return RequestData(
      attributes: json['attributes'] as List<dynamic>?,
      request: json['request'] as List<dynamic>?,
      query: json['query'] as List<dynamic>?,
      server: json['server'] as List<dynamic>?,
      files: json['files'] as List<dynamic>?,
      cookies: json['cookies'] as List<dynamic>?,
      headers: json['headers'] as List<dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "attributes": attributes,
      "request": request,
      "query": query,
      "server": server,
      "files": files,
      "cookies": cookies,
      "headers": headers,
    };
  }
}
