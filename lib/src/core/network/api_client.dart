import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../storage/token_storage.dart';
import 'auth_interceptor.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient(TokenStorage tokenStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // ngrok requires this header in dev to skip the browser warning
          'ngrok-skip-browser-warning': 'true',
        },
      ),
    )..interceptors.add(AuthInterceptor(tokenStorage));
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.post(path, data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Map<String, dynamic>> get(String path) async {
    try {
      final response = await _dio.get(path);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Map<String, dynamic>> patch(
    String path,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.patch(path, data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  // Returns nothing — used for 204 No Content responses.
  Future<void> delete(String path) async {
    try {
      await _dio.delete(path);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Exception _mapError(DioException e) {
    final statusCode = e.response?.statusCode;
    final message = e.response?.data?['message'] as String?;

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return Exception('Request timed out. Check your connection.');
    }

    return switch (statusCode) {
      400 => Exception(message ?? 'Invalid request.'),
      401 => Exception(message ?? 'Unauthorised. Please sign in again.'),
      403 => Exception(message ?? 'Access denied.'),
      404 => Exception(message ?? 'Resource not found.'),
      422 => Exception(message ?? 'Validation failed.'),
      500 => Exception(message ?? 'Server error. Please try again later.'),
      _ => Exception(message ?? e.message ?? 'Something went wrong.'),
    };
  }
}
