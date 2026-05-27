import 'package:flutter/material.dart';

import 'features/boot/booting_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Show the splash immediately; BootingApp runs bootstrap() asynchronously
  // and swaps in KaiApp when the provider container is ready. This avoids
  // the blank-white frame between native cold-start splash and the first
  // app screen (HIGH gap from 2026-05-27 brand audit).
  runApp(const BootingApp());
}
