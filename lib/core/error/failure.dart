sealed class Failure {
  const Failure([this.message = '']);
  final String message;
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network error']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Unauthorized']);
}

class StorageFailure extends Failure {
  const StorageFailure([super.message = 'Storage error']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Unknown error']);
}
