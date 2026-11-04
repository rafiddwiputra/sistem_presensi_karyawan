import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:sistem_presensi_karyawan/core/errors/app_exception.dart';
import 'package:sistem_presensi_karyawan/core/network/api_client.dart';
import 'package:sistem_presensi_karyawan/core/services/secure_storage_service.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final SecureStorageService _storageService;

  AuthRepository(this._apiClient, this._storageService);

  Future<String> _getDeviceName() async {
    final deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.model;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.name;
      }
    } catch (e) {
      return 'Unknown_Device';
    }
    return 'Unknown_Device';
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final deviceName = await _getDeviceName();

      final response = await _apiClient.dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
          'device_name': deviceName,
        },
      );

      final token = response.data['access_token'] as String?;
      if (token == null) {
        throw const ServerException('Token tidak ditemukan pada respons server.');
      }

      await _storageService.saveToken(token);
      return Map<String, dynamic>.from(response.data['user']);
    } on DioException catch (e) {
      throw _apiClient.mapError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.dio.post('/auth/logout');
    } on DioException catch (e) {
      if (kDebugMode) debugPrint('API Logout terputus, melanjutkan penghapusan lokal: ${e.message}');
    } finally {
      await _storageService.deleteToken();
      try {
        await _storageService.delete('USER_PROFIL_CACHE');
      } catch (_) {}
    }
  }
}