import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/connectivity_service.dart';

final isOnlineProvider = StreamProvider<bool>((ref) {
  return ref.watch(connectivityServiceProvider).onConnectivityChanged;
});
