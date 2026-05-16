import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/local_storage.dart';

class FavouritesNotifier extends StateNotifier<List<String>> {
  final LocalStorage? _storage;

  FavouritesNotifier(LocalStorage storage)
      : _storage = storage,
        super(storage.countryFavourites);

  // For widget tests — no Hive required.
  FavouritesNotifier.inMemory([super.state = const []])
      : _storage = null;

  bool isFavourite(String iso2) => state.contains(iso2);

  void toggle(String iso2) {
    final updated = List<String>.from(state);
    if (updated.contains(iso2)) {
      updated.remove(iso2);
    } else {
      updated.add(iso2);
    }
    _storage?.countryFavourites = updated;
    state = updated;
  }
}

final favouritesProvider =
    StateNotifierProvider<FavouritesNotifier, List<String>>((ref) {
  return FavouritesNotifier(ref.watch(localStorageProvider));
});
