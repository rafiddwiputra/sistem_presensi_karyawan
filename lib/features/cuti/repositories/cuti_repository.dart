import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/errors/app_exception.dart';

class CutiRepository {
  final ApiClient _apiClient;

  CutiRepository(this._apiClient);

  Future<String> submitCuti({
    required String uuidPengajuan,
    required String jenisCuti,
    required String tanggalMulai,
    required String tanggalSelesai,
    required String keterangan,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/pengajuan/cuti',
        // Menggunakan JSON Body standar (bukan FormData) karena tidak ada lampiran
        data: {
          'uuid_pengajuan': uuidPengajuan,
          'jenis_cuti': jenisCuti,
          'tanggal_mulai': tanggalMulai,
          'tanggal_selesai': tanggalSelesai,
          'keterangan': keterangan,
        },
      );

      final responseData = response.data;
      if (responseData is! Map<String, dynamic>) {
        throw const ServerException('Format respons pengajuan cuti tidak valid.');
      }

      // Backend me-return 'success' => true beserta 'message' (baik data baru maupun duplikat)
      return responseData['message'] as String? ?? 'Pengajuan cuti berhasil dikirim.';
    } on DioException catch (e) {
      throw _apiClient.mapError(e);
    }
  }

// Catatan: Jika riwayat cuti membutuhkan model khusus,
// method getCutiHistory() dapat ditambahkan di sini secara konsisten.
}