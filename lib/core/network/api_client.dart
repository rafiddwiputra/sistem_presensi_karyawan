import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../errors/app_exception.dart';
import '../services/secure_storage_service.dart';
import 'auth_interceptor.dart';

class ApiClient {
  late final Dio dio;

  ApiClient(SecureStorageService storageService) {
    dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
        },
      ),
    );
    dio.interceptors.addAll([
      AuthInterceptor(storageService),

      if (kDebugMode) SanitizingLogInterceptor(),
    ]);
  }

  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://emphasis-dive-nano-medline.trycloudflare.com/api/v1/mobile',
  );

  AppException mapError(Object error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return const TimeoutAppException();
        case DioExceptionType.connectionError:
          return const NetworkException();
        case DioExceptionType.badResponse:
          return _mapResponseError(error.response);
        default:
          return UnknownException(error.message ?? 'Terjadi kesalahan jaringan.');
      }
    }
    return const UnknownException();
  }

  AppException _mapResponseError(Response? response) {
    final statusCode = response?.statusCode;
    final data = response?.data;

    if (statusCode == 401) {
      return const UnauthorizedException();
    }

    if (statusCode == 422 && data is Map) {
      final rawErrors = data['errors'];
      if (rawErrors is Map) {
        final errors = rawErrors.map<String, List<String>>(
              (key, value) => MapEntry(key.toString(), List<String>.from(value as List)),
        );
        final message = (data['message'] as String?) ?? 'Data tidak valid.';
        return ValidationException(errors, message);
      }

      final message = (data['message'] as String?) ?? 'Validasi gagal.';
      return ValidationException({}, message);
    }

    final message = (data is Map ? data['message'] as String? : null) ??
        'Terjadi kesalahan pada server.';
    return ServerException(message, statusCode: statusCode);
  }
}

class SanitizingLogInterceptor extends Interceptor {
  static const _sensitiveKeys = {'password', 'current_password', 'new_password', 'password_confirmation', 'token'};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      final sanitized = _sanitize(options.data);
      debugPrint('--> ${options.method} ${options.uri}');
      debugPrint('Body: $sanitized');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('<-- ${response.statusCode} ${response.requestOptions.uri}');
      debugPrint('Response: ${response.data}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('<-- ERROR ${err.response?.statusCode} ${err.requestOptions.uri}');
      debugPrint('Message: ${err.message}');
      if (err.response?.data != null) {
        debugPrint('Error Data: ${err.response?.data}');
      }
    }
    handler.next(err);
  }

  dynamic _sanitize(dynamic data) {
    if (data is FormData) {
      final fields = data.fields.map((e) {
        final isSensitive = _sensitiveKeys.contains(e.key.toLowerCase());
        return '${e.key}: ${isSensitive ? '***' : e.value}';
      }).join(', ');
      return '{$fields}';
    }
    if (data is Map) {
      return data.map((key, value) {
        final isSensitive = _sensitiveKeys.contains(key.toString().toLowerCase());
        return MapEntry(key, isSensitive ? '***' : value);
      });
    }
    return data;
  }
}