import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/di/injection.dart';
import '../../data/models/today_attendance_model.dart';
import '../bloc/presensi_bloc.dart';
import '../bloc/presensi_event.dart';
import '../bloc/presensi_state.dart';
import '../widgets/konfirmasi_presensi_bottom_sheet.dart';

class PresensiPage extends StatelessWidget {
  const PresensiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<PresensiBloc>()..add(LoadPresensiData()),
      child: const PresensiView(),
    );
  }
}

class PresensiView extends StatefulWidget {
  const PresensiView({super.key});

  @override
  State<PresensiView> createState() => _PresensiViewState();
}

class _PresensiViewState extends State<PresensiView> {
  final MapController _mapController = MapController();
  bool _isMapReady = false;
  bool _isSatellite = false;

  // Fallback koordinat default (Madiun) jika kantor & GPS belum termuat
  static const LatLng _defaultCenter = LatLng(-7.6298, 111.5239);

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _fitCameraToLocations(PresensiState state) {
    if (!_isMapReady) return;

    final kantor = state.attendanceData?.kantor;
    final hasKantor = kantor != null;
    final hasUser = state.userLatitude != null && state.userLongitude != null;

    final LatLng? kantorLatLng =
    hasKantor ? LatLng(kantor.latitude, kantor.longitude) : null;
    final LatLng? userLatLng =
    hasUser ? LatLng(state.userLatitude!, state.userLongitude!) : null;

    try {
      if (userLatLng != null && kantorLatLng != null) {
        final bounds = LatLngBounds.fromPoints([userLatLng, kantorLatLng]);
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: bounds,
            padding: EdgeInsets.symmetric(horizontal: 64.w, vertical: 80.h),
            maxZoom: 17.5,
          ),
        );
      } else if (userLatLng != null) {
        _mapController.move(userLatLng, 17.5);
      } else if (kantorLatLng != null) {
        _mapController.move(kantorLatLng, 17.0);
      }
    } catch (_) {
      // Abaikan jika controller belum terpasang sepenuhnya
    }
  }

  String _formatTanggal(String? rawDate) {
    if (rawDate == null) return '-';
    try {
      final date = DateTime.parse(rawDate);
      return DateFormat('EEEE, d MMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return rawDate;
    }
  }

  String _formatJamWIB(String? time) {
    if (time == null || time.isEmpty) return '--:-- WIB';

    String timeOnly = time;
    if (time.contains(' ')) {
      timeOnly = time.split(' ').last;
    }

    final parts = timeOnly.split(':');
    if (parts.length >= 2) {
      return '${parts[0]}:${parts[1]} WIB';
    }
    return '$timeOnly WIB';
  }

  String _getTileUrl() {
    if (_isSatellite) {
      return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
    }
    return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    const Color headerBlue = Color(0xFF1961B6);
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color textSecondary =
    isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final Color cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color mapBgColor =
    isDark ? const Color(0xFF121212) : const Color(0xFFE8EDF2);
    final Color borderColor =
    isDark ? const Color(0xFF333333) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF154B8C) : headerBlue,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 24.w),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Absensi Hari ini',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: BlocConsumer<PresensiBloc, PresensiState>(
        listener: (context, state) {
          if (state.status == PresensiStatus.error &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state.status == PresensiStatus.submitSuccess &&
              state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                backgroundColor: Colors.green,
              ),
            );
            Future.delayed(const Duration(seconds: 1), () {
              if (context.mounted) context.pop();
            });
          } else if (state.status == PresensiStatus.loaded) {
            _fitCameraToLocations(state);
          }
        },
        builder: (context, state) {
          if (state.status == PresensiStatus.initial ||
              (state.status == PresensiStatus.loading &&
                  state.attendanceData == null)) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = state.attendanceData;
          final KantorModel? kantor = data?.kantor;
          final isDalamRadius = state.isDalamRadius;
          final isCheckingLokasi =
              state.status == PresensiStatus.locationChecking;

          final LatLng? kantorLatLng = kantor != null
              ? LatLng(kantor.latitude, kantor.longitude)
              : null;
          final LatLng? userLatLng =
          (state.userLatitude != null && state.userLongitude != null)
              ? LatLng(state.userLatitude!, state.userLongitude!)
              : null;
          final LatLng initialCenter =
              userLatLng ?? kantorLatLng ?? _defaultCenter;

          // ==========================================
          // LOGIKA TOMBOL PRESENSI
          // ==========================================
          final bool isSudahMasuk = data?.presensi.waktuMasuk != null;
          final bool isModePulang = data?.aksiBerikutnya == 'Pulang';
          final bool isSelesai = data?.presensiSelesai == true;

          bool isTombolAktif = false;
          String teksTombol = 'Memuat...';
          IconData? iconTombol;

          if (isSelesai) {
            isTombolAktif = false;
            teksTombol = 'Presensi Selesai';
            iconTombol = Icons.check_circle_outline;
          } else if (!isSudahMasuk) {
            isTombolAktif = true;
            teksTombol = 'Masuk Kerja';
            iconTombol = null;
          } else if (isSudahMasuk && isModePulang) {
            isTombolAktif = true;
            teksTombol = 'Pulang Kerja';
            iconTombol = Icons.logout_outlined;
          } else if (isSudahMasuk && !isModePulang) {
            isTombolAktif = false;
            teksTombol = 'Belum Waktu Pulang';
            iconTombol = Icons.lock_clock_outlined;
          }

          bool canPress = isTombolAktif && isDalamRadius && !isCheckingLokasi;
          // ==========================================

          return Stack(
            children: [
              // 1. AREA PETA REAL-TIME (FLUTTER MAP)
              Container(
                height: MediaQuery.of(context).size.height * 0.62,
                width: double.infinity,
                color: mapBgColor,
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: initialCenter,
                    initialZoom: 17.0,
                    minZoom: 10.0,
                    maxZoom: 19.0,
                    onMapReady: () {
                      _isMapReady = true;
                      _fitCameraToLocations(state);
                    },
                  ),
                  children: [
                    // Layer Peta (OpenStreetMap Gratis Tanpa API Key / Satellite)
                    TileLayer(
                      urlTemplate: _getTileUrl(),
                      userAgentPackageName: 'com.presensi.sistem_presensi_karyawan',
                      maxZoom: 19,
                      tileBuilder: (context, tileWidget, tile) {
                        if (!isDark || _isSatellite) return tileWidget;
                        return ColorFiltered(
                          colorFilter: const ColorFilter.matrix(<double>[
                            0.459, -1.144, -0.115, 0, 229.5,
                            -0.341, -0.344, -0.115, 0, 229.5,
                            -0.341, -1.144,  0.685, 0, 229.5,
                            0,      0,      0,     1,   0,
                          ]),
                          child: tileWidget,
                        );
                      },
                    ),

                    // Lingkaran Radius Geofencing Kantor
                    if (kantorLatLng != null && kantor != null)
                      CircleLayer(
                        circles: [
                          CircleMarker(
                            point: kantorLatLng,
                            radius: kantor.radiusMeter.toDouble(),
                            useRadiusInMeter: true,
                            color: (isDalamRadius
                                ? const Color(0xFF10B981)
                                : const Color(0xFFF59E0B))
                                .withValues(alpha: 0.16),
                            borderColor: isDalamRadius
                                ? const Color(0xFF10B981)
                                : const Color(0xFFF59E0B),
                            borderStrokeWidth: 2,
                          ),
                        ],
                      ),

                    // Marker Kantor & Posisi Karyawan
                    MarkerLayer(
                      markers: [
                        // Pin Lokasi Kantor
                        if (kantorLatLng != null && kantor != null)
                          Marker(
                            point: kantorLatLng,
                            width: 160.w,
                            height: 80.h,
                            alignment: Alignment.center,
                            child: Stack(
                              alignment: Alignment.center,
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 32.w,
                                  height: 32.w,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.2,
                                        ),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.business_rounded,
                                    color: Colors.white,
                                    size: 16.w,
                                  ),
                                ),
                                Positioned(
                                  top: 36.h,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 3.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF1E293B)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(8.r),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.12,
                                          ),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      kantor.nama,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF1E293B),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Pin Posisi Karyawan + Pill Oranye
                        if (userLatLng != null)
                          Marker(
                            point: userLatLng,
                            width: 185.w,
                            height: 90.h,
                            alignment: Alignment.center,
                            child: Stack(
                              alignment: Alignment.center,
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 24.w,
                                  height: 24.w,
                                  decoration: BoxDecoration(
                                    color: headerBlue.withValues(alpha: 0.25),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 12.w,
                                      height: 12.w,
                                      decoration: BoxDecoration(
                                        color: headerBlue,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 30.h,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 6.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isCheckingLokasi
                                          ? Colors.blue
                                          : const Color(0xFFF59E0B),
                                      borderRadius: BorderRadius.circular(20.r),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.15,
                                          ),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (isCheckingLokasi) ...[
                                          SizedBox(
                                            width: 10.w,
                                            height: 10.w,
                                            child:
                                            const CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          ),
                                          SizedBox(width: 6.w),
                                          Text(
                                            'Mencari GPS...',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ] else ...[
                                          Icon(
                                            Icons.location_on,
                                            color: Colors.white,
                                            size: 14.w,
                                          ),
                                          SizedBox(width: 4.w),
                                          Text(
                                            'Posisi Anda (${state.jarakMeter}m)',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // 2. TOMBOL KONTROL PETA (RECENTER & GANTI LAYER)
              Positioned(
                top: 16.h,
                right: 16.w,
                child: Column(
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'btn_location',
                      backgroundColor:
                      isDark ? const Color(0xFF282828) : Colors.white,
                      onPressed: () {
                        context.read<PresensiBloc>().add(RefreshLokasi());
                        if (userLatLng != null && _isMapReady) {
                          _mapController.move(userLatLng, 17.5);
                        }
                      },
                      child: Icon(
                        Icons.my_location,
                        color: headerBlue,
                        size: 20.w,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    FloatingActionButton.small(
                      heroTag: 'btn_layers',
                      backgroundColor: _isSatellite
                          ? headerBlue
                          : (isDark ? const Color(0xFF282828) : Colors.white),
                      onPressed: () {
                        setState(() {
                          _isSatellite = !_isSatellite;
                        });
                      },
                      child: Icon(
                        Icons.layers_outlined,
                        color: _isSatellite ? Colors.white : textSecondary,
                        size: 20.w,
                      ),
                    ),
                  ],
                ),
              ),

              // 3. BOTTOM SHEET KARTU PRESENSI
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.r),
                      topRight: Radius.circular(30.r),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.4 : 0.12,
                        ),
                        blurRadius: 20.r,
                        offset: Offset(0, -5.h),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40.w,
                          height: 5.h,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF333333)
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      isCheckingLokasi
                          ? const Center(child: CircularProgressIndicator())
                          : (isDalamRadius
                          ? _buildDalamRadiusCard(
                        isDark,
                        state.jarakMeter,
                      )
                          : _buildLuarRadiusCard(
                        isDark,
                        state.jarakMeter,
                      )),
                      SizedBox(height: 16.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 16.h,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF121212)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: borderColor, width: 1.0.w),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(10.w),
                                    decoration: BoxDecoration(
                                      color: headerBlue.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    child: Icon(
                                      Icons.calendar_today_outlined,
                                      color: isDark
                                          ? const Color(0xFF60A5FA)
                                          : headerBlue,
                                      size: 20.w,
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'Tanggal Presensi',
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: textSecondary,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 2.h),
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            _formatTanggal(data?.tanggal),
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.bold,
                                              color: textPrimary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 40.h,
                              width: 1.w,
                              color: borderColor,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              flex: 4,
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(10.w),
                                    decoration: BoxDecoration(
                                      color: headerBlue.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    child: Icon(
                                      Icons.access_time_outlined,
                                      color: isDark
                                          ? const Color(0xFF60A5FA)
                                          : headerBlue,
                                      size: 20.w,
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'Waktu Presensi',
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: textSecondary,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 2.h),
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            '${DateFormat('HH:mm').format(DateTime.now())} WIB',
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.bold,
                                              color: textPrimary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // --- CARD PRESENSI MASUK HARI INI ---
                      if (data?.presensi.waktuMasuk != null)
                        Container(
                          margin: EdgeInsets.only(top: 12.h),
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E1E1E)
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF333333)
                                  : const Color(0xFFF1F5F9),
                              width: 1.5.w,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10.w),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Icon(
                                  Icons.login_rounded,
                                  color: const Color(0xFF10B981),
                                  size: 20.w,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Presensi Masuk Hari Ini',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: isDark
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  RichText(
                                    text: TextSpan(
                                      text: 'Jam Masuk: ',
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF1E293B),
                                        fontFamily: 'Inter',
                                      ),
                                      children: [
                                        TextSpan(
                                          text: _formatJamWIB(
                                            data!.presensi.waktuMasuk!,
                                          ),
                                          style: const TextStyle(
                                            color: Color(0xFF3B82F6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                      SizedBox(height: 16.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                              color: headerBlue.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.location_on_outlined,
                              color: isDark
                                  ? const Color(0xFF60A5FA)
                                  : headerBlue,
                              size: 24.w,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'LOKASI KANTOR',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    color: textSecondary,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  data?.kantor?.nama ?? 'Memuat lokasi...',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 32.h),

                      // Tombol Master Presensi
                      SizedBox(
                        width: double.infinity,
                        height: 55.h,
                        child: ElevatedButton.icon(
                          onPressed: canPress
                              ? () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => BlocProvider.value(
                                value: context.read<PresensiBloc>(),
                                child:
                                const KonfirmasiPresensiBottomSheet(),
                              ),
                            );
                          }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: headerBlue,
                            disabledBackgroundColor: isDark
                                ? const Color(0xFF333333)
                                : const Color(0xFFE2E8F0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            elevation: 0,
                          ),
                          icon: iconTombol != null
                              ? Icon(
                            (!canPress && isTombolAktif)
                                ? Icons.lock_outline
                                : iconTombol,
                            color: canPress
                                ? Colors.white
                                : const Color(0xFF94A3B8),
                            size: 20.w,
                          )
                              : const SizedBox.shrink(),
                          label: Text(
                            (!canPress && isTombolAktif)
                                ? 'Di Luar Radius Kantor'
                                : teksTombol,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: canPress
                                  ? Colors.white
                                  : const Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLuarRadiusCard(bool isDark, int jarak) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF3F2704) : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? const Color(0xFF92400E) : const Color(0xFFFDE68A),
          width: 1.w,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF78350F)
                      : const Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: isDark
                      ? const Color(0xFFFDE68A)
                      : const Color(0xFFD97706),
                  size: 18.w,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Di Luar Radius',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                        color: isDark
                            ? const Color(0xFFFDE68A)
                            : const Color(0xFF92400E),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Lokasi Anda berada di luar area',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: isDark
                            ? const Color(0xFFFDE68A).withValues(alpha: 0.8)
                            : const Color(0xFF92400E).withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                height: 35.h,
                width: 1.w,
                color:
                isDark ? const Color(0xFF92400E) : const Color(0xFFFDE68A),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '$jarak m',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                      color: isDark
                          ? const Color(0xFFFDE68A)
                          : const Color(0xFF92400E),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Jarak Anda',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: isDark
                          ? const Color(0xFFFDE68A).withValues(alpha: 0.7)
                          : const Color(0xFF92400E).withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDalamRadiusCard(bool isDark, int jarak) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF064E3B) : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? const Color(0xFF047857) : const Color(0xFFBBF7D0),
          width: 1.0.w,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: const BoxDecoration(
              color: Color(0xFF10B981),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, color: Colors.white, size: 16.w),
          ),
          SizedBox(width: 12.w),
          Text(
            'Dalam Radius',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const Spacer(),
          Container(
            height: 40.h,
            width: 1.w,
            color: isDark ? const Color(0xFF047857) : const Color(0xFFBBF7D0),
          ),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '$jarak m',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.sp,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Jarak Anda',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isDark
                      ? const Color(0xFFA7F3D0)
                      : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}