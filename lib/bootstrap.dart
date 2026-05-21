import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/network/connectivity_service.dart';
import 'features/chat/data/chat_local_source.dart';

Future<ProviderContainer> bootstrap() async {
  await Hive.initFlutter();
  await Future.wait([
    Hive.openBox('settings'),
    Hive.openBox('chat_history'),
    Hive.openBox('sessions'),
    Hive.openBox('pending_messages'),
    Hive.openBox('cache'),
  ]);

  // T25 (Phase 3): run one-shot Hive schema migrations after all boxes
  // are opened but before any provider reads them.
  await ChatLocalSource.migrateIfNeeded(Hive.box('chat_history'));

  final container = ProviderContainer();

  final connectivityService = container.read(connectivityServiceProvider);
  await connectivityService.init();

  return container;
}
