import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:sistem_presensi_karyawan/core/routes/app_router.dart';
import 'package:sistem_presensi_karyawan/features/profil/repositories/notifikasi_repository.dart';

class FcmService {
  final NotifikasiRepository _notifikasiRepository;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool _isUserLoggedIn = false;
  RemoteMessage? _pendingInitialMessage;

  static const AndroidNotificationChannel _androidChannel =
  AndroidNotificationChannel(
    'high_importance_channel',
    'Notifikasi Presensi & Pengajuan',
    description: 'Notifikasi penting terkait presensi dan status pengajuan.',
    importance: Importance.max,
  );

  FcmService(this._notifikasiRepository);

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    // 1. Minta izin notifikasi (wajib untuk Android 13+ dan iOS)
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. Setup Local Notifications untuk tampilan pop-up saat aplikasi terbuka
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (_) => _navigateToNotifikasi(),
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    // 3. Listener pesan masuk saat aplikasi di foreground
    FirebaseMessaging.onMessage.listen(_showForegroundNotification);

    // 4. Listener saat user mengetuk notifikasi dari background
    FirebaseMessaging.onMessageOpenedApp.listen((_) => _navigateToNotifikasi());

    // 5. Listener saat FCM memperbarui token perangkat secara otomatis
    _messaging.onTokenRefresh.listen((newToken) {
      if (_isUserLoggedIn && newToken.isNotEmpty) {
        unawaited(_sendTokenToBackend(newToken));
      }
    });

    // 6. Simpan pesan awal jika aplikasi dibuka dari kondisi terminated
    _pendingInitialMessage = await _messaging.getInitialMessage();
  }

  /// Dipanggil saat login berhasil atau sesi tersimpan tervalidasi di Splash
  Future<void> syncTokenWithBackend() async {
    _isUserLoggedIn = true;
    try {
      final token = await _messaging.getToken();
      debugPrint('FCM_TOKEN: $token');
      if (token != null && token.isNotEmpty) {
        await _sendTokenToBackend(token);
      }

    } catch (e) {
      if (kDebugMode) {
        debugPrint('Gagal sinkronisasi FCM token: $e');
      }
    }

    if (_pendingInitialMessage != null) {
      _pendingInitialMessage = null;
      await Future<void>.delayed(const Duration(milliseconds: 400));
      _navigateToNotifikasi();
    }
  }

  /// Dipanggil SEBELUM authRepository.logout() agar Sanctum token masih aktif
  Future<void> unregisterTokenFromBackend() async {
    _isUserLoggedIn = false;
    try {
      final token = await _messaging.getToken();
      if (token != null && token.isNotEmpty) {
        await _notifikasiRepository.deleteDeviceToken(token: token);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Gagal menghapus FCM token saat logout: $e');
      }
    }
  }

  Future<void> _sendTokenToBackend(String token) async {
    final platform = Platform.isIOS ? 'ios' : 'android';
    final deviceName = await _resolveDeviceName();

    await _notifikasiRepository.registerDeviceToken(
      token: token,
      platform: platform,
      deviceName: deviceName,
    );
  }

  Future<String?> _resolveDeviceName() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final info = await deviceInfo.androidInfo;
        final raw = '${info.manufacturer} ${info.model}'.trim();
        return raw.length > 100 ? raw.substring(0, 100) : raw;
      }
      if (Platform.isIOS) {
        final info = await deviceInfo.iosInfo;
        final raw = info.utsname.machine.trim();
        return raw.length > 100 ? raw.substring(0, 100) : raw;
      }
    } catch (_) {
      // Abaikan jika gagal membaca info perangkat
    }
    return null;
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    final title =
        notification?.title ?? message.data['judul']?.toString() ?? 'Notifikasi';
    final body =
        notification?.body ?? message.data['pesan']?.toString() ?? '';

    if (title.isEmpty && body.isEmpty) return;

    await _localNotifications.show(
      id: message.hashCode,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  void _navigateToNotifikasi() {
    if (!_isUserLoggedIn) return;
    appRouter.push('/notifikasi');
  }
}