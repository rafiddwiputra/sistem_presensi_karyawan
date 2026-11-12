import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/errors/app_exception.dart';
import '../data/models/lembur_model.dart';

class LemburRepository {
  final ApiClient _apiClient;

  LemburRepository(this._apiClient);

  Future<List<LemburModel>> getRiwayatLembur() async {
    try {
      final response = await _apiClient.dio.get(
        '/pengajuan',
        queryParameters: {'jenis': 'lembur'},
      );
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
            .map((json) => LemburModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw const ServerException('Gagal memuat data riwayat lembur.');
      }
    } on DioException catch (e) {
      throw _apiClient.mapError(e);
    } catch (e) {
      throw ServerException('Terjadi kesalahan sistem/parsing: $e');
    }
  }

  // --- 2. MENGAMBIL DETAIL LEMBUR BERDASARKAN ID (Opsional jika dibutuhkan) ---
  Future<LemburModel> getDetailLembur(int id) async {
    try {
      final response = await _apiClient.dio.get('/pengajuan/lembur/$id');
      final responseData = response.data;

      if (responseData['success'] == true) {
        return LemburModel.fromJson(responseData['data'] as Map<String, dynamic>);
      } else {
        throw const ServerException('Gagal memuat detail lembur.');
      }
    } on DioException catch (e) {
      throw _apiClient.mapError(e);
    } catch (e) {
      throw ServerException('Terjadi kesalahan parsing detail lembur: $e');
    }
  }

  // --- 3. MENGIRIM PENGAJUAN LEMBUR ---
  Future<String> submitLembur({
    required String uuidPengajuan,
    required DateTime tanggalLembur,
    required TimeOfDay jamMulai,
    required TimeOfDay jamSelesai,
    required String alasanLembur,
  }) async {
    try {
      final String formattedTanggal = DateFormat('yyyy-MM-dd').format(tanggalLembur);
      final String formattedMulai = '${jamMulai.hour.toString().padLeft(2, '0')}:${jamMulai.minute.toString().padLeft(2, '0')}';
      final String formattedSelesai = '${jamSelesai.hour.toString().padLeft(2, '0')}:${jamSelesai.minute.toString().padLeft(2, '0')}';

      final response = await _apiClient.dio.post(
        '/pengajuan/lembur',
        data: {
          'uuid_pengajuan': uuidPengajuan,
          'tanggal_lembur': formattedTanggal,
          'jam_mulai': formattedMulai,
          'jam_selesai': formattedSelesai,
          'alasan_lembur': alasanLembur,
        },
      );

      final responseData = response.data;
      if (responseData is! Map<String, dynamic>) {
        throw const ServerException('Format respons pengajuan lembur tidak valid.');
      }

      return responseData['message'] as String? ?? 'Pengajuan lembur berhasil dikirim.';
    } on DioException catch (e) {
      throw _apiClient.mapError(e);
    }
  }
}