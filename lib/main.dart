import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Pre-register adapters before opening boxes
  await Hive.openBox('settings');
  await Hive.openBox('chat_history');

  runApp(const ProviderScope(child: KaiApp()));
}
