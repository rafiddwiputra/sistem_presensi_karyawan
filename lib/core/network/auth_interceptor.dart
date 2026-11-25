import 'package:dio/dio.dart';

import '../services/secure_storage_service.dart';

/// Interceptor khusus untuk menyisipkan token dan menangani sesi tidak valid (401 / 403).
class AuthInterceptor extends Interceptor {
  final SecureStorageService _storageService;
  void Function(String reason)? onSessionExpired;

  DateTime? _lastExpiredTrigger;

  /// Endpoint yang tidak boleh disisipi token dan tidak boleh memicu auto-logout.
  static const _publicPaths = ['/auth/login', '/auth/register'];

  AuthInterceptor(this._storageService, {this.onSessionExpired});

  bool _isPublicPath(String path) {
    return _publicPaths.any((p) => path.contains(p));
  }

  @override
  void onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    if (!_isPublicPath(options.path)) {
      final token = await _storageService.getToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final isPublic = _isPublicPath(err.requestOptions.path);
    final statusCode = err.response?.statusCode;

    if (!isPublic && (statusCode == 401 || statusCode == 403)) {
      final existingToken = await _storageService.getToken();
      await _storageService.deleteToken();
      try {
        await _storageService.delete('USER_PROFIL_CACHE');
      } catch (_) {}

      if (existingToken != null && existingToken.isNotEmpty) {
        final now = DateTime.now();
        final canTrigger = _lastExpiredTrigger == null ||
            now.difference(_lastExpiredTrigger!) > const Duration(seconds: 3);

        if (canTrigger) {
          _lastExpiredTrigger = now;
          final reason = statusCode == 403
              ? 'Akun Anda telah dinonaktifkan oleh administrator.'
              : 'Sesi Anda telah berakhir. Silakan login kembali.';
          onSessionExpired?.call(reason);
        }
      }
    }

    handler.next(err);
  }
}