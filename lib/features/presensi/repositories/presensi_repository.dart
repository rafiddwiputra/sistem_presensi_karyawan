
import 'dart:async';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../data/models/today_attendance_model.dart';

class PresensiRepository {
  final ApiClient _apiClient;

  PresensiRepository(this._apiClient);

  // 1. Mengambil data presensi hari ini
  Future<TodayAttendanceModel> getTodayAttendance() async {
    try {
      final response = await _apiClient.dio.get('/attendance/today');

      final data = response.data['data'];
      if (data is! Map<String, dynamic>) {
        throw const FormatException(
          'Format respons presensi hari ini tidak valid.',
        );
      }

      return TodayAttendanceModel.fromJson(data);
    } on DioException catch (e) {
      throw _apiClient.mapError(e);
    }
  }

  // 2. Mengecek apakah posisi saat ini berada dalam radius kantor
  Future<Map<String, dynamic>> checkLocation({
    required double latitude,
    required double longitude,
    required double accuracy,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/attendance/location-check',
        data: {
          'latitude': latitude,
          'longitude': longitude,
          'accuracy_m': accuracy,
        },
      );

      return {
        'message': response.data['message'],
        'data': response.data['data'],
      };
    } on DioException catch (e) {
      throw _apiClient.mapError(e);
    }
  }

  // 3. Mengirimkan data presensi (Masuk/Keluar)
  Future<Map<String, dynamic>> storeAttendance({
    required String uuidPresensi,
    required double latitude,
    required double longitude,
    required double accuracy,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/attendance',
        data: {
          'uuid_presensi': uuidPresensi,
          'latitude': latitude,
          'longitude': longitude,
          'accuracy_m': accuracy,
        },
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _apiClient.mapError(e);
    }
  }
}
