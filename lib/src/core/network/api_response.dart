String? apiResponseMessage(Map<String, dynamic> response) {
  final top = response['message'];
  if (top is String && top.isNotEmpty) return top;
  final errors = response['errors'];
  if (errors is Map<String, dynamic>) {
    final msg = errors['message'];
    if (msg is String && msg.isNotEmpty) return msg;
  }
  return null;
}
