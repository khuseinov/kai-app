import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'bootstrap.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = await bootstrap();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const KaiApp(),
    ),
  );
}
