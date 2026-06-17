import 'package:kai_app/core/providers/root.dart';
import 'package:kai_app/features/auth/domain/repositories/session_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_provider.g.dart';

/// Async provider that fetches the full session list from [sessionRepositoryProvider].
@riverpod
Future<List<ChatSession>> sessionList(SessionListRef ref) {
  return ref.watch(sessionRepositoryProvider).list();
}
