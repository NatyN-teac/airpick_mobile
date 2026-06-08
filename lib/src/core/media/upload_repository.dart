import 'dart:io';

import 'package:dio/dio.dart';
import '../network/api_client.dart';

class UploadRepository {
  final ApiClient _client;

  UploadRepository(this._client);

  /// POST /api/v1/uploads — returns a public URL for the uploaded file.
  Future<String> uploadFile(File file) async {
    final name = file.path.split('/').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: name),
    });
    final response = await _client.postMultipart('/uploads', formData);
    final content = response['content'] ?? response['data'];
    if (content is String && content.isNotEmpty) return content;
    if (content is Map<String, dynamic>) {
      final url = content['url'] ?? content['fileUrl'] ?? content['photoIdUrl'];
      if (url is String && url.isNotEmpty) return url;
    }
    throw Exception('Upload succeeded but no URL was returned.');
  }
}
