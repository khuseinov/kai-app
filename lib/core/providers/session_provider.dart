import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/session_repository.dart';
import 'root.dart';

/// Async provider that fetches the full session list from [sessionRepositoryProvider].
final sessionListProvider = FutureProvider<List<ChatSession>>((ref) {
  return ref.watch(sessionRepositoryProvider).list();
});
