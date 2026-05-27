import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

/// Logs request / response with a per-request correlation ID + duration.
///
/// Active in debug builds only (kReleaseMode == false).
class LoggingInterceptor extends Interceptor {
  LoggingInterceptor({Logger? logger, Uuid? uuid})
      : _logger = logger ?? Logger(printer: SimplePrinter(printTime: true)),
        _uuid = uuid ?? const Uuid();

  static const String _correlationKey = 'x-correlation-id';
  static const String _startKey = 'x-request-start-ms';

  final Logger _logger;
  final Uuid _uuid;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    if (!kReleaseMode) {
      final cid = _uuid.v4();
      options.extra[_correlationKey] = cid;
      options.extra[_startKey] = DateTime.now().millisecondsSinceEpoch;
      _logger.d('-> ${options.method} ${options.path} [cid=$cid]');
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (!kReleaseMode) {
      final cid = response.requestOptions.extra[_correlationKey] ?? '-';
      final start = response.requestOptions.extra[_startKey] as int?;
      final ms = start == null
          ? '-'
          : '${DateTime.now().millisecondsSinceEpoch - start}ms';
      _logger.d(
        '<- ${response.statusCode} ${response.requestOptions.path} '
        '[cid=$cid] ($ms)',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!kReleaseMode) {
      final cid = err.requestOptions.extra[_correlationKey] ?? '-';
      _logger.w(
        'xx ${err.type} ${err.requestOptions.path} '
        '[cid=$cid] ${err.message ?? ''}',
      );
    }
    handler.next(err);
  }
}
