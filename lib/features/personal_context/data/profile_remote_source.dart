import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/providers/settings_provider.dart';

class UserProfileItem {
  final String id;
  final String type;
  final String content;
  final String? sourceSession;
  final String? createdAt;
  final bool verifiedPreference;

  const UserProfileItem({
    required this.id,
    required this.type,
    required this.content,
    this.sourceSession,
    this.createdAt,
    required this.verifiedPreference,
  });

  factory UserProfileItem.fromJson(Map<String, dynamic> json) => UserProfileItem(
        id: json['id'] as String? ?? '',
        type: json['type'] as String? ?? '',
        content: json['content'] as String? ?? '',
        sourceSession: json['source_session'] as String?,
        createdAt: json['created_at'] as String?,
        verifiedPreference: json['verified_preference'] as bool? ?? false,
      );
}

abstract interface class ProfileRemoteSource {
  Future<List<UserProfileItem>> getProfiles(String userId, {String? typeFilter});
  Future<void> createProfile(String userId, String content, String type);
}

class DioProfileRemoteSource implements ProfileRemoteSource {
  final Dio _dio;
  final String _internalToken;

  DioProfileRemoteSource(this._dio, this._internalToken);

  @override
  Future<List<UserProfileItem>> getProfiles(String userId,
      {String? typeFilter}) async {
    final response = await _dio.get<List<dynamic>>(
      '/user/$userId/profiles',
      queryParameters: typeFilter != null ? {'type_filter': typeFilter} : null,
      options: Options(headers: {
        if (_internalToken.isNotEmpty) 'X-Internal-Token': _internalToken,
      }),
    );
    final data = response.data ?? [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(UserProfileItem.fromJson)
        .toList();
  }

  @override
  Future<void> createProfile(
      String userId, String content, String type) async {
    await _dio.post<dynamic>(
      '/user/$userId/profiles',
      data: {'content': content, 'type': type},
      options: Options(headers: {
        if (_internalToken.isNotEmpty) 'X-Internal-Token': _internalToken,
      }),
    );
  }
}

final profileRemoteSourceProvider = Provider<ProfileRemoteSource>((ref) {
  final apiKey = ref.watch(settingsProvider).apiKey ?? '';
  return DioProfileRemoteSource(ref.watch(dioProvider), apiKey);
});
