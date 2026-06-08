import 'dart:convert';

String? apiResponseMessage(Map<String, dynamic> response) {
  final top = response['message'];
  if (top is String && top.isNotEmpty) return top;
  final resultReason = response['resultReason'];
  if (resultReason is String && resultReason.isNotEmpty) return resultReason;
  final errors = response['errors'];
  if (errors is Map<String, dynamic>) {
    final msg = errors['message'];
    final code = errors['code'];
    if (msg is String && msg.isNotEmpty) {
      if (code is String && code.isNotEmpty) return '$code: $msg';
      return msg;
    }
  }
  if (errors is String && errors.isNotEmpty) return errors;
  return null;
}

/// Full response body for debug logs / error snackbars.
String formatApiResponseBody(Object? data) {
  if (data == null) return '(empty body)';
  if (data is Map || data is List) {
    try {
      return const JsonEncoder.withIndent('  ').convert(data);
    } catch (_) {
      return data.toString();
    }
  }
  return data.toString();
}

void logApi({
  required String tag,
  required String method,
  required String path,
  int? statusCode,
  Object? body,
  Object? error,
}) {
  final buffer = StringBuffer('[$tag] $method $path');
  if (statusCode != null) buffer.write(' → $statusCode');
  if (body != null) {
    buffer.writeln();
    buffer.write(formatApiResponseBody(body));
  }
  if (error != null) {
    buffer.writeln();
    buffer.write('error: $error');
  }
  // ignore: avoid_print
  print(buffer.toString());
}
