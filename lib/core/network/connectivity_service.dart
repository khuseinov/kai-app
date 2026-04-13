import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectivityService {
  final Connectivity _connectivity;
  bool _isOnline = true;

  ConnectivityService(this._connectivity) {
    _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      _isOnline = !results.contains(ConnectivityResult.none);
    });
  }

  bool get isOnline => _isOnline;

  Stream<bool> get onConnectivityChanged => _connectivity.onConnectivityChanged
      .map((results) => !results.contains(ConnectivityResult.none));

  Future<void> init() async {
    final results = await _connectivity.checkConnectivity();
    _isOnline = !results.contains(ConnectivityResult.none);
  }
}

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService(Connectivity());
});
