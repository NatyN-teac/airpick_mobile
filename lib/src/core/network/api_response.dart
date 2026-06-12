import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

final _apiLogger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 0,
    printEmojis: false,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);

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
  if (!kDebugMode) return;

  final buffer = StringBuffer('[$tag] $method $path');
  if (statusCode != null) buffer.write(' → $statusCode');
  if (body != null) {
    buffer.writeln();
    buffer.write(formatApiResponseBody(_redactApiLogData(body)));
  }
  if (error != null) {
    buffer.writeln();
    buffer.write('error: $error');
  }
  if (error == null) {
    _apiLogger.i(buffer.toString());
  } else {
    _apiLogger.e(buffer.toString(), error: error);
  }
}

Object? _redactApiLogData(Object? data) {
  if (data is Map) {
    return data.map((key, value) {
      final normalizedKey = key.toString().toLowerCase().replaceAll(
        RegExp(r'[_-]'),
        '',
      );
      return MapEntry(
        key,
        _sensitiveLogKeys.contains(normalizedKey)
            ? '[REDACTED]'
            : _redactApiLogData(value),
      );
    });
  }
  if (data is Iterable) {
    return data.map(_redactApiLogData).toList();
  }
  return data;
}

const _sensitiveLogKeys = {
  'authorization',
  'accesstoken',
  'firebasetoken',
  'idtoken',
  'password',
  'refreshtoken',
  'token',
};
