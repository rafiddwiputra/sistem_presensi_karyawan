import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPreferencesService {
  static const String _keyPengingatPresensi = 'pref_notif_pengingat_presensi';
  static const String _keyInfoIzinCuti = 'pref_notif_info_izin_cuti';

  static const String _topicPengingatPresensi = 'pengingat_presensi';
  static const String _topicInfoIzinCuti = 'info_izin_cuti';

  SharedPreferences? _prefs;
  bool _isPengingatPresensi = true;
  bool _isInfoIzinCuti = true;

  bool get isPengingatPresensi => _isPengingatPresensi;
  bool get isInfoIzinCuti => _isInfoIzinCuti;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _isPengingatPresensi = _prefs?.getBool(_keyPengingatPresensi) ?? true;
    _isInfoIzinCuti = _prefs?.getBool(_keyInfoIzinCuti) ?? true;
  }

  Future<void> setPengingatPresensi(bool value) async {
    _isPengingatPresensi = value;
    await _prefs?.setBool(_keyPengingatPresensi, value);
    await _syncTopicSubscription(_topicPengingatPresensi, value);
  }

  Future<void> setInfoIzinCuti(bool value) async {
    _isInfoIzinCuti = value;
    await _prefs?.setBool(_keyInfoIzinCuti, value);
    await _syncTopicSubscription(_topicInfoIzinCuti, value);
  }

  Future<void> syncAllTopicSubscriptions() async {
    await _syncTopicSubscription(
      _topicPengingatPresensi,
      _isPengingatPresensi,
    );
    await _syncTopicSubscription(_topicInfoIzinCuti, _isInfoIzinCuti);
  }

  /// Menentukan apakah notifikasi FCM perlu memunculkan banner pop-up di perangkat.
  /// Riwayat di halaman Notifikasi tetap tersimpan dari database server.
  bool shouldDisplayNotification(RemoteMessage message) {
    final kategori =
        message.data['kategori']?.toString().toLowerCase().trim() ?? '';
    final tipe = message.data['tipe']?.toString().toLowerCase().trim() ?? '';
    final title =
    (message.notification?.title ??
        message.data['judul']?.toString() ??
        '')
        .toLowerCase();

    final isPresensi =
        kategori == 'presensi' ||
            tipe.contains('presensi') ||
            title.contains('presensi');

    if (isPresensi) {
      return _isPengingatPresensi;
    }

    final isPengajuan =
        kategori == 'pengajuan' ||
            tipe.contains('cuti') ||
            tipe.contains('izin') ||
            tipe.contains('lembur') ||
            tipe.contains('reimbursement') ||
            title.contains('cuti') ||
            title.contains('izin') ||
            title.contains('pengajuan');

    if (isPengajuan) {
      return _isInfoIzinCuti;
    }

    return true;
  }

  Future<void> _syncTopicSubscription(String topic, bool subscribe) async {
    try {
      if (subscribe) {
        await FirebaseMessaging.instance.subscribeToTopic(topic);
      } else {
        await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Gagal sinkronisasi FCM topic ($topic): $e');
      }
    }
  }
}