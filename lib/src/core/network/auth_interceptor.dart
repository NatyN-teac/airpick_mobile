import 'package:dio/dio.dart';
import '../session/app_session.dart';
import '../storage/token_storage.dart';

class AuthInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;

  static const _publicPaths = [
    '/users/register',
    '/users/login',
  ];

  AuthInterceptor(this._tokenStorage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final isPublic = _publicPaths.any((p) => options.path.contains(p));
    if (!isPublic) {
      final token = await _tokenStorage.getToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      final isPublic =
          _publicPaths.any((p) => err.requestOptions.path.contains(p));
      if (!isPublic) {
        // Clear stale token and signal the app to route to sign-in
        _tokenStorage.clear();
        AppSession.notifyUnauthorized();
      }
    }
    handler.next(err);
  }
}
