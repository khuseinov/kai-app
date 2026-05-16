import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/providers/settings_provider.dart';

/// Abstract surface so tests can inject a fake without touching Dio.
abstract interface class UserRemoteSource {
  /// DELETE /user/{user_id}/trajectory — backend wipes Qdrant
  /// `user_profiles` + `user_episodes` + legacy `user_trajectory`.
  /// See services/kai-core/src/api/routes/user.py.
  /// Throws on non-2xx.
  Future<void> deleteTrajectory(String userId);
}

class DioUserRemoteSource implements UserRemoteSource {
  final Dio _dio;
  final String _internalToken;

  DioUserRemoteSource(this._dio, [this._internalToken = '']);

  @override
  Future<void> deleteTrajectory(String userId) async {
    await _dio.delete<dynamic>(
      '/user/$userId/trajectory',
      options: Options(headers: {
        if (_internalToken.isNotEmpty) 'X-Internal-Token': _internalToken,
      }),
    );
  }
}

final userRemoteSourceProvider = Provider<UserRemoteSource>((ref) {
  final apiKey = ref.watch(settingsProvider).apiKey ?? '';
  return DioUserRemoteSource(ref.watch(dioProvider), apiKey);
});
