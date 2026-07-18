import 'package:dio/dio.dart';
import 'api_response.dart';
import '../config/app_config.dart';
import '../storage/token_storage.dart';
import 'auth_interceptor.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient(TokenStorage tokenStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(minutes: 1),
        receiveTimeout: const Duration(minutes: 1),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // ngrok requires this header in dev to skip the browser warning
          'ngrok-skip-browser-warning': 'true',
        },
      ),
    );
    _dio.interceptors.addAll([
      AuthInterceptor(tokenStorage),
      InterceptorsWrapper(
        onResponse: (response, handler) {
          final request = response.requestOptions;
          if (_isAuthPath(request.path)) {
            logApi(
              tag: 'AuthApi',
              method: request.method,
              path: request.path,
              statusCode: response.statusCode,
              body: response.data,
            );
          }
          handler.next(response);
        },
      ),
    ]);
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

  // Used for endpoints that return 204 No Content (empty body).
  Future<void> postVoid(String path, {Map<String, dynamic>? data}) async {
    try {
      await _dio.post(path, data: data);
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

  // Used for endpoints that return 204 No Content.
  Future<void> patchVoid(String path, {Map<String, dynamic>? data}) async {
    try {
      await _dio.patch(path, data: data);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.put(path, data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Map<String, dynamic>> postMultipart(String path, FormData data) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        options: Options(contentType: 'multipart/form-data'),
      );
      final body = response.data;
      if (body is Map<String, dynamic>) return body;
      return {'success': true};
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
    final data = e.response?.data;
    final path = e.requestOptions.path;
    final method = e.requestOptions.method;

    logApi(
      tag: _isAuthPath(path) ? 'AuthApi' : 'ApiClient',
      method: method,
      path: path,
      statusCode: statusCode,
      body: data,
      error: e.message,
    );

    String? message;
    if (data is Map<String, dynamic>) {
      message = apiResponseMessage(data);
    }

    final bodyDetail = data != null ? '\n${formatApiResponseBody(data)}' : '';
    final detail = message != null ? '' : bodyDetail;

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return Exception('Request timed out. Check your connection.');
    }

    return switch (statusCode) {
      400 => Exception(message ?? 'Invalid request.$detail'),
      401 => Exception(message ?? 'Unauthorised. Please sign in again.$detail'),
      403 => Exception(message ?? 'Access denied (403).$detail'),
      404 => Exception(message ?? 'Resource not found.$detail'),
      422 => Exception(message ?? 'Validation failed.$detail'),
      500 => Exception(
        message ?? 'Server error. Please try again later.$detail',
      ),
      _ => Exception(message ?? e.message ?? 'Something went wrong.$detail'),
    };
  }

  bool _isAuthPath(String path) =>
      path.contains('/users/register') || path.contains('/users/login');
}
