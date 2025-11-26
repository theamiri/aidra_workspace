import 'dart:convert';

import 'package:ampere/core/config/env_config.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

/// Logging interceptor for Dio that only runs in development mode.
class LoggingInterceptor extends Interceptor {
  final Logger _logger;
  final bool _enabled;

  LoggingInterceptor()
    : _logger = Logger(
        printer: PrettyPrinter(
          methodCount: 0,
          errorMethodCount: 5,
          lineLength: 120,
          colors: true,
          printEmojis: true,
          dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
        ),
      ),
      _enabled = !EnvConfig.isProduction;

  // ───────────────────────────
  // REQUEST
  // ───────────────────────────
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!_enabled) return handler.next(options);

    _section('REQUEST');
    _line('${options.method} ${options.uri}');

    _printHeaders(options.headers);
    _printMapSection('Query', options.queryParameters);
    _printBody(options.data);

    _endSection();
    handler.next(options);
  }

  // ───────────────────────────
  // RESPONSE
  // ───────────────────────────
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (!_enabled) return handler.next(response);

    _section('RESPONSE');
    _line('${response.requestOptions.method} ${response.requestOptions.uri}');
    _line('Status: ${response.statusCode} ${response.statusMessage ?? ''}');

    _printHeaders(response.headers.map);
    _printBody(response.data);

    _endSection();
    handler.next(response);
  }

  // ───────────────────────────
  // ERROR
  // ───────────────────────────
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!_enabled) return handler.next(err);

    _section('ERROR');
    _line('${err.requestOptions.method} ${err.requestOptions.uri}');
    _line('Type: ${err.type}');
    _line('Message: ${err.message}');

    if (err.response != null) {
      _line('Status: ${err.response?.statusCode}');
      if (err.response?.data != null) {
        _printBody(err.response?.data, label: 'Error Body');
      }
    }

    _line('Stack Trace:');
    _line(err.stackTrace.toString());

    _endSection();
    handler.next(err);
  }

  // ───────────────────────────
  // Helpers
  // ───────────────────────────

  void _section(String title) {
    _logger.d(
      '┌───────────────────────────────────────────────────────────────',
    );
    _logger.d('│ $title');
    _logger.d(
      '├───────────────────────────────────────────────────────────────',
    );
  }

  void _endSection() {
    _logger.d(
      '└───────────────────────────────────────────────────────────────',
    );
  }

  void _line(String text) {
    _logger.d('│ $text');
  }

  void _printHeaders(Map<String, dynamic> headers) {
    if (headers.isEmpty) return;
    _line('Headers:');

    headers.forEach((key, value) {
      final masked = _isSensitive(key) ? '***' : value;
      _line('  $key: $masked');
    });
  }

  void _printMapSection(String name, Map<String, dynamic> map) {
    if (map.isEmpty) return;
    _line('$name:');
    map.forEach((k, v) => _line('  $k: $v'));
  }

  void _printBody(dynamic data, {String label = 'Body'}) {
    if (data == null) return;
    _line('$label:');

    final formatted = _format(data);
    for (final line in formatted.split('\n')) {
      _line('  $line');
    }
  }

  /// Pretty prints JSON or falls back to `toString`.
  String _format(dynamic data) {
    try {
      if (data is String) {
        final decoded = json.decode(data);
        return const JsonEncoder.withIndent('  ').convert(decoded);
      }

      if (data is Map || data is List) {
        return const JsonEncoder.withIndent('  ').convert(data);
      }
    } catch (_) {
      // fall through to toString
    }

    return data.toString();
  }

  /// Masks sensitive keys (case-insensitive).
  bool _isSensitive(String key) {
    const sensitive = {
      'authorization',
      'token',
      'api-key',
      'apikey',
      'x-api-key',
      'cookie',
      'set-cookie',
    };
    return sensitive.contains(key.toLowerCase());
  }
}
