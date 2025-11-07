class ApiResponse<T> {
  final T? data;
  final String? error;
  final bool isLoading;

  ApiResponse._({this.data, this.error, this.isLoading = false});

  factory ApiResponse.success(T data) {
    return ApiResponse._(data: data);
  }

  factory ApiResponse.error(String errorMessage) {
    return ApiResponse._(error: errorMessage);
  }
  
  

  factory ApiResponse.loading() {
    return ApiResponse._(isLoading: true);
  }
}
