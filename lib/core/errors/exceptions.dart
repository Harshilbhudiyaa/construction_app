class AuthException implements Exception {
  final String message;
  AuthException([this.message = 'Unauthorized action. Contact administrator top-level.']);

  @override
  String toString() => 'AuthException: $message';
}
