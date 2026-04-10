import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../storage/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorage _secureStorage;

  AuthInterceptor(this._secureStorage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final tokens = await _secureStorage.readTokens();
    if (tokens != null) {
      options.headers['Authorization'] = 'Bearer ${tokens.access}';
    } else {
      final apiKey = await _secureStorage.readApiKey();
      if (apiKey != null && apiKey.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $apiKey';
      }
    }
    handler.next(options);
  }
}

final authInterceptorProvider = Provider<AuthInterceptor>((ref) {
  return AuthInterceptor(ref.watch(secureStorageProvider));
});
