import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/network/interceptors/auth_interceptor.dart';

/// Drives requests through a REAL Dio pipeline against a stub adapter, so the
/// tests exercise the interceptor exactly as production does — no reaching into
/// protected handler internals.
///
/// Two things under test:
///  1. onRequest/onError must never hang. dio types them as `void Function(...)`
///     and calls them fire-and-forget, so an async throw out of the token
///     getter would leave the handler's completer uncompleted and the request
///     pending forever (connect/receive timeouts never arm). Driving a real
///     request means a hang shows up as a timeout the test fails on.
///  2. The header split: kai-auth JWT rides in X-Kai-Access-Token (identity),
///     the HF edge PAT rides in Authorization (front door). They must not
///     collide.
class _CapturingAdapter implements HttpClientAdapter {
  _CapturingAdapter(this.status);

  final int status;
  RequestOptions? last;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    last = options;
    return ResponseBody.fromString(
      '{}',
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Dio _dioWith(AuthInterceptor interceptor, _CapturingAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test.local'))
    ..httpClientAdapter = adapter;
  interceptor.attach(dio);
  dio.interceptors.add(interceptor);
  return dio;
}

void main() {
  group('AuthInterceptor never hangs the request', () {
    test('onRequest completes when the token getter throws', () async {
      final adapter = _CapturingAdapter(200);
      final dio = _dioWith(
        AuthInterceptor(getAccessToken: () async => throw Exception('boom')),
        adapter,
      );

      // If onRequest hung, this await would never return — the timeout turns
      // that into a test failure instead of an infinite pending future.
      final resp = await dio
          .get<dynamic>('/sessions')
          .timeout(const Duration(seconds: 3));

      expect(resp.statusCode, 200);
      // Treated as signed out: no identity header, no edge header.
      expect(adapter.last!.headers.containsKey('X-Kai-Access-Token'), isFalse);
      expect(adapter.last!.headers.containsKey('Authorization'), isFalse);
    });

    test('a good token goes out in X-Kai-Access-Token, not Authorization',
        () async {
      final adapter = _CapturingAdapter(200);
      final dio = _dioWith(
        AuthInterceptor(getAccessToken: () async => 'live-jwt'),
        adapter,
      );

      await dio.get<dynamic>('/sessions');

      expect(adapter.last!.headers['X-Kai-Access-Token'], 'live-jwt');
      expect(adapter.last!.headers.containsKey('Authorization'), isFalse);
    });

    test('hfToken rides Authorization for the edge, JWT rides its own header',
        () async {
      final adapter = _CapturingAdapter(200);
      final dio = _dioWith(
        AuthInterceptor(
          hfToken: 'hf-pat',
          getAccessToken: () async => 'live-jwt',
        ),
        adapter,
      );

      await dio.get<dynamic>('/sessions');

      // Edge PAT and identity token coexist without collision.
      expect(adapter.last!.headers['Authorization'], 'Bearer hf-pat');
      expect(adapter.last!.headers['X-Kai-Access-Token'], 'live-jwt');
    });

    test('hfToken still attaches when the getter throws (signed out)', () async {
      final adapter = _CapturingAdapter(200);
      final dio = _dioWith(
        AuthInterceptor(
          hfToken: 'hf-pat',
          getAccessToken: () async => throw Exception('boom'),
        ),
        adapter,
      );

      await dio.get<dynamic>('/sessions');

      expect(adapter.last!.headers['Authorization'], 'Bearer hf-pat');
      expect(adapter.last!.headers.containsKey('X-Kai-Access-Token'), isFalse);
    });

    test('onError completes (does not hang) when refresh throws on a 401',
        () async {
      final adapter = _CapturingAdapter(401);
      final dio = _dioWith(
        AuthInterceptor(getAccessToken: () async => throw Exception('boom')),
        adapter,
      );

      // The 401 must surface as a normal error, not stall forever.
      await expectLater(
        dio.get<dynamic>('/sessions').timeout(const Duration(seconds: 3)),
        throwsA(isA<DioException>()),
      );
    });
  });
}
