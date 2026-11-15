import 'package:dio/dio.dart';
import 'package:sistem_presensi_karyawan/core/network/api_client.dart';

import '../data/models/notifikasi_model.dart';

class NotifikasiRepository {
  final ApiClient _apiClient;

  NotifikasiRepository(this._apiClient);

  Future<NotifikasiListResponse> getNotifications({
    String? kategori,
    bool unreadOnly = false,
    String? cursor,
    int perPage = 20,
  }) async {
    try {
      final queryParams = <String, Object>{
        'per_page': perPage,
        if (kategori != null && kategori.isNotEmpty) 'kategori': kategori,
        if (unreadOnly) 'unread': 1,
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      };

      final response = await _apiClient.dio.get(
        '/notifications',
        queryParameters: queryParams,
      );

      final body = response.data;
      if (body is! Map<String, dynamic>) {
        throw const FormatException('Format respons notifikasi tidak sesuai.');
      }

      return NotifikasiListResponse.fromJson(body);
    } on DioException catch (e) {
      throw _apiClient.mapError(e);
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await _apiClient.dio.get('/notifications/unread-count');
      final data = response.data['data'];
      if (data is Map<String, dynamic>) {
        return (data['unread_count'] as num?)?.toInt() ?? 0;
      }
      return 0;
    } on DioException catch (e) {
      throw _apiClient.mapError(e);
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _apiClient.dio.patch('/notifications/$id/read');
    } on DioException catch (e) {
      throw _apiClient.mapError(e);
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _apiClient.dio.post('/notifications/read-all');
    } on DioException catch (e) {
      throw _apiClient.mapError(e);
    }
  }

  Future<void> registerDeviceToken({
    required String token,
    required String platform,
    String? deviceName,
  }) async {
    try {
      await _apiClient.dio.put(
        '/device-tokens',
        data: <String, Object>{
          'token': token,
          'platform': platform,
          if (deviceName != null && deviceName.isNotEmpty)
            'device_name': deviceName,
        },
      );
    } on DioException catch (e) {
      throw _apiClient.mapError(e);
    }
  }

  Future<void> deleteDeviceToken({required String token}) async {
    try {
      await _apiClient.dio.delete(
        '/device-tokens',
        data: <String, Object>{'token': token},
      );
    } on DioException catch (e) {
      throw _apiClient.mapError(e);
    }
  }
}