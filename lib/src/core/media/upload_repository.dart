import 'dart:io';

import 'package:dio/dio.dart';
import '../network/api_client.dart';

class UploadRepository {
  final ApiClient _client;

  UploadRepository(this._client);

  /// POST /api/v1/uploads — stores the file in a private bucket and returns an
  /// opaque object *reference* (not a directly loadable URL). Persist this
  /// reference (e.g. as a receiver's photoIdUrl); view it later by exchanging it
  /// for a short-lived signed URL through the owning resource.
  Future<String> uploadFile(File file) async {
    final name = file.path.split('/').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: name),
    });
    final response = await _client.postMultipart('/uploads', formData);
    final content = response['content'] ?? response['data'];
    if (content is String && content.isNotEmpty) return content;
    if (content is Map<String, dynamic>) {
      // New private-upload shape returns `reference`; keep legacy fallbacks.
      final ref = content['reference'] ??
          content['url'] ??
          content['fileUrl'] ??
          content['photoIdUrl'];
      if (ref is String && ref.isNotEmpty) return ref;
    }
    throw Exception('Upload succeeded but no reference was returned.');
  }
}
