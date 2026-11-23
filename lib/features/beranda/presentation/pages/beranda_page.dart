import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:sistem_presensi_karyawan/features/presensi/data/models/today_attendance_model.dart';
import 'package:sistem_presensi_karyawan/features/presensi/presentation/bloc/riwayat_bloc.dart';
import 'package:sistem_presensi_karyawan/features/presensi/presentation/bloc/riwayat_state.dart';
import 'package:sistem_presensi_karyawan/features/presensi/repositories/presensi_repository.dart';
import 'package:sistem_presensi_karyawan/features/profil/presentation/bloc/profil_bloc.dart';
import 'package:sistem_presensi_karyawan/features/profil/presentation/bloc/profil_event.dart';
import 'package:sistem_presensi_karyawan/features/profil/presentation/bloc/profil_state.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/fcm_service.dart';
import '../../../../core/widgets/authenticated_profile_image.dart';
import '../../../profil/repositories/notifikasi_repository.dart';
import '../widgets/menu_card.dart';

class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> with WidgetsBindingObserver {
  bool _hasUnreadNotifications = false;
  bool _isLoadingAttendance = false;
  TodayAttendanceModel? _todayAttendance;
  String? _todayApprovedLeaveType;

  int _izinCount = 0;
  int _cutiCount = 0;
  int _lemburCount = 0;
  int _reimbursementCount = 0;

  StreamSubscription<void>? _fcmSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshBerandaData();

    _fcmSubscription = sl<FcmService>().onNotificationReceived.listen((_) {
      if (!mounted) return;
      setState(() => _hasUnreadNotifications = true);
      _refreshBerandaData();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _fcmSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshBerandaData();
    }
  }

  Future<void> _refreshBerandaData() async {
    if (mounted) {
      context.read<ProfilBloc>().add(LoadProfilRequested());
    }
    await Future.wait([
      _loadTodayAttendance(),
      _checkUnreadNotifications(),
      _loadPengajuanData(),
    ]);
  }

