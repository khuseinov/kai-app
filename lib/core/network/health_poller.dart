import 'dart:async';
import 'package:dio/dio.dart';

/// Result of a single `GET /health` probe.
///
/// - [healthy]: HTTP 200, backend is reachable and reports OK.
/// - [degraded]: HTTP 5xx, backend is reachable but reporting failure.
/// - [unreachable]: timeout, network error, or DNS failure.
enum HealthState { healthy, degraded, unreachable }

/// Polls `GET /health` on the backend at a fixed [interval] (default 60s).
///
/// Backend `/health` is a public endpoint (no auth) that returns a
/// non-2xx code if Redis/Neo4j/Qdrant checks fail. See
/// services/kai-core/src/api/routes/health.py.
class HealthPoller {
  final Dio _dio;
  final Duration interval;
  Timer? _timer;
  final _controller = StreamController<HealthState>.broadcast();

  HealthPoller(this._dio, {this.interval = const Duration(seconds: 60)});

  Stream<HealthState> get stream => _controller.stream;

  void start() {
    _poll();
    _timer = Timer.periodic(interval, (_) => _poll());
  }

  Future<void> _poll() async {
    try {
      final res = await _dio.get<dynamic>(
        '/health',
        options: Options(
          receiveTimeout: const Duration(seconds: 5),
          // /health is public — do not let auth interceptors short-circuit.
          extra: const {'skipAuth': true},
        ),
      );
      final code = res.statusCode ?? 0;
      _controller.add(
        code >= 200 && code < 300 ? HealthState.healthy : HealthState.degraded,
      );
    } on DioException {
      _controller.add(HealthState.unreachable);
    } catch (_) {
      _controller.add(HealthState.unreachable);
    }
  }

  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}
