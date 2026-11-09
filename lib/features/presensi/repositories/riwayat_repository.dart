import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:sistem_presensi_karyawan/core/network/api_client.dart';

import '../data/models/riwayat_model.dart';

class RiwayatRepository {
  final ApiClient _apiClient;

  RiwayatRepository(this._apiClient);

  Future<RiwayatResponse> getRiwayat(DateTime date) async {
    try {
      final monthParam = DateFormat('yyyy-MM').format(date);

      final response = await _apiClient.dio.get(
        '/attendance/history',
        queryParameters: {'month': monthParam},
      );

      final data = response.data['data'];
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Format respons riwayat tidak sesuai.');
      }

      return RiwayatResponse.fromJson(data);
    } on DioException catch (e) {
      throw _apiClient.mapError(e);
    }
  }
}