  Future<void> _loadTodayAttendance() async {
    if (mounted) {
      setState(() => _isLoadingAttendance = true);
    }

    try {
      final attendance = await sl<PresensiRepository>().getTodayAttendance();
      if (mounted) {
        setState(() {
          _todayAttendance = attendance;
          _isLoadingAttendance = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingAttendance = false);
      }
    }
  }

  Future<void> _loadPengajuanData() async {
    try {
      final response = await sl<ApiClient>().dio.get(
        '/pengajuan',
        queryParameters: {'per_page': 100},
      );
      final responseData = response.data;
      if (responseData is! Map<String, dynamic>) return;

      final rawData = responseData['data'];
      if (rawData is! List) return;

      final now = DateTime.now();
      final todayOnly = DateTime(now.year, now.month, now.day);

      int izin = 0;
      int cuti = 0;
      int lembur = 0;
      int reimbursement = 0;
      String? activeLeaveToday;

      for (final item in rawData) {
        if (item is! Map<String, dynamic>) continue;

        final String jenis =
        (item['jenis']?.toString() ?? '').trim().toLowerCase();
        final String status =
        (item['status']?.toString() ?? '').trim().toLowerCase();

        if ((jenis == 'izin' || jenis == 'cuti') &&
            (status == 'disetujui' || status == 'approved')) {
          final DateTime? startDate = _parseDateOnly(
            item['start_date'] ?? item['tanggal_mulai'],
          );
          final DateTime? endDate = _parseDateOnly(
            item['end_date'] ?? item['tanggal_selesai'],
          ) ??
              startDate;

          if (startDate != null &&
              endDate != null &&
              !todayOnly.isBefore(startDate) &&
              !todayOnly.isAfter(endDate)) {
            activeLeaveToday = jenis == 'cuti' ? 'Cuti' : 'Izin';
          }
        }

        if (status == 'ditolak' || status == 'rejected' || status == 'batal') {
          continue;
        }

        final DateTime? itemDate = _parsePengajuanDate(item);
        if (itemDate == null ||
            itemDate.year != now.year ||
            itemDate.month != now.month) {
          continue;
        }

        switch (jenis) {
          case 'izin':
            izin++;
            break;
          case 'cuti':
            cuti++;
            break;
          case 'lembur':
            lembur++;
            break;
          case 'reimbursement':
            reimbursement++;
            break;
        }
      }

      if (mounted) {
        setState(() {
          _todayApprovedLeaveType = activeLeaveToday;
          _izinCount = izin;
          _cutiCount = cuti;
          _lemburCount = lembur;
          _reimbursementCount = reimbursement;
        });
      }
    } catch (_) {
      // Pertahankan state terakhir jika gagal memuat data pengajuan
    }
  }

  String _extractJabatan(Map<String, dynamic> user) {
    String? pickFromMap(Map<String, dynamic> map) {
      final rawJabatan = map['jabatan'];
      if (rawJabatan is String && rawJabatan.trim().isNotEmpty) {
        return rawJabatan.trim();
      }
      if (rawJabatan is Map) {
        final nested = rawJabatan['nama'] ??
            rawJabatan['nama_jabatan'] ??
            rawJabatan['title'] ??
            rawJabatan['label'];
        if (nested != null && nested.toString().trim().isNotEmpty) {
          return nested.toString().trim();
        }
      }

      final directCandidates = [
        map['nama_jabatan'],
        map['jabatan_nama'],
        map['posisi'],
        map['position'],
        map['role_label'],
      ];

      for (final candidate in directCandidates) {
        if (candidate is String && candidate.trim().isNotEmpty) {
          return candidate.trim();
        }
      }
      return null;
    }

    final topLevel = pickFromMap(user);
    if (topLevel != null) return topLevel;

    final karyawan = user['karyawan'];
    if (karyawan is Map) {
      final fromKaryawan = pickFromMap(Map<String, dynamic>.from(karyawan));
      if (fromKaryawan != null) return fromKaryawan;
    }

    return 'Karyawan';
  }

  DateTime? _parseDateOnly(dynamic raw) {
    if (raw == null) return null;
    final text = raw.toString().trim();
    if (text.isEmpty) return null;
    final parsed = DateTime.tryParse(text);
    if (parsed == null) return null;
    final local = parsed.isUtc ? parsed.toLocal() : parsed;
    return DateTime(local.year, local.month, local.day);
  }

  DateTime? _parsePengajuanDate(Map<String, dynamic> item) {
    final candidates = [
      item['submitted_at'],
      item['created_at'],
      item['start_date'],
      item['tanggal_mulai'],
      item['tanggal_lembur'],
      item['tanggal_transaksi'],
      item['tanggal'],
    ];

    for (final raw in candidates) {
      if (raw == null) continue;
      final text = raw.toString().trim();
      if (text.isEmpty) continue;
      final parsed = DateTime.tryParse(text);
      if (parsed != null) {
        return parsed.isUtc ? parsed.toLocal() : parsed;
      }
    }
    return null;
  }

  Future<void> _checkUnreadNotifications() async {
    try {
      final result = await sl<NotifikasiRepository>().getNotifications(
        unreadOnly: true,
      );
      if (mounted) {
        setState(() {
          _hasUnreadNotifications = result.items.isNotEmpty;
        });
      }
    } catch (_) {
      // Abaikan kegagalan jaringan saat pengecekan badge di latar belakang
    }
  }

  String _formatJamPresensi(String? rawTime) {
    if (rawTime == null || rawTime.trim().isEmpty) return '--:--';
    final clean = rawTime.trim();

    if (clean.contains('-') || clean.contains('T')) {
      final parsed = DateTime.tryParse(clean);
      if (parsed != null) {
        final local = parsed.isUtc ? parsed.toLocal() : parsed;
        final hh = local.hour.toString().padLeft(2, '0');
        final mm = local.minute.toString().padLeft(2, '0');
        return '$hh:$mm';
      }
    }

    final match = RegExp(r'(\d{1,2})[:.](\d{2})').firstMatch(clean);
    if (match != null) {
      final hh = match.group(1)!.padLeft(2, '0');
      final mm = match.group(2)!;
      return '$hh:$mm';
    }

    return clean;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryBlue =
    isDark ? const Color(0xFF154B8C) : const Color(0xFF1961B6);
    final Color primaryBlueDeep =
    isDark ? const Color(0xFF0F3666) : const Color(0xFF12498C);
    final Color cardSurface = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color borderColor =
    isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE2E8F0);
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color textSecondary =
    isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final presensi = _todayAttendance?.presensi;
    final jadwal = _todayAttendance?.jadwal;

    final bool sudahMasuk = presensi?.sudahMasuk ?? false;
    final bool sudahKeluar = presensi?.sudahKeluar ?? false;

    final String jamMasukDisplay =
    sudahMasuk ? _formatJamPresensi(presensi?.waktuMasuk) : '--:--';
    final String jamSelesaiDisplay =
    sudahKeluar ? _formatJamPresensi(presensi?.waktuKeluar) : '--:--';

    final String apiStatus =
    (presensi?.statusKehadiran ?? '').trim().toLowerCase();
    final String? effectiveLeaveToday = _todayApprovedLeaveType ??
        (apiStatus == 'cuti'
            ? 'Cuti'
            : (apiStatus == 'izin' ? 'Izin' : null));

    String statusBadgeText = 'Belum Presensi';
    Color statusBadgeColor = const Color(0xFFD97706);

    if (_isLoadingAttendance && _todayAttendance == null) {
      statusBadgeText = 'Memuat...';
      statusBadgeColor = textSecondary;
    } else if (sudahMasuk && sudahKeluar) {
      statusBadgeText = 'Selesai';
      statusBadgeColor = const Color(0xFF10B981);
    } else if (sudahMasuk) {
      final terlambat = presensi?.menitTerlambat ?? 0;
      if (terlambat > 0) {
        statusBadgeText = 'Terlambat ${terlambat}m';
        statusBadgeColor = const Color(0xFFD97706);
      } else {
        statusBadgeText = 'Sudah Masuk';
        statusBadgeColor = const Color(0xFF0284C7);
      }
    } else if (effectiveLeaveToday != null) {
      statusBadgeText = effectiveLeaveToday;
      statusBadgeColor = effectiveLeaveToday == 'Cuti'
          ? const Color(0xFF2E7D60)
          : const Color(0xFF5E548E);
    }

    String footerHintText = 'Ketuk untuk rekam kehadiran GPS';
    if (!sudahMasuk && effectiveLeaveToday != null) {
      footerHintText =
      'Status hari ini: $effectiveLeaveToday • Ketuk jika tetap presensi';
    } else if (jadwal != null) {
      final jamShift =
          '${_formatJamPresensi(jadwal.jamMasuk)} - ${_formatJamPresensi(jadwal.jamPulang)}';
      if (sudahMasuk && sudahKeluar) {
        footerHintText = 'Shift ${jadwal.nama} ($jamShift) • Presensi selesai';
      } else if (sudahMasuk) {
        footerHintText = 'Shift ${jadwal.nama} • Ketuk untuk presensi pulang';
      } else {
        footerHintText = 'Shift ${jadwal.nama} ($jamShift) • Ketuk untuk masuk';
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _refreshBerandaData,
        color: primaryBlue,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: Stack(
            children: [
              // 1. CORPORATE HERO BACKGROUND
              Positioned(
                top: -500,
                left: 0,
                right: 0,
                child: Container(
                  height: 500 + 235.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [primaryBlue, primaryBlueDeep],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32.r),
                      bottomRight: Radius.circular(32.r),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -40.w,
                        bottom: -30.h,
                        child: Container(
                          width: 180.w,
                          height: 180.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                        ),
                      ),
                      Positioned(
                        left: -30.w,
                        bottom: 40.h,
                        child: Container(
                          width: 120.w,
                          height: 120.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.04),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. KONTEN UTAMA
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- TOP BAR PROFIL & NOTIFIKASI ---
                  Padding(
                    padding: EdgeInsets.only(top: 56.h, left: 20.w, right: 20.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: BlocBuilder<ProfilBloc, ProfilState>(
                            builder: (context, state) {
                              String namaPanggilan = 'Karyawan';
                              String jabatan = 'Karyawan';
                              String? fotoProfilUrl;

                              if (state is ProfilLoaded) {
                                final dynamic rawUser = state.user;
                                if (rawUser is Map) {
                                  final userMap =
                                  Map<String, dynamic>.from(rawUser);
                                  final String namaLengkap =
                                  (userMap['nama']?.toString() ??
                                      'Karyawan')
                                      .trim();
                                  if (namaLengkap.isNotEmpty) {
                                    namaPanggilan =
                                        namaLengkap.split(' ').first;
                                  }
                                  jabatan = _extractJabatan(userMap);
                                  fotoProfilUrl =
                                      userMap['foto_url']?.toString();
                                }
                              }

                              return Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(2.w),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color:
                                        Colors.white.withValues(alpha: 0.35),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: AuthenticatedProfileImage(
                                      imagePath: fotoProfilUrl,
                                      size: 46.w,
                                      isDark: isDark,
                                      borderWidth: 0,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Halo, $namaPanggilan',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8.w,
                                            vertical: 3.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white
                                                .withValues(alpha: 0.14),
                                            borderRadius:
                                            BorderRadius.circular(6.r),
                                          ),
                                          child: Text(
                                            jabatan,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 11.sp,
                                              fontWeight: FontWeight.w500,
                                              color: const Color(0xFFFDE68A),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 12.w),
                        GestureDetector(
                          onTap: () async {
                            await context.push('/notifikasi');
                            if (mounted) {
                              _checkUnreadNotifications();
                            }
                          },
                          child: Container(
                            width: 42.w,
                            height: 42.w,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(14.r),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  Icons.notifications_outlined,
                                  color: Colors.white,
                                  size: 22.w,
                                ),
                                if (_hasUnreadNotifications)
                                  Positioned(
                                    right: 10.w,
                                    top: 10.h,
                                    child: Container(
                                      width: 8.w,
                                      height: 8.w,
                                      decoration: BoxDecoration(
                                        color: AppColors.error,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: primaryBlue,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 18.h),

                  // --- CAPSULE TANGGAL & JAM REAL-TIME (CENTER) ---
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: const Center(
                      child: _RealTimeDateCapsule(),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // --- BODY KARTU & MENU ---
                  Padding(
                    padding: EdgeInsets.only(
                      left: 20.w,
                      right: 20.w,
                      bottom: 110.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. KARTU JADWAL & JAM KERJA HARI INI
                        GestureDetector(
                          onTap: () async {
                            await context.push('/presensi');
                            if (mounted) {
                              _loadTodayAttendance();
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(18.w),
                            decoration: BoxDecoration(
                              color: cardSurface,
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(color: borderColor, width: 1.w),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: isDark ? 0.35 : 0.07,
                                  ),
                                  blurRadius: 18.r,
                                  offset: Offset(0, 6.h),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.schedule_rounded,
                                          size: 16.w,
                                          color: isDark
                                              ? const Color(0xFF60A5FA)
                                              : const Color(0xFF1961B6),
                                        ),
                                        SizedBox(width: 6.w),
                                        Text(
                                          'JADWAL PRESENSI HARI INI',
                                          style: TextStyle(
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.6,
                                            color: textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 3.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusBadgeColor
                                            .withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(6.r),
                                      ),
                                      child: Text(
                                        statusBadgeText,
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w700,
                                          color: statusBadgeColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 14.h),

                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: EdgeInsets.all(12.w),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? const Color(0xFF141B24)
                                              : const Color(0xFFF0F9FF),
                                          borderRadius:
                                          BorderRadius.circular(14.r),
                                          border: Border.all(
                                            color: isDark
                                                ? const Color(0xFF1E3A5F)
                                                : const Color(0xFFBAE6FD),
                                            width: 1.w,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(8.w),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF0EA5E9)
                                                    .withValues(alpha: 0.15),
                                                borderRadius:
                                                BorderRadius.circular(10.r),
                                              ),
                                              child: Icon(
                                                Icons.login_rounded,
                                                color: const Color(0xFF0EA5E9),
                                                size: 18.w,
                                              ),
                                            ),
                                            SizedBox(width: 10.w),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Jam Masuk',
                                                    style: TextStyle(
                                                      fontSize: 11.sp,
                                                      color: const Color(
                                                        0xFF0284C7,
                                                      ),
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                  SizedBox(height: 2.h),
                                                  FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    alignment:
                                                    Alignment.centerLeft,
                                                    child: Text(
                                                      jamMasukDisplay,
                                                      style: TextStyle(
                                                        fontSize: 18.sp,
                                                        fontWeight:
                                                        FontWeight.w800,
                                                        color: sudahMasuk
                                                            ? textPrimary
                                                            : textSecondary,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: Container(
                                        padding: EdgeInsets.all(12.w),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? const Color(0xFF231618)
                                              : const Color(0xFFFEF2F2),
                                          borderRadius:
                                          BorderRadius.circular(14.r),
                                          border: Border.all(
                                            color: isDark
                                                ? const Color(0xFF4C1D24)
                                                : const Color(0xFFFECACA),
                                            width: 1.w,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(8.w),
                                              decoration: BoxDecoration(
                                                color: AppColors.error
                                                    .withValues(alpha: 0.14),
                                                borderRadius:
                                                BorderRadius.circular(10.r),
                                              ),
                                              child: Icon(
                                                Icons.logout_rounded,
                                                color: AppColors.error,
                                                size: 18.w,
                                              ),
                                            ),
                                            SizedBox(width: 10.w),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Jam Selesai',
                                                    style: TextStyle(
                                                      fontSize: 11.sp,
                                                      color: AppColors.error,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                  SizedBox(height: 2.h),
                                                  FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    alignment:
                                                    Alignment.centerLeft,
                                                    child: Text(
                                                      jamSelesaiDisplay,
                                                      style: TextStyle(
                                                        fontSize: 18.sp,
                                                        fontWeight:
                                                        FontWeight.w800,
                                                        color: sudahKeluar
                                                            ? textPrimary
                                                            : textSecondary,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 12.h),

                                // Strip Pintasan ke Halaman Absensi
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 8.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF141414)
                                        : const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.location_on_outlined,
                                              size: 15.w,
                                              color: isDark
                                                  ? const Color(0xFF60A5FA)
                                                  : const Color(0xFF1961B6),
                                            ),
                                            SizedBox(width: 6.w),
                                            Expanded(
                                              child: Text(
                                                footerHintText,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 11.sp,
                                                  fontWeight: FontWeight.w500,
                                                  color: textSecondary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 6.w),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 12.w,
                                        color: textSecondary,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 18.h),

                        _buildRekapPresensiCard(context, isDark),

                        SizedBox(height: 24.h),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Layanan Karyawan',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                    color: textPrimary,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'Pengajuan administrasi',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        SizedBox(height: 12.h),

                        GridView.count(
                          padding: EdgeInsets.zero,
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 14.w,
                          mainAxisSpacing: 14.h,
                          childAspectRatio: 1.08,
                          children: [
                            MenuCard(
                              title: 'IZIN',
                              subtitle: 'Izin bulan ini',
                              count: _izinCount.toString(),
                              backgroundColor: isDark
                                  ? const Color(0xFF1E1E1E)
                                  : const Color(0xFFF5F3FF),
                              iconBackgroundColor: const Color(0xFF5E548E),
                              icon: Icons.mail_outline_rounded,
                              onTap: () async {
                                await context.push('/izin');
                                if (mounted) _loadPengajuanData();
                              },
                            ),
                            MenuCard(
                              title: 'CUTI',
                              subtitle: 'Cuti bulan ini',
                              count: _cutiCount.toString(),
                              backgroundColor: isDark
                                  ? const Color(0xFF1E1E1E)
                                  : const Color(0xFFECFDF5),
                              iconBackgroundColor: const Color(0xFF2E7D60),
                              icon: Icons.calendar_today_outlined,
                              onTap: () async {
                                await context.push('/cuti');
                                if (mounted) _loadPengajuanData();
                              },
                            ),
                            MenuCard(
                              title: 'LEMBUR',
                              subtitle: 'Pengajuan lembur',
                              count: _lemburCount.toString(),
                              backgroundColor: isDark
                                  ? const Color(0xFF1E1E1E)
                                  : const Color(0xFFFFF7ED),
                              iconBackgroundColor: const Color(0xFFD9531E),
                              icon: Icons.access_time_rounded,
                              onTap: () async {
                                await context.push('/lembur');
                                if (mounted) _loadPengajuanData();
                              },
                            ),
                            MenuCard(
                              title: 'REIMBURSEMENT',
                              subtitle: 'Reimburs bulan ini',
                              count: _reimbursementCount.toString(),
                              backgroundColor: isDark
                                  ? const Color(0xFF1E1E1E)
                                  : const Color(0xFFFDF2F8),
                              iconBackgroundColor: const Color(0xFF9E3E6E),
                              icon: Icons.receipt_long_outlined,
                              onTap: () async {
                                await context.push('/reimbursement');
                                if (mounted) _loadPengajuanData();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRekapPresensiCard(BuildContext context, bool isDark) {
    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color borderColor =
    isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE2E8F0);
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color textSecondary =
    isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return GestureDetector(
      onTap: () {
        context.push('/rekap-presensi');
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: borderColor, width: 1.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
              blurRadius: 14.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(9.w),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E3A8A).withValues(alpha: 0.35)
                              : const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.bar_chart_rounded,
                          color: isDark
                              ? const Color(0xFF60A5FA)
                              : const Color(0xFF1961B6),
                          size: 20.w,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rekap Presensi',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                color: textPrimary,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'Ringkasan kehadiran bulan ini',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF282828)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Detail',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? const Color(0xFF93C5FD)
                              : const Color(0xFF1961B6),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: isDark
                            ? const Color(0xFF93C5FD)
                            : const Color(0xFF1961B6),
                        size: 16.w,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            BlocBuilder<RiwayatBloc, RiwayatState>(
              builder: (context, state) {
                String totalMasuk = '0';
                String totalTerlambat = '0';
                String totalTanpaAbsen = '0';

                if (state is RiwayatLoaded) {
                  totalMasuk = state.summary.hadir.toString();
                  totalTanpaAbsen = state.summary.tidakHadir.toString();

                  int terlambatCount = 0;
                  for (var item in state.riwayatList) {
                    if (item.menitTerlambat > 0) {
                      terlambatCount++;
                    }
                  }
                  totalTerlambat = terlambatCount.toString();
                }

                return Row(
                  children: [
                    Expanded(
                      child: _buildRekapTile(
                        isDark: isDark,
                        angka: totalMasuk,
                        label: 'Masuk',
                        warnaAngka: isDark
                            ? const Color(0xFF34D399)
                            : const Color(0xFF059669),
                        warnaBg: isDark
                            ? const Color(0xFF064E3B).withValues(alpha: 0.35)
                            : const Color(0xFFECFDF5),
                        textSecondary: textSecondary,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _buildRekapTile(
                        isDark: isDark,
                        angka: totalTerlambat,
                        label: 'Terlambat',
                        warnaAngka: isDark
                            ? const Color(0xFFFBBF24)
                            : const Color(0xFFD97706),
                        warnaBg: isDark
                            ? const Color(0xFF78350F).withValues(alpha: 0.35)
                            : const Color(0xFFFFFBEB),
                        textSecondary: textSecondary,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _buildRekapTile(
                        isDark: isDark,
                        angka: totalTanpaAbsen,
                        label: 'Tanpa Absen',
                        warnaAngka: isDark
                            ? const Color(0xFFF87171)
                            : const Color(0xFFDC2626),
                        warnaBg: isDark
                            ? const Color(0xFF7F1D1D).withValues(alpha: 0.35)
                            : const Color(0xFFFEF2F2),
                        textSecondary: textSecondary,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRekapTile({
    required bool isDark,
    required String angka,
    required String label,
    required Color warnaAngka,
    required Color warnaBg,
    required Color textSecondary,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: warnaBg,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        children: [
          Text(
            angka,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: warnaAngka,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white.withValues(alpha: 0.85) : textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _RealTimeDateCapsule extends StatefulWidget {
  const _RealTimeDateCapsule();

  @override
  State<_RealTimeDateCapsule> createState() => _RealTimeDateCapsuleState();
}

class _RealTimeDateCapsuleState extends State<_RealTimeDateCapsule> {
  late DateTime _now;
  Timer? _timer;

  static const List<String> _months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static const List<String> _days = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formattedDate() {
    return '${_days[_now.weekday - 1]}, ${_now.day} ${_months[_now.month - 1]} ${_now.year}';
  }

  String _formattedTime() {
    final hh = _now.hour.toString().padLeft(2, '0');
    final mm = _now.minute.toString().padLeft(2, '0');
    final ss = _now.second.toString().padLeft(2, '0');
    return '$hh:$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 14.w,
        vertical: 7.h,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 13.w,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            SizedBox(width: 7.w),
            Text(
              _formattedDate(),
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.95),
              ),
            ),
            Container(
              width: 1.w,
              height: 13.h,
              margin: EdgeInsets.symmetric(horizontal: 10.w),
              color: Colors.white.withValues(alpha: 0.24),
            ),
            Icon(
              Icons.access_time_rounded,
              size: 13.w,
              color: const Color(0xFFFDE68A),
            ),
            SizedBox(width: 5.w),
            Text(
              _formattedTime(),
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFFDE68A),
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}