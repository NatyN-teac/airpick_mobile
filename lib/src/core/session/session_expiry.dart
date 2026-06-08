import 'package:dio/dio.dart';
import '../network/api_response.dart';

/// Detects responses that mean the JWT/session is no longer valid.
bool isSessionExpiredResponse(DioException err) {
  final status = err.response?.statusCode;
  if (status == 401) return true;
  if (status != 403) return false;

  final message = _responseMessage(err.response?.data);
  if (message == null || message.isEmpty) {
    // Empty 403 on an authenticated call — treat as expired session.
    return _hadAuthHeader(err);
  }

  if (_isBusinessPermissionError(message)) return false;

  if (_isAuthFailureMessage(message) || _isGenericAccessDenied(message)) {
    return true;
  }

  return false;
}

bool _hadAuthHeader(DioException err) {
  final auth = err.requestOptions.headers['Authorization'];
  return auth is String && auth.isNotEmpty;
}

String? _responseMessage(dynamic data) {
  if (data is Map<String, dynamic>) {
    return apiResponseMessage(data) ??
        data['resultReason']?.toString() ??
        data['error']?.toString();
  }
  if (data is String && data.trim().isNotEmpty) return data.trim();
  return null;
}

bool _isAuthFailureMessage(String message) {
  final lower = message.toLowerCase();
  const keys = [
    'token',
    'jwt',
    'expired',
    'unauthorized',
    'unauthenticated',
    'session',
    'authentication',
    'authenticate',
    'bearer',
    'sign in',
    'log in',
    'invalid credentials',
  ];
  return keys.any(lower.contains);
}

bool _isGenericAccessDenied(String message) {
  final lower = message.toLowerCase().trim();
  return lower == 'forbidden' ||
      lower == 'access denied' ||
      lower.startsWith('access denied (403)');
}

/// Real authorization rules (not stale JWT) — do not force logout.
bool _isBusinessPermissionError(String message) {
  final lower = message.toLowerCase();
  const keys = [
    'only the',
    'must be',
    'not allowed to',
    'cannot ',
    'owner',
    'permission denied',
    'wrong role',
    'proposal',
    'offer request',
    'carrier',
    'shipper',
    'sender',
  ];
  return keys.any(lower.contains);
}
