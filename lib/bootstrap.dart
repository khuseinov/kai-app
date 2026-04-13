import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/network/connectivity_service.dart';

Future<ProviderContainer> bootstrap() async {
  await Hive.initFlutter();
  await Future.wait([
    Hive.openBox('settings'),
    Hive.openBox('chat_history'),
    Hive.openBox('sessions'),
    Hive.openBox('pending_messages'),
    Hive.openBox('cache'),
  ]);

  final container = ProviderContainer();

  final connectivityService = container.read(connectivityServiceProvider);
  await connectivityService.init();

  return container;
}
