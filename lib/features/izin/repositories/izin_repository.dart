import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/errors/app_exception.dart';
import '../data/models/izin_history_model.dart';
import '../data/models/izin_result_model.dart';

class IzinRepository {
  final ApiClient _apiClient;

  IzinRepository(this._apiClient);
  Future<StoreIzinResult> submitIzin({
    required String uuidPengajuan,
    required String jenisIzin,
    required String tanggalMulai,
    required String tanggalSelesai,
    required String keterangan,
    File? lampiran,
  }) async {
    try {
      final Map<String, dynamic> dataMap = {
        'uuid_pengajuan': uuidPengajuan,
        'jenis_izin': jenisIzin,
        'tanggal_mulai': tanggalMulai,
        'tanggal_selesai': tanggalSelesai,
        'keterangan': keterangan,
      };

      final formData = FormData.fromMap(dataMap);

      if (lampiran != null) {
        formData.files.add(
          MapEntry(
            'lampiran',
            await MultipartFile.fromFile(
              lampiran.path,
              filename: lampiran.path.split('/').last,
            ),
          ),
        );
      }

      final response = await _apiClient.dio.post(
        '/pengajuan/izin',
        data: formData,
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const ServerException(
          'Format respons pengajuan izin tidak valid.',
        );
      }

      return StoreIzinResult.fromJson(data);
    } on DioException catch (e) {
      throw _apiClient.mapError(e);
    }
  }

  Future<List<IzinHistoryItem>> getIzinHistory() async {
    try {
      final response = await _apiClient.dio.get(
        '/pengajuan',

        queryParameters: {'jenis': 'izin', 'per_page': 100},
      );
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const ServerException('Format respons riwayat izin tidak valid.');
      }

      final List listData = data['data'] ?? [];
      return listData
          .map((item) => IzinHistoryItem.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _apiClient.mapError(e);
    }
  }
}
