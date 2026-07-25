/// Low-level exceptions thrown by datasources. Repositories catch these and
/// translate them into [Failure]s so nothing above the data layer needs to
/// know about Firebase-specific error types.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
}

class ServerException implements Exception {
  final String message;
  const ServerException(this.message);
}

class NotFoundException implements Exception {
  final String message;
  const NotFoundException(this.message);
}
