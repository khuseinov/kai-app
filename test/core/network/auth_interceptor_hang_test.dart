import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/network/interceptors/auth_interceptor.dart';

/// Dio types onRequest/onError as `void Function(...)` and calls them
/// fire-and-forget (`cb(options, handler); return handler.future;`). The
/// returned future — and any error in it — is discarded, while `handler.future`
/// is backed by a Completer that only ever completes via next/resolve/reject.
///
/// So an async throw out of these callbacks is not merely an unhandled error:
/// the request never completes. No timeout rescues it either — connect/receive
/// timeouts live inside _dispatchRequest, which is never reached. The symptom
/// is a spinner that hangs forever with no error, e.g. every parallel call at
/// launch after the 30-day refresh token has expired.
///
/// These tests assert the handler is always driven to completion.
void main() {
  group('AuthInterceptor never hangs the request', () {
    test('onRequest completes even when the token getter throws', () async {
      final interceptor = AuthInterceptor(
        getAccessToken: () async => throw Exception('refresh failed'),
      );

      final options = RequestOptions(path: '/sessions');
      final handler = RequestInterceptorHandler();
      final settled = _watch(handler.future);

      await interceptor.onRequest(options, handler);
      await Future<void>.delayed(Duration.zero);

      expect(settled.value, isTrue, reason: 'handler.next was never called');
      // Treated as signed out: no bearer, so the server answers 401 — a normal,
      // visible error instead of a silent stall.
      expect(options.headers.containsKey('Authorization'), isFalse);
    });

    test('onRequest still attaches a good token (control)', () async {
      final interceptor = AuthInterceptor(
        getAccessToken: () async => 'live-token',
      );

      final options = RequestOptions(path: '/sessions');
      await interceptor.onRequest(options, RequestInterceptorHandler());

      expect(options.headers['Authorization'], 'Bearer live-token');
    });

    test('onRequest falls back to hfToken when the getter throws', () async {
      final interceptor = AuthInterceptor(
        hfToken: 'hf-pat',
        getAccessToken: () async => throw Exception('boom'),
      );

      final options = RequestOptions(path: '/sessions');
      await interceptor.onRequest(options, RequestInterceptorHandler());

      expect(options.headers['Authorization'], 'Bearer hf-pat');
    });

    test('onError completes when the refresh throws on a 401', () async {
      final dio = Dio();
      final interceptor = AuthInterceptor(
        getAccessToken: () async => throw Exception('refresh failed'),
      )..attach(dio);

      final requestOptions = RequestOptions(path: '/sessions');
      final err = DioException(
        requestOptions: requestOptions,
        response: Response<dynamic>(
          requestOptions: requestOptions,
          statusCode: 401,
        ),
      );

      final handler = ErrorInterceptorHandler();
      final settled = _watch(handler.future);

      await interceptor.onError(err, handler);
      await Future<void>.delayed(Duration.zero);

      expect(settled.value, isTrue, reason: 'the original 401 must still surface');
    });
  });
}

/// Flips to true once [future] settles, either way. These handler futures
/// complete with an error by design (that IS the 401 being propagated) — the
/// bug under test is them never completing at all, so both outcomes count.
_Flag _watch(Future<dynamic> future) {
  final flag = _Flag();
  future.then(
    (_) => flag.value = true,
    onError: (Object _) => flag.value = true,
  );
  return flag;
}

class _Flag {
  bool value = false;
}
