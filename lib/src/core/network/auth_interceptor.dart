import 'package:dio/dio.dart';
import '../session/app_session.dart';
import '../session/session_expiry.dart';
import '../storage/token_storage.dart';
import '../utils/app_logger.dart';

class AuthInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;

  static const _publicPaths = ['/users/register', '/users/login'];

  AuthInterceptor(this._tokenStorage);

  bool _isPublic(RequestOptions options) =>
      _publicPaths.any((p) => options.path.contains(p));

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isPublic(options)) {
      final token = await _tokenStorage.getToken();
      // Logger().d(token);
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      } else {
        appLogger.w('[AuthInterceptor] No JWT for ${options.method} ${options.path}');
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!_isPublic(err.requestOptions) && isSessionExpiredResponse(err)) {
      await AppSession.expireSession(_tokenStorage);
    }
    handler.next(err);
  }
}
