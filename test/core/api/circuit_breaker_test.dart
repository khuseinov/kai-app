import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/api/api_exceptions.dart';
import 'package:kai_app/core/api/circuit_breaker.dart';

void main() {
  group('CircuitBreaker', () {
    test('starts in closed state', () {
      final cb = CircuitBreaker();
      expect(cb.state, CircuitState.closed);
    });

    test('stays closed on success', () async {
      final cb = CircuitBreaker();
      await cb.execute(() => Future.value(42));
      expect(cb.state, CircuitState.closed);
    });

    test('transitions to open after reaching failure threshold', () async {
      final cb = CircuitBreaker(failureThreshold: 2);
      try {
        await cb.execute(() => Future.error(Exception('fail')));
      } catch (_) {}
      try {
        await cb.execute(() => Future.error(Exception('fail')));
      } catch (_) {}
      expect(cb.state, CircuitState.open);
    });

    test('fails fast when open', () async {
      final cb = CircuitBreaker(failureThreshold: 1);
      try {
        await cb.execute(() => Future.error(Exception('fail')));
      } catch (_) {}
      expect(
        () => cb.execute(() => Future.value(42)),
        throwsA(isA<CircuitBreakerException>()),
      );
    });

    test('transitions to halfOpen after reset timeout', () async {
      final cb = CircuitBreaker(
        failureThreshold: 1,
        resetTimeout: const Duration(milliseconds: 10),
      );
      try {
        await cb.execute(() => Future.error(Exception('fail')));
      } catch (_) {}
      expect(cb.state, CircuitState.open);

      await Future.delayed(const Duration(milliseconds: 20));
      expect(cb.state, CircuitState.halfOpen);
    });

    test('closes after success in halfOpen state', () async {
      final cb = CircuitBreaker(
        failureThreshold: 1,
        resetTimeout: const Duration(milliseconds: 10),
      );
      try {
        await cb.execute(() => Future.error(Exception('fail')));
      } catch (_) {}
      await Future.delayed(const Duration(milliseconds: 20));
      expect(cb.state, CircuitState.halfOpen);

      await cb.execute(() => Future.value('ok'));
      expect(cb.state, CircuitState.closed);
    });

    test('re-opens on failure in halfOpen state', () async {
      final cb = CircuitBreaker(
        failureThreshold: 1,
        resetTimeout: const Duration(milliseconds: 10),
      );
      try {
        await cb.execute(() => Future.error(Exception('fail')));
      } catch (_) {}
      await Future.delayed(const Duration(milliseconds: 20));
      expect(cb.state, CircuitState.halfOpen);

      try {
        await cb.execute(() => Future.error(Exception('fail')));
      } catch (_) {}
      expect(cb.state, CircuitState.open);
    });

    test('resets failure count on success', () async {
      final cb = CircuitBreaker(failureThreshold: 3);
      try {
        await cb.execute(() => Future.error(Exception('fail')));
      } catch (_) {}
      try {
        await cb.execute(() => Future.error(Exception('fail')));
      } catch (_) {}
      // success resets count
      await cb.execute(() => Future.value('ok'));
      // now need 3 more failures to open
      try {
        await cb.execute(() => Future.error(Exception('fail')));
      } catch (_) {}
      try {
        await cb.execute(() => Future.error(Exception('fail')));
      } catch (_) {}
      expect(cb.state, CircuitState.closed); // still closed, only 2 failures
    });
  });
}
