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
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    dio.interceptors.addAll([
      AuthInterceptor(storageService),
      if (kDebugMode) _loggingInterceptor,
    ]);
  }

  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://illustrated-cole-manufacture-ordinance.trycloudflare.com/api/v1/mobile',
  );

  Interceptor get _loggingInterceptor => LogInterceptor(
    requestBody: true,
    responseBody: true,
    error: true,
    logPrint: (obj) => debugPrint(obj.toString()),
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
    }

    final message = (data is Map ? data['message'] as String? : null) ??
        'Terjadi kesalahan pada server.';
    return ServerException(message, statusCode: statusCode);
  }
}