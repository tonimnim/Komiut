/// Generic API response wrapper.
///
/// Provides a consistent structure for handling API responses
/// including success data, errors, and metadata.
library;

/// Wrapper class for API responses.
///
/// Provides a unified interface for handling both successful responses
/// and error responses from the API.
class ApiResponse<T> {
  /// Creates a successful response.
  const ApiResponse.success({
    required this.data,
    this.message,
    this.statusCode = 200,
  })  : isSuccess = true,
        error = null;

  /// Creates an error response.
  const ApiResponse.error({
    required this.error,
    this.statusCode,
    this.message,
  })  : isSuccess = false,
        data = null;

  /// Whether the request was successful.
  final bool isSuccess;

  /// The response data (null if error).
  final T? data;

  /// Error information (null if success).
  final ApiError? error;

  /// Optional message from the server.
  final String? message;

  /// HTTP status code.
  final int? statusCode;

  /// Whether the response has data.
  bool get hasData => data != null;

  /// Whether the response has an error.
  bool get hasError => error != null;

  /// Maps the response data to a different type.
  ApiResponse<R> map<R>(R Function(T data) mapper) {
    if (isSuccess && data != null) {
      return ApiResponse.success(
        data: mapper(data as T),
        message: message,
        statusCode: statusCode ?? 200,
      );
    }
    return ApiResponse.error(
      error: error,
      statusCode: statusCode,
      message: message,
    );
  }

  /// Executes a callback based on the response state.
  R when<R>({
    required R Function(T data) success,
    required R Function(ApiError error) failure,
  }) {
    if (isSuccess && data != null) {
      return success(data as T);
    }
    return failure(error ?? const ApiError(message: 'Unknown error'));
  }

  /// Converts the response to a string for debugging.
  @override
  String toString() {
    if (isSuccess) {
      return 'ApiResponse.success(data: $data, message: $message)';
    }
    return 'ApiResponse.error(error: $error, statusCode: $statusCode)';
  }
}

/// Represents an API error.
class ApiError {
  /// Creates an API error.
  const ApiError({
    required this.message,
    this.code,
    this.details,
  });

  /// Creates an API error from a JSON map.
  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      message: json['message'] as String? ?? 'Unknown error',
      code: json['code'] as String?,
      details: json['details'] as Map<String, dynamic>?,
    );
  }

  /// The error message.
  final String message;

  /// Optional error code.
  final String? code;

  /// Additional error details.
  final Map<String, dynamic>? details;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
        'message': message,
        if (code != null) 'code': code,
        if (details != null) 'details': details,
      };

  @override
  String toString() => 'ApiError(message: $message, code: $code)';
}

/// Paginated response wrapper.
class PaginatedResponse<T> {
  /// Creates a paginated response.
  const PaginatedResponse({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
  });

  /// Creates from JSON with a mapper function for items.
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final items = (json['items'] as List<dynamic>?)
            ?.map((e) => fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return PaginatedResponse(
      items: items,
      totalCount: json['totalCount'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 20,
    );
  }

  /// The list of items.
  final List<T> items;

  /// Total count of items across all pages.
  final int totalCount;

  /// Current page number.
  final int page;

  /// Number of items per page.
  final int pageSize;

  /// Total number of pages.
  int get totalPages => (totalCount / pageSize).ceil();

  /// Whether there are more pages.
  bool get hasMore => page < totalPages;

  /// Whether this is the first page.
  bool get isFirstPage => page == 1;

  /// Whether this is the last page.
  bool get isLastPage => page >= totalPages;
}
