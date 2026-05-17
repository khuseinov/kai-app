import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/settings_provider.dart';
import '../data/profile_remote_source.dart';

class PersonalContextState {
  final List<UserProfileItem> items;
  final bool isLoading;
  final String? error;
  final bool isSaving;
  final bool savedSuccess;
  final bool memoryEnabled;

  const PersonalContextState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.isSaving = false,
    this.savedSuccess = false,
    this.memoryEnabled = true,
  });

  PersonalContextState copyWith({
    List<UserProfileItem>? items,
    bool? isLoading,
    String? error,
    bool? isSaving,
    bool? savedSuccess,
    bool? memoryEnabled,
  }) =>
      PersonalContextState(
        items: items ?? this.items,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        isSaving: isSaving ?? this.isSaving,
        savedSuccess: savedSuccess ?? this.savedSuccess,
        memoryEnabled: memoryEnabled ?? this.memoryEnabled,
      );
}

class PersonalContextNotifier
    extends StateNotifier<PersonalContextState> {
  final ProfileRemoteSource _remote;
  final String _userId;

  PersonalContextNotifier(this._remote, this._userId)
      : super(const PersonalContextState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final items = await _remote.getProfiles(_userId);
      state = state.copyWith(isLoading: false, items: items);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Не удалось загрузить данные',
      );
    }
  }

  Future<void> addInstruction(String content) async {
    if (content.trim().isEmpty) return;
    state = state.copyWith(isSaving: true, savedSuccess: false, error: null);
    try {
      await _remote.createProfile(_userId, content.trim(), 'instruction');
      await load();
      state = state.copyWith(isSaving: false, savedSuccess: true);
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: 'Не удалось сохранить инструкцию',
      );
    }
  }

  Future<void> deleteItem(String itemId) async {
    state = state.copyWith(error: null);
    try {
      await _remote.deleteProfile(_userId, itemId);
      state = state.copyWith(
        items: state.items.where((i) => i.id != itemId).toList(),
      );
    } catch (_) {
      state = state.copyWith(error: 'Не удалось удалить');
    }
  }

  Future<void> updateItem(String itemId, String newContent) async {
    if (newContent.trim().isEmpty) return;
    state = state.copyWith(error: null);
    try {
      await _remote.updateProfile(_userId, itemId, newContent.trim());
      state = state.copyWith(
        items: state.items.map((i) {
          if (i.id == itemId) {
            return UserProfileItem(
              id: i.id,
              type: i.type,
              content: newContent.trim(),
              sourceSession: i.sourceSession,
              createdAt: i.createdAt,
              verifiedPreference: i.verifiedPreference,
            );
          }
          return i;
        }).toList(),
      );
    } catch (_) {
      state = state.copyWith(error: 'Не удалось обновить');
    }
  }

  Future<void> setMemoryEnabled(bool value) async {
    final prev = state.memoryEnabled;
    state = state.copyWith(memoryEnabled: value);
    try {
      await _remote.setMemoryEnabled(_userId, value);
    } catch (_) {
      state = state.copyWith(
        memoryEnabled: prev,
        error: 'Не удалось изменить настройку',
      );
    }
  }
}

final personalContextNotifierProvider = StateNotifierProvider.autoDispose<
    PersonalContextNotifier, PersonalContextState>((ref) {
  final userId = ref.watch(settingsProvider.select((s) => s.userId));
  return PersonalContextNotifier(ref.watch(profileRemoteSourceProvider), userId);
});
