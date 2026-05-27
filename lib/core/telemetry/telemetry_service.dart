/// Placeholder telemetry interface. Wire a real implementation before launch.
abstract class TelemetryService {
  void track(String event, {Map<String, dynamic>? properties});
  void identify(String userId, {Map<String, dynamic>? traits});
}

class NoOpTelemetryService implements TelemetryService {
  const NoOpTelemetryService();

  @override
  void track(String event, {Map<String, dynamic>? properties}) {}

  @override
  void identify(String userId, {Map<String, dynamic>? traits}) {}
}
