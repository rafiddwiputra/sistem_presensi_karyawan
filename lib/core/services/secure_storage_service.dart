import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'access_token';

  // Fungsi untuk menyimpan token ke dalam "brankas"
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // Fungsi untuk mengambil token (biasanya untuk disisipkan ke request API)
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Fungsi untuk menghapus token (digunakan saat Logout)
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }
}