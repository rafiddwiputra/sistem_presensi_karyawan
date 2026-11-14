import 'dart:io';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/errors/app_exception.dart';
import '../data/models/reimbursement_model.dart';

class ReimbursementRepository {
  final ApiClient _apiClient;
  final Uuid _uuid = const Uuid();

  ReimbursementRepository(this._apiClient);

  // --- 1. MENGAMBIL RIWAYAT REIMBURSEMENT ---
  Future<List<ReimbursementModel>> getRiwayatReimbursement() async {
    try {
      final response = await _apiClient.dio.get(
        '/pengajuan',
        queryParameters: {'jenis': 'reimbursement'},
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

        // Ambil detail tiap item secara paralel jika endpoint list belum menyertakan 'detail'
        final futures = dataList.map((rawItem) async {
          final Map<String, dynamic> itemMap =
          Map<String, dynamic>.from(rawItem as Map);

          if (itemMap['detail'] == null && itemMap['id'] != null) {
            final int? id = itemMap['id'] is int
                ? itemMap['id'] as int
                : int.tryParse(itemMap['id'].toString());

            if (id != null && id > 0) {
              try {
                return await getDetailReimbursement(id);
              } catch (_) {
                // Fallback ke data summary jika detail gagal dimuat
                return ReimbursementModel.fromJson(itemMap);
              }
            }
          }

          return ReimbursementModel.fromJson(itemMap);
        });

        return await Future.wait(futures);
      } else {
        throw const ServerException('Gagal memuat data riwayat reimbursement.');
      }
    } on DioException catch (e) {
      throw _apiClient.mapError(e);
    } catch (e) {
      throw ServerException('Terjadi kesalahan sistem/parsing: $e');
    }
  }

  // --- 2. MENGAMBIL DETAIL REIMBURSEMENT ---
  Future<ReimbursementModel> getDetailReimbursement(int id) async {
    try {
      final response = await _apiClient.dio.get('/pengajuan/reimbursement/$id');
      final responseData = response.data;

      if (responseData['success'] == true) {
        return ReimbursementModel.fromJson(
          responseData['data'] as Map<String, dynamic>,
        );
      } else {
        throw const ServerException('Gagal memuat detail reimbursement.');
      }
    } on DioException catch (e) {
      throw _apiClient.mapError(e);
    } catch (e) {
      throw ServerException('Terjadi kesalahan parsing detail reimbursement: $e');
    }
  }

  // --- 3. MENGIRIM PENGAJUAN REIMBURSEMENT (DENGAN LAMPIRAN FILE) ---
  Future<String> submitReimbursement({
    required String tanggal,
    required String keperluan,
    required String nominal,
    required File lampiran,
  }) async {
    try {
      // Hilangkan titik/koma pada nominal (contoh: "350.000" jadi "350000")
      final String cleanNominal = nominal.replaceAll('.', '').replaceAll(',', '');
      final String generatedUuid = _uuid.v4();

      // Menyiapkan FormData untuk menangani file upload dan teks sekaligus
      FormData formData = FormData.fromMap({
        'uuid_pengajuan': generatedUuid,
        'tanggal_transaksi': tanggal,
        'keperluan_pengeluaran': keperluan,
        'nominal': cleanNominal,
        'lampiran': await MultipartFile.fromFile(
          lampiran.path,
          filename: lampiran.uri.pathSegments.last,
        ),
      });

      final response = await _apiClient.dio.post(
        '/pengajuan/reimbursement',
        data: formData,
      );

      final responseData = response.data;
      if (responseData is! Map<String, dynamic>) {
        throw const ServerException('Format respons pengajuan reimbursement tidak valid.');
      }

      return responseData['message'] as String? ??
          'Pengajuan reimbursement berhasil dikirim.';
    } on DioException catch (e) {
      throw _apiClient.mapError(e);
    } catch (e) {
      throw ServerException('Terjadi kesalahan saat mengunggah: $e');
    }
  }
}