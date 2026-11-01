/// Error thrown by [ApiClient] for a failed request. Carries the backend's
/// `errors.errorCode` and `errors.details` so callers can branch on the code
/// instead of the human-readable message (which can change).
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;
  final Map<String, dynamic>? details;

  const ApiException(
    this.message, {
    this.statusCode,
    this.errorCode,
    this.details,
  });

  /// Reads `errors.errorCode` from an `ApiResponseDto` error body.
  static String? errorCodeFrom(Object? body) {
    if (body is! Map) return null;
    final errors = body['errors'];
    if (errors is! Map) return null;
    final code = errors['errorCode'];
    return code is String && code.isNotEmpty ? code : null;
  }

  /// Reads `errors.details` from an `ApiResponseDto` error body.
  static Map<String, dynamic>? detailsFrom(Object? body) {
    if (body is! Map) return null;
    final errors = body['errors'];
    if (errors is! Map) return null;
    final details = errors['details'];
    return details is Map ? Map<String, dynamic>.from(details) : null;
  }

  // Same text as a plain `Exception(message)` so existing
  // `toString().replaceFirst('Exception: ', '')` call sites keep working.
  @override
  String toString() => 'Exception: $message';
}
