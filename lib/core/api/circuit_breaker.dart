import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_exceptions.dart';

enum CircuitState { closed, open, halfOpen }

class CircuitBreaker {
  final int failureThreshold;
  final Duration resetTimeout;

  CircuitState _state = CircuitState.closed;
  int _failureCount = 0;
  DateTime? _lastFailureTime;

  CircuitBreaker({
    this.failureThreshold = 3,
    this.resetTimeout = const Duration(seconds: 30),
  });

  CircuitState get state {
    if (_state == CircuitState.open) {
      if (DateTime.now().difference(_lastFailureTime!) > resetTimeout) {
        _state = CircuitState.halfOpen;
      }
    }
    return _state;
  }

  Future<T> execute<T>(Future<T> Function() action) async {
    final currentState = state;

    if (currentState == CircuitState.open) {
      throw const CircuitBreakerException('Circuit breaker is OPEN. Failing fast to protect backend.');
    }

    try {
      final result = await action();
      _onSuccess();
      return result;
    } catch (e) {
      _onError();
      rethrow;
    }
  }

  void _onSuccess() {
    _failureCount = 0;
    _state = CircuitState.closed;
  }

  void _onError() {
    _failureCount++;
    _lastFailureTime = DateTime.now();
    if (_failureCount >= failureThreshold) {
      _state = CircuitState.open;
    }
  }
}

final circuitBreakerProvider = Provider<CircuitBreaker>((ref) {
  return CircuitBreaker(
    failureThreshold: 3,
    resetTimeout: const Duration(seconds: 30),
  );
});
