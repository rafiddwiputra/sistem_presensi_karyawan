import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../presentation/pages/presensi_berhasil_page.dart';

class KonfirmasiPresensiBottomSheet extends StatelessWidget {
  const KonfirmasiPresensiBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Deteksi Mode Gelap
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // 2. Definisi Warna Dinamis
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final Color primaryBlue = isDark ? const Color(0xFF1961B6) : const Color(0xFF135CAE);
    final Color bgSheet = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return ConstrainedBox(
      // KUNCI PERBAIKANNYA DI SINI: Membatasi tinggi maksimal 85% dari layar HP
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 24.w), // Memberikan padding seragam di samping
        decoration: BoxDecoration(
          color: bgSheet,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 12.h), // Spasi atas untuk handle bar
            // Handle Bar (Garis abu-abu di atas)
            Container(
              width: 40.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF333333) : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            SizedBox(height: 24.h),

            // Ikon Ceklis Hijau
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check, color: isDark ? const Color(0xFF34D399) : const Color(0xFF10B981), size: 28.w),
            ),
            SizedBox(height: 16.h),

            // Judul & Subjudul
            Text(
              'Konfirmasi Presensi Masuk',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: textPrimary),
            ),
            SizedBox(height: 8.h),
            Text(
              'Pastikan data presensi Anda sudah benar sebelum melanjutkan.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.sp, color: textSecondary),
            ),
            SizedBox(height: 24.h),

            // Kartu Lokasi Valid
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF064E3B).withValues(alpha: 0.5) : const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: isDark ? const Color(0xFF047857) : const Color(0xFFBBF7D0), width: 1.w),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF047857) : const Color(0xFFBBF7D0),
                        shape: BoxShape.circle
                    ),
                    child: Icon(Icons.check, color: isDark ? Colors.white : const Color(0xFF065F46), size: 12.w),
                  ),
                  SizedBox(width: 12.w),
                  Text('Lokasi Valid', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFFA7F3D0) : const Color(0xFF065F46))),
                  const Spacer(),
                  // Badge "15 M dari kantor"
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF047857) : const Color(0xFFD1FAE5),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text('15 M dari kantor', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFFA7F3D0) : const Color(0xFF065F46))),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Bagian Detail Presensi
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'DETAIL PRESENSI',
                style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: textSecondary),
              ),
            ),
            SizedBox(height: 12.h),

            // Kotak Detail Karyawan
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12.r),
                border: isDark ? Border.all(color: const Color(0xFF333333), width: 1.w) : null,
              ),
              child: Column(
                children: [
                  _buildDetailRow('Nama Karyawan', Text('Sigit', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: textPrimary)), isDark: isDark),
                  _buildDetailRow('Tanggal Presensi', Text('Senin, 28 September 2026', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: textPrimary)), isDark: isDark),
                  _buildDetailRow('Waktu Presensi', Text('07:45 WIB', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: textPrimary)), isDark: isDark),
                  _buildDetailRow(
                    'Jenis Presensi',
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E3A8A) : const Color(0xFFDBEAFE),
                          borderRadius: BorderRadius.circular(4.r)
                      ),
                      child: Text('Masuk', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF1D4ED8))),
                    ),
                    isDark: isDark,
                  ),
                  _buildDetailRow('Lokasi Kantor', Text('Cyber Olympus Software House', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: textPrimary)), isLast: true, isDark: isDark),
                ],
              ),
            ),
            SizedBox(height: 32.h),

            // Tombol Konfirmasi Presensi
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PresensiBerhasilPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  elevation: 0,
                ),
                child: Text('Konfirmasi Presensi', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            SizedBox(height: 16.h),

            // Tombol Batalkan
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batalkan', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: textSecondary)),
            ),
            SizedBox(height: 24.h), // Jarak lega di bagian paling bawah perangkat
          ],
        ),
      ),
    );
  }

  // Fungsi Helper untuk membuat baris detail yang rapi
  Widget _buildDetailRow(String label, Widget valueWidget, {bool isLast = false, required bool isDark}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text(label, style: TextStyle(fontSize: 12.sp, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)))),
          Expanded(flex: 3, child: Align(alignment: Alignment.centerRight, child: valueWidget)),
        ],
      ),
    );
  }
}