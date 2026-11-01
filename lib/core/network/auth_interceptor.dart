import 'package:dio/dio.dart';
import '../services/secure_storage_service.dart';

/// Interceptor khusus untuk menyisipkan token dan menangani token kadaluarsa.
class AuthInterceptor extends Interceptor {
  final SecureStorageService _storageService;

  /// Endpoint yang tidak boleh disisipi token dan tidak boleh memicu auto-logout.
  static const _publicPaths = ['/auth/login', '/auth/register'];

  AuthInterceptor(this._storageService);

  bool _isPublicPath(String path) {
    return _publicPaths.any((p) => path.contains(p));
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
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

    if (err.response?.statusCode == 401 && !isPublic) {
      await _storageService.deleteToken();
    }
    handler.next(err);
  }
}