/// Representasi error yang sudah diseragamkan dari seluruh lapisan network.
/// UI cukup menangani satu tipe ini, tidak perlu tahu soal DioException.
sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Koneksi Server Terputus']);
}

class TimeoutAppException extends AppException {
  const TimeoutAppException([super.message = 'Koneksi ke server lambat']);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Sesi kamu telah berakhir.']);
}

class ValidationException extends AppException {
  final Map<String, List<String>> errors;
  const ValidationException(this.errors, [super.message = 'Data yang dikirim tidak valid.']);
}

class ServerException extends AppException {
  final int? statusCode;
  const ServerException(super.message, {this.statusCode});
}

class UnknownException extends AppException {
  const UnknownException([super.message = 'Terjadi kesalahan yang tidak diketahui.']);
}