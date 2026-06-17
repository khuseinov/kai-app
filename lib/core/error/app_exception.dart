sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Unauthorized']);
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Network unavailable']);
}

class ServerException extends AppException {
  const ServerException([super.message = 'Server error']);
}
