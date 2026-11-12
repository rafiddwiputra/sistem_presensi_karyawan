import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/errors/app_exception.dart';
import '../data/models/cuti_model.dart';

class CutiRepository {
  final ApiClient _apiClient;

  CutiRepository(this._apiClient);

  Future<List<CutiModel>> getRiwayatCuti() async {
    try {
      final response = await _apiClient.dio.get('/pengajuan');
      final responseData = response.data;

      if (responseData['success'] == true) {
        final data = responseData['data'];
        List<dynamic> dataList = [];

        if (data is List) {
          dataList = data;
        } else if (data is Map) {
          dataList = [data];
        }

        return dataList
            .where((json) => json['jenis'] == 'cuti')
            .map((json) => CutiModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw const ServerException('Gagal memuat data riwayat cuti.');
      }
    } on DioException catch (e) {
      throw _apiClient.mapError(e);
    } catch (e) {
      throw ServerException('Terjadi kesalahan sistem/parsing: $e');
    }
  }

  Future<String> submitCuti({
    required String uuidPengajuan,
    required String jenisCuti,
    required DateTime tanggalMulai,
    required DateTime tanggalSelesai,
    required String keterangan,
  }) async {
    try {
      final String formattedMulai = DateFormat('yyyy-MM-dd').format(tanggalMulai);
      final String formattedSelesai = DateFormat('yyyy-MM-dd').format(tanggalSelesai);

      final response = await _apiClient.dio.post(
        '/pengajuan/cuti',
        data: {
          'uuid_pengajuan': uuidPengajuan,
          'jenis_cuti': jenisCuti,
          'tanggal_mulai': formattedMulai,
          'tanggal_selesai': formattedSelesai,
          'keterangan': keterangan,
        },
      );

      final responseData = response.data;
      if (responseData is! Map<String, dynamic>) {
        throw const ServerException('Format respons pengajuan cuti tidak valid.');
      }

      return responseData['message'] as String? ?? 'Pengajuan cuti berhasil dikirim.';
    } on DioException catch (e) {
      throw _apiClient.mapError(e);
    }
  }
}