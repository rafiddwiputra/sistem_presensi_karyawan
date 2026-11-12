import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class CutiBerhasilPage extends StatelessWidget {
  final String namaKaryawan;
  final String jenisCuti;
  final String keterangan;
  final DateTime tanggalMulai;
  final DateTime tanggalSelesai;

  const CutiBerhasilPage({
    super.key,
    required this.namaKaryawan,
    required this.jenisCuti,
    required this.keterangan,
    required this.tanggalMulai,
    required this.tanggalSelesai,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Deteksi Mode Gelap
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // 2. Definisi Warna Dinamis
    final Color bgApp = Theme.of(context).scaffoldBackgroundColor;
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color textSecondary = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final Color primaryBlue = isDark
        ? const Color(0xFF3B82F6)
        : const Color(0xFF1D4ED8);
    final Color borderGrey = isDark
        ? const Color(0xFF333333)
        : const Color(0xFFE2E8F0);
    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    // 3. Konversi Tanggal dan Durasi
    final int durasiHari = tanggalSelesai.difference(tanggalMulai).inDays + 1;
    final String labelMulai = DateFormat(
      'dd MMM',
      'id_ID',
    ).format(tanggalMulai);
    final String labelSelesai = DateFormat(
      'dd MMM yyyy',
      'id_ID',
    ).format(tanggalSelesai);
    final String rentangWaktu = '$labelMulai - $labelSelesai';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: bgApp,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 32.h,
                  ),
                  child: Column(
                    children: [
                      // --- 1. ILUSTRASI SUKSES (Ceklis Hijau & Confetti) ---
                      _buildSuccessIllustration(isDark),
                      SizedBox(height: 24.h),

                      // --- 2. TEKS JUDUL & SUBJUDUL ---
                      Text(
                        'Pengajuan Cuti Berhasil!',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Text(
                          'Permohonan cuti Anda telah dikirim dan saat ini menunggu persetujuan dari pihak Admin.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ),
                      SizedBox(height: 32.h),

                      // --- 3. KARTU STATUS PENGAJUAN ---
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16.r),
                          border: isDark ? Border.all(color: borderGrey) : null,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? 0.2 : 0.02,
                              ),
                              blurRadius: 10.r,
                              offset: Offset(0, 4.h),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'STATUS PENGAJUAN',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF94A3B8),
                                letterSpacing: 0.5,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              child: Divider(color: borderGrey, height: 1.h),
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10.w),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF451A03)
                                        : const Color(0xFFFEF3C7),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.access_time_filled,
                                    color: isDark
                                        ? const Color(0xFFFBBF24)
                                        : const Color(0xFFD97706),
                                    size: 20.w,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Text(
                                  'Menunggu Verifikasi Admin',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // --- 4. KARTU RINGKASAN PENGAJUAN ---
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16.r),
                          border: isDark ? Border.all(color: borderGrey) : null,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? 0.2 : 0.02,
                              ),
                              blurRadius: 10.r,
                              offset: Offset(0, 4.h),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Kartu Ringkasan
                            Row(
                              children: [
                                Icon(
                                  Icons.description_outlined,
                                  color: primaryBlue,
                                  size: 18.w,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'RINGKASAN PENGAJUAN',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.bold,
                                    color: textPrimary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              child: Divider(color: borderGrey, height: 1.h),
                            ),

                            // Nama Karyawan
                            _buildInfoRow(
                              'Nama Karyawan',
                              customValue: Text(
                                namaKaryawan, // <-- Menggunakan Variabel Dinamis
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary,
                                ),
                              ),
                              isDark: isDark,
                            ),
                            SizedBox(height: 16.h),

                            // Cuti Karena?
                            _buildInfoRow(
                              'Cuti Karena?',
                              customValue: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF333333)
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  jenisCuti, // <-- Menggunakan Variabel Dinamis
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    color: textPrimary,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              isDark: isDark,
                            ),
                            SizedBox(height: 16.h),

                            // Rentang Waktu
                            _buildInfoRow(
                              'Rentang Waktu',
                              customValue: Wrap(
                                alignment: WrapAlignment.end,
                                children: [
                                  Text(
                                    '$rentangWaktu ', // <-- Tanggal Dinamis
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                      color: textPrimary,
                                    ),
                                  ),
                                  Text(
                                    '($durasiHari Hari)', // <-- Durasi Dinamis
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              isDark: isDark,
                            ),
                            SizedBox(height: 16.h),

                            // Keterangan
                            Text(
                              'Keterangan:',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: textSecondary,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF121212)
                                    : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                '"$keterangan"', // <-- Alasan Dinamis
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontStyle: FontStyle.italic,
                                  color: textPrimary,
                                  height: 1.4,
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

              // --- 5. TOMBOL KEMBALI KE BERANDA ---
              Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                decoration: const BoxDecoration(color: Colors.transparent),
                child: SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: () {
                      context.go('/beranda');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          primaryBlue, // Konsisten dengan tema aplikasi
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Kembali ke Beranda',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 18.w,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildSuccessIllustration(bool isDark) {
    return SizedBox(
      width: 120.w,
      height: 120.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 100.w,
            height: 100.w,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF064E3B)
                  : const Color(0xFFD1FAE5).withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 72.w,
            height: 72.w,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.3)
                      : const Color(0xFF10B981).withValues(alpha: 0.3),
                  blurRadius: 20.r,
                  offset: Offset(0, 8.h),
                ),
              ],
            ),
            child: Icon(Icons.check, color: Colors.white, size: 40.w),
          ),
          Positioned(
            top: 10.h,
            left: 10.w,
            child: _buildDot(
              isDark ? const Color(0xFF34D399) : const Color(0xFF6EE7B7),
              8.w,
            ),
          ),
          Positioned(
            top: 20.h,
            right: 10.w,
            child: _buildDot(
              isDark ? const Color(0xFF60A5FA) : const Color(0xFF93C5FD),
              6.w,
            ),
          ),
          Positioned(
            bottom: 10.h,
            left: 25.w,
            child: _buildDot(
              isDark ? const Color(0xFFFBBF24) : const Color(0xFFFCD34D),
              6.w,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildInfoRow(
    String label, {
    required Widget customValue,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Align(alignment: Alignment.centerRight, child: customValue),
        ),
      ],
    );
  }
}
