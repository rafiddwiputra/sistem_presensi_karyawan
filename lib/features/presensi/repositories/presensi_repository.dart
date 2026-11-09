import 'dart:async';

import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/errors/app_exception.dart';
import '../data/models/today_attendance_model.dart';

class LocationCheckResult {
  final bool isDalamRadius;
  final int jarakMeter;
  const LocationCheckResult({
    required this.isDalamRadius,
    required this.jarakMeter,
  });

  factory LocationCheckResult.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const LocationCheckResult(isDalamRadius: false, jarakMeter: 0);
    }
    return LocationCheckResult(
      isDalamRadius: json['di_dalam_radius'] as bool? ?? false,
      jarakMeter: (json['jarak_meter'] as num?)?.toInt() ?? 0,
    );
  }
}

class StoreAttendanceResult {
  final String message;
  final Map<String, dynamic> data;
  const StoreAttendanceResult({required this.message, required this.data});

  factory StoreAttendanceResult.fromJson(Map<String, dynamic> json) {
    return StoreAttendanceResult(
      message: json['message'] as String? ?? 'Presensi berhasil dicatat.',
      data: json['data'] as Map<String, dynamic>? ?? {},
    );
  }
}

class PresensiRepository {
  final ApiClient _apiClient;

  PresensiRepository(this._apiClient);

  Future<TodayAttendanceModel> getTodayAttendance() async {
    try {
      final response = await _apiClient.dio.get('/attendance/today');
      final data = response.data['data'];

      if (data is! Map<String, dynamic>) {
        throw const ServerException(
          'Format respons presensi hari ini tidak valid.',
        );
      }

      return TodayAttendanceModel.fromJson(data);
    } on DioException catch (e) {
      throw _apiClient.mapError(e);
    }
  }

  Future<LocationCheckResult> checkLocation({
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

      return LocationCheckResult.fromJson(
        response.data['data'] as Map<String, dynamic>?,
      );
    } on DioException catch (e) {
      throw _apiClient.mapError(e);
    }
  }

  Future<StoreAttendanceResult> storeAttendance({
    required String uuidPresensi,
    required String jenisPresensi,
    required double latitude,
    required double longitude,
    required double accuracy,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/attendance',
        data: {
          'uuid_presensi': uuidPresensi,
          'jenis_presensi': jenisPresensi,
          'latitude': latitude,
          'longitude': longitude,
          'accuracy_m': accuracy,
        },
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const ServerException('Format respons presensi tidak valid.');
      }

      return StoreAttendanceResult.fromJson(data);
    } on DioException catch (e) {
      throw _apiClient.mapError(e);
    }
  }
}