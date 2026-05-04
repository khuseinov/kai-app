import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/settings_provider.dart';
import '../data/user_remote_source.dart';

enum DeleteDataState { idle, deleting, success, error }

class DeleteDataNotifier extends StateNotifier<DeleteDataState> {
  final UserRemoteSource _remote;
  final String _userId;

  DeleteDataNotifier(this._remote, this._userId)
      : super(DeleteDataState.idle);

  Future<void> deleteAll() async {
    state = DeleteDataState.deleting;
    try {
      await _remote.deleteTrajectory(_userId);
      state = DeleteDataState.success;
    } catch (_) {
      state = DeleteDataState.error;
    }
  }

  void reset() => state = DeleteDataState.idle;
}

final deleteDataNotifierProvider =
    StateNotifierProvider.autoDispose<DeleteDataNotifier, DeleteDataState>(
  (ref) {
    final userId = ref.watch(settingsProvider.select((s) => s.userId));
    return DeleteDataNotifier(ref.watch(userRemoteSourceProvider), userId);
  },
);
