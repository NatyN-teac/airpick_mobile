class AuthCancelledException implements Exception {
  final String providerName;
  const AuthCancelledException(this.providerName);
}

class AuthConfigurationException implements Exception {
  final String message;
  const AuthConfigurationException(this.message);

  @override
  String toString() => message;
}
