import 'package:ampere/core/config/env_config.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

/// Logging interceptor for Dio that only runs in development mode
/// Logs request and response details for debugging purposes
class LoggingInterceptor extends Interceptor {
  final Logger _logger;
  final bool _enabled;

  /// Creates a LoggingInterceptor
  LoggingInterceptor()  :  _logger =Logger(
          printer: PrettyPrinter(
            methodCount: 0,
            errorMethodCount: 8,
            lineLength: 120,
            colors: true,
            printEmojis: true,
            dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
          ),
        ),
        _enabled = !EnvConfig.isProduction;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!_enabled) {
      handler.next(options);
      return;
    }

    _logger.d(
      '┌─────────────────────────────────────────────────────────────',
    );
    _logger.d('│ REQUEST');
    _logger.d('├─────────────────────────────────────────────────────────────');
    _logger.d('│ ${options.method} ${options.uri}');
    
    if (options.headers.isNotEmpty) {
      _logger.d('│ Headers:');
      options.headers.forEach((key, value) {
        // Mask sensitive headers
        if (_isSensitiveHeader(key)) {
          _logger.d('│   $key: ***');
        } else {
          _logger.d('│   $key: $value');
        }
      });
    }

    if (options.queryParameters.isNotEmpty) {
      _logger.d('│ Query Parameters:');
      options.queryParameters.forEach((key, value) {
        _logger.d('│   $key: $value');
      });
    }

    if (options.data != null) {
      _logger.d('│ Body:');
      _logger.d('│   ${_formatData(options.data)}');
    }

    _logger.d(
      '└─────────────────────────────────────────────────────────────',
    );

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (!_enabled) {
      handler.next(response);
      return;
    }

    _logger.d(
      '┌─────────────────────────────────────────────────────────────',
    );
    _logger.d('│ RESPONSE');
    _logger.d('├─────────────────────────────────────────────────────────────');
    _logger.d('│ ${response.requestOptions.method} ${response.requestOptions.uri}');
    _logger.d('│ Status Code: ${response.statusCode} ${response.statusMessage ?? ''}');
    
    if (response.headers.map.isNotEmpty) {
      _logger.d('│ Headers:');
      response.headers.map.forEach((key, values) {
        _logger.d('│   $key: ${values.join(', ')}');
      });
    }

    if (response.data != null) {
      _logger.d('│ Body:');
      _logger.d('│   ${_formatData(response.data)}');
    }

    _logger.d(
      '└─────────────────────────────────────────────────────────────',
    );

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!_enabled) {
      handler.next(err);
      return;
    }

    _logger.e(
      '┌─────────────────────────────────────────────────────────────',
    );
    _logger.e('│ ERROR');
    _logger.e('├─────────────────────────────────────────────────────────────');
    _logger.e('│ ${err.requestOptions.method} ${err.requestOptions.uri}');
    _logger.e('│ Type: ${err.type}');
    
    if (err.response != null) {
      _logger.e('│ Status Code: ${err.response?.statusCode}');
      _logger.e('│ Status Message: ${err.response?.statusMessage ?? ''}');
      
      if (err.response?.data != null) {
        _logger.e('│ Error Body:');
        _logger.e('│   ${_formatData(err.response?.data)}');
      }
    } else {
      _logger.e('│ Message: ${err.message}');
    }

    _logger.e('│ Stack Trace:');
    _logger.e('│   ${err.stackTrace}');

    _logger.e(
      '└─────────────────────────────────────────────────────────────',
    );

    handler.next(err);
  }

  /// Formats data for logging
  String _formatData(dynamic data) {
    if (data == null) return 'null';
    
    if (data is Map || data is List) {
      try {
        // Try to format as JSON-like string
        return data.toString().replaceAll(', ', ',\n│     ');
      } catch (e) {
        return data.toString();
      }
    }
    
    return data.toString();
  }

  /// Checks if a header is sensitive and should be masked
  bool _isSensitiveHeader(String key) {
    final sensitiveHeaders = [
      'authorization',
      'auth',
      'token',
      'api-key',
      'api_key',
      'apikey',
      'x-api-key',
      'cookie',
      'set-cookie',
    ];
    
    return sensitiveHeaders.contains(key.toLowerCase());
  }
}

