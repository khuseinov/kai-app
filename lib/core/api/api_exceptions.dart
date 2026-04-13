sealed class KaiApiException implements Exception {
  final String message;
  const KaiApiException(this.message);

  @override
  String toString() => 'KaiApiException: $message';
}

class NetworkException extends KaiApiException {
  const NetworkException(super.message);
}

class TimeoutException extends KaiApiException {
  const TimeoutException(super.message);
}

class UnauthorizedException extends KaiApiException {
  const UnauthorizedException(super.message);
}

class ServerException extends KaiApiException {
  final int? statusCode;
  const ServerException(super.message, {this.statusCode});
}

class OfflineException extends KaiApiException {
  const OfflineException() : super('Device is offline');
}

class CacheException extends KaiApiException {
  const CacheException(super.message);
}

class UnknownException extends KaiApiException {
  const UnknownException(super.message);
}

class CircuitBreakerException extends KaiApiException {
  const CircuitBreakerException(super.message);
}

/// HTTP 429 — Rate limit exceeded.
/// [retryAfterSeconds] is parsed from the server's Retry-After header when available.
class RateLimitException extends KaiApiException {
  final int? retryAfterSeconds;
  const RateLimitException(super.message, {this.retryAfterSeconds});
}

/// HTTP 503 / 504 — Kai backend is temporarily down or overloaded.
class ServiceUnavailableException extends KaiApiException {
  const ServiceUnavailableException(super.message);
}
