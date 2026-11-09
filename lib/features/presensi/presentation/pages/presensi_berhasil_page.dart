import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/date_formatter.dart';

class PresensiBerhasilPage extends StatelessWidget {
  // Tambahkan parameter untuk menangkap data dari halaman sebelumnya
  final String namaKaryawan;
  final String lokasiKantor;
  final String jenisPresensi;
  final String jarakMeter;
  final DateTime waktuPresensi;

  const PresensiBerhasilPage({
    super.key,
    required this.namaKaryawan,
    required this.lokasiKantor,
    required this.jenisPresensi,
    required this.jarakMeter,
    required this.waktuPresensi,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color textSecondary = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final String alamatKantor = lokasiKantor != '-'
        ? 'Koordinat Terverifikasi'
        : '-';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        // Hapus BlocBuilder, gunakan data langsung dari parameter
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
                child: Column(
                  children: [
                    // 1. Ikon Ceklis Berlapis dengan Ornamen Titik
                    SizedBox(
                      width: 140.w,
                      height: 140.w,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 120.w,
                            height: 120.w,
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981)
                                  .withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Container(
                            width: 90.w,
                            height: 90.w,
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981)
                                  .withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Container(
                            width: 70.w,
                            height: 70.w,
                            decoration: const BoxDecoration(
                              color: Color(0xFF22C55E),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 40.w,
                            ),
                          ),
                          Positioned(
                            bottom: 20.h,
                            left: 10.w,
                            child: CircleAvatar(
                              radius: 4.r,
                              backgroundColor: const Color(0xFF3B82F6),
                            ),
                          ),
                          Positioned(
                            top: 20.h,
                            left: 20.w,
                            child: CircleAvatar(
                              radius: 3.r,
                              backgroundColor: const Color(0xFF22C55E),
                            ),
                          ),
                          Positioned(
                            top: 10.h,
                            right: 30.w,
                            child: CircleAvatar(
                              radius: 4.r,
                              backgroundColor: const Color(0xFF6EE7B7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // 2. Teks Judul
                    Text(
                      'Presensi Berhasil!',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Presensi $jenisPresensi kamu telah berhasil dicatat ke\nsistem.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: textSecondary,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // 3. Kartu Detail Presensi
                    Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.3 : 0.03,
                            ),
                            blurRadius: 20.r,
                            offset: Offset(0, 4.h),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Header Kartu
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF1E3A8A)
                                      : const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Icon(
                                  Icons.receipt_long_outlined,
                                  color: isDark
                                      ? const Color(0xFF60A5FA)
                                      : const Color(0xFF3B82F6),
                                  size: 16.w,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                'DETAIL PRESENSI',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: textSecondary,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF064E3B)
                                      : const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(5.r),
                                  border: Border.all(
                                    color: isDark
                                        ? const Color(0xFF047857)
                                        : const Color(0xFFA7F3D0),
                                    width: 1.w,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: isDark
                                          ? const Color(0xFF34D399)
                                          : const Color(0xFF10B981),
                                      size: 12.w,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      'Berhasil',
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? const Color(0xFF34D399)
                                            : const Color(0xFF10B981),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24.h),

                          // List Detail Dinamis
                          _buildDetailRow(
                            'Nama Karyawan',
                            Text(
                              namaKaryawan,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ),
                            isDark: isDark,
                          ),
                          _buildDetailRow(
                            'Tanggal Presensi',
                            Text(
                              DateFormatter.formatWithDay(
                                waktuPresensi.toIso8601String(),
                              ),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: textPrimary,
                              ),
                            ),
                            isDark: isDark,
                          ),
                          _buildDetailRow(
                            'Waktu Presensi',
                            Text(
                              '${DateFormatter.currentTime()} WIB',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ),
                            isDark: isDark,
                          ),
                          _buildDetailRow(
                            'Jenis Presensi',
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1E3A8A)
                                    : const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(5.r),
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0xFF1E3A8A)
                                      : const Color(0xFFDBEAFE),
                                  width: 1.w,
                                ),
                              ),
                              child: Text(
                                jenisPresensi,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? const Color(0xFF60A5FA)
                                      : const Color(0xFF3B82F6),
                                ),
                              ),
                            ),
                            isDark: isDark,
                          ),

                          // Lokasi Kantor Dinamis
                          Padding(
                            padding: EdgeInsets.only(bottom: 16.h),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Lokasi Kantor',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: isDark
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF94A3B8),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        lokasiKantor,
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                          color: textPrimary,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        alamatKantor,
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          color: isDark
                                              ? const Color(0xFF64748B)
                                              : const Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Divider(
                            color: isDark
                                ? const Color(0xFF333333)
                                : const Color(0xFFF1F5F9),
                            thickness: 1.h,
                            height: 24.h,
                          ),

                          // Alert Lokasi Tervalidasi Dinamis
                          Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF064E3B)
                                        .withValues(alpha: 0.5)
                                  : const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF047857)
                                    : const Color(0xFFBBF7D0),
                                width: 1.w,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8.w),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF047857)
                                        : const Color(0xFFD1FAE5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.location_on_outlined,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF059669),
                                    size: 16.w,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Lokasi tervalidasi',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? const Color(0xFFA7F3D0)
                                              : const Color(0xFF065F46),
                                        ),
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        'Presensi dalam radius ($jarakMeter M dari kantor).',
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          color: isDark
                                              ? const Color(0xFF6EE7B7)
                                              : const Color(0xFF059669),
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
                  ],
                ),
              ),
            ),

            // 4. Tombol Kembali ke Beranda
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: const BoxDecoration(color: Colors.transparent),
              child: SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/beranda');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D6EFD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    elevation: isDark ? 0 : 8,
                    shadowColor: isDark
                        ? Colors.transparent
                        : const Color(0xFF0D6EFD).withValues(alpha: 0.4),
                  ),
                  child: Text(
                    'Kembali ke Beranda',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    Widget valueWidget, {
    required bool isDark,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF94A3B8),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Align(alignment: Alignment.centerRight, child: valueWidget),
          ),
        ],
      ),
    );
  }
}
