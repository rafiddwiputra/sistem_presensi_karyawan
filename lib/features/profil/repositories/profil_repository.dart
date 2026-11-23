import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sistem_presensi_karyawan/core/network/api_client.dart';
import 'package:sistem_presensi_karyawan/core/services/secure_storage_service.dart';

class ProfilRepository {
  final ApiClient _apiClient;
  final SecureStorageService _storageService;

  static const String _profilCacheKey = 'USER_PROFIL_CACHE';

  ProfilRepository(this._apiClient, this._storageService);

  Future<dynamic> getProfilLocal() async {
    try {
      final jsonString = await _storageService.read(_profilCacheKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        return jsonDecode(jsonString);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Gagal membaca cache profil: $e');
    }
    return null;
  }

  Future<void> saveProfilLocal(dynamic data) async {
    try {
      dynamic payload = data;
      if (data is Map) {
        final existing = await getProfilLocal();
        if (existing is Map) {
          payload = <String, dynamic>{
            ...Map<String, dynamic>.from(existing),
            ...Map<String, dynamic>.from(data),
          };
        }
      }
      final jsonString = jsonEncode(payload);
      await _storageService.write(_profilCacheKey, jsonString);
    } catch (e) {
      if (kDebugMode) debugPrint('Gagal menyimpan cache profil: $e');
    }
  }

  Future<void> clearProfilLocal() async {
    try {
      await _storageService.delete(_profilCacheKey);
    } catch (e) {
      if (kDebugMode) debugPrint('Gagal menghapus cache profil: $e');
    }
  }

  Future<dynamic> getProfil() async {
    try {
      final response = await _apiClient.dio.get('/me');

      dynamic userData;
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('user')) {
          userData = responseData['user'];
        } else if (responseData.containsKey('data')) {
          userData = responseData['data'];
        } else {
          userData = responseData;
        }
      }

      if (userData is Map<String, dynamic>) {
        await saveProfilLocal(userData);
      }

      return userData;
    } on DioException catch (e) {
      throw _apiClient.mapError(e);
    }
  }

  Future<dynamic> updateProfil({
    required String nama,
    required String email,
    required String noHp,
    required String alamat,
    File? image,
  }) async {
    try {
      final Map<String, dynamic> dataMap = {
        "nama": nama,
        "email": email,
        "no_hp": noHp,
        "alamat": alamat,
        "_method": "PATCH",
      };

      final FormData formData = FormData.fromMap(dataMap);
      final response = await _apiClient.dio.post('/me', data: formData);

      if (response.data != null && response.data is Map<String, dynamic>) {
        final updatedData =
            response.data['user'] ?? response.data['data'] ?? response.data;
        if (updatedData is Map<String, dynamic>) {
          await saveProfilLocal(updatedData);
        }
      }

      if (image != null) {
        final String fileName = image.path.split('/').last;
        final FormData photoFormData = FormData.fromMap({
          "foto": await MultipartFile.fromFile(image.path, filename: fileName),
        });

        final photoResponse = await _apiClient.dio.post(
          '/me/photo',
          data: photoFormData,
        );

        if (photoResponse.data != null &&
            photoResponse.data is Map<String, dynamic>) {
          final updatedPhotoData = photoResponse.data['user'] ??
              photoResponse.data['data'] ??
              photoResponse.data;
          if (updatedPhotoData is Map<String, dynamic>) {
            await saveProfilLocal(updatedPhotoData);
            return updatedPhotoData;
          }
        }
      }

      return response.data;
    } on DioException catch (e) {
      throw _apiClient.mapError(e);
    }
  }

  Future<void> ubahPassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      await _apiClient.dio.put(
        '/me/password',
        data: {
          'current_password': currentPassword,
          'password': newPassword,
          'password_confirmation': newPasswordConfirmation,
        },
      );
    } on DioException catch (e) {
      throw _apiClient.mapError(e);
    }
  }
}