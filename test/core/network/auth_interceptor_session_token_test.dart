import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kai_app/core/network/interceptors/auth_interceptor.dart';
import 'package:kai_app/core/network/session_token_store.dart';

void main() {
  group('SessionTokenStore', () {
    test('saves non-empty tokens and ignores empty/null', () {
      final store = SessionTokenStore()
        ..save('s1', 'tok')
        ..save('s1', '') // ignored — keeps previous
        ..save('s2', null); // ignored
      expect(store.tokenFor('s1'), 'tok');
      expect(store.tokenFor('s2'), isNull);
    });
  });

  group('AuthInterceptor session token (SEC-2 / T-03)', () {
    test('captures X-Session-Token from /chat response, re-attaches on next request',
        () {
      final store = SessionTokenStore();
      final interceptor = AuthInterceptor(sessionTokenStore: store);

      // Backend returns the token on a /chat response bound to session s1.
      final chatResponse = Response<dynamic>(
        requestOptions: RequestOptions(path: '/chat', data: {'session_id': 's1'}),
        headers: Headers.fromMap({
          'x-session-token': ['tok-abc'],
        }),
      );
      interceptor.onResponse(chatResponse, ResponseInterceptorHandler());
      expect(store.tokenFor('s1'), 'tok-abc');

      // A later /chat request for s1 carries the token.
      final nextChat = RequestOptions(path: '/chat', data: {'session_id': 's1'});
      interceptor.onRequest(nextChat, RequestInterceptorHandler());
      expect(nextChat.headers['X-Session-Token'], 'tok-abc');

      // The history endpoint for s1 (path-derived session id) also carries it.
      final messages = RequestOptions(path: '/sessions/s1/messages');
      interceptor.onRequest(messages, RequestInterceptorHandler());
      expect(messages.headers['X-Session-Token'], 'tok-abc');
    });

    test('attaches nothing when no token has been issued for the session', () {
      final interceptor = AuthInterceptor(sessionTokenStore: SessionTokenStore());
      final req = RequestOptions(path: '/chat', data: {'session_id': 'unknown'});
      interceptor.onRequest(req, RequestInterceptorHandler());
      expect(req.headers.containsKey('X-Session-Token'), isFalse);
    });
  });
}
