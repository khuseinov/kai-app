import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';

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

  DioUserRemoteSource(this._dio);

  @override
  Future<void> deleteTrajectory(String userId) async {
    await _dio.delete<dynamic>('/user/$userId/trajectory');
  }
}

final userRemoteSourceProvider = Provider<UserRemoteSource>((ref) {
  return DioUserRemoteSource(ref.watch(dioProvider));
});
