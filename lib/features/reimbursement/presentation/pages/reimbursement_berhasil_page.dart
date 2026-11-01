import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ReimbursementBerhasilPage extends StatelessWidget {
  const ReimbursementBerhasilPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Deteksi Mode Gelap
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // 2. Definisi Warna Dinamis
    final Color bgApp = isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC);
    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final Color borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFF1F5F9);
    final Color btnBlue = isDark ? const Color(0xFF3B82F6) : const Color(0xFF1E61B6);

    // Warna Lingkaran Pendar
    final Color glowOuter = isDark ? const Color(0xFF064E3B).withValues(alpha: 0.3) : const Color(0xFFF0FDF4);
    final Color glowInner = isDark ? const Color(0xFF064E3B).withValues(alpha: 0.6) : const Color(0xFFDCFCE7);

    return Scaffold(
      backgroundColor: bgApp,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
                child: Column(
                  children: [
                    SizedBox(height: 20.h),

                    // 1. Ikon Sukses dengan Lingkaran Berpendar & Ornamen Titik
                    SizedBox(
                      width: 180.w,
                      height: 180.w,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Ornamen Titik-Titik
                          Positioned(top: 20.h, left: 30.w, child: _buildDot(6.w, const Color(0xFF2DD4BF))),
                          Positioned(top: 10.h, right: 40.w, child: _buildDot(10.w, const Color(0xFF34D399))),
                          Positioned(bottom: 40.h, left: 20.w, child: _buildDot(12.w, const Color(0xFF3B82F6))),
                          Positioned(bottom: 25.h, right: 50.w, child: _buildDot(6.w, const Color(0xFF6EE7B7))),

                          // Lingkaran Pendar Luar
                          Container(
                            width: 150.w,
                            height: 150.w,
                            decoration: BoxDecoration(
                              color: glowOuter,
                              shape: BoxShape.circle,
                            ),
                          ),
                          // Lingkaran Pendar Tengah
                          Container(
                            width: 110.w,
                            height: 110.w,
                            decoration: BoxDecoration(
                              color: glowInner,
                              shape: BoxShape.circle,
                            ),
                          ),
                          // Lingkaran Utama (Hijau Tua)
                          Container(
                            width: 72.w,
                            height: 72.w,
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.5 : 0.3),
                                  blurRadius: 15.r,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Icon(Icons.check, color: Colors.white, size: 40.sp),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // 2. Teks Judul & Subjudul
                    Text(
                      'Pengajuan Reimbursement\nBerhasil',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Pengajuan reimbursement Anda berhasil dikirim',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: textSecondary,
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // 3. Card 1: STATUS PENGAJUAN
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20.r),
                        border: isDark ? Border.all(color: borderColor) : null,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                            blurRadius: 15.r,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 20.h, bottom: 12.h),
                            child: Text(
                              'STATUS PENGAJUAN',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                color: textSecondary,
                              ),
                            ),
                          ),
                          Divider(color: borderColor, thickness: 1.5.h, height: 0),
                          Padding(
                            padding: EdgeInsets.all(20.w),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10.w),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.access_time, color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706), size: 20.sp),
                                ),
                                SizedBox(width: 16.w),
                                Expanded(
                                  child: Text(
                                    'Menunggu Verifikasi Admin',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
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
                    SizedBox(height: 20.h),

                    // 4. Card 2: RINGKASAN PENGAJUAN
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20.r),
                        border: isDark ? Border.all(color: borderColor) : null,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                            blurRadius: 15.r,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Card
                          Row(
                            children: [
                              Icon(Icons.description_outlined, color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF0B56A6), size: 20.sp),
                              SizedBox(width: 8.w),
                              Text(
                                'RINGKASAN PENGAJUAN',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                  color: textPrimary,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.h),

                          // List Item: Pemohon
                          _buildDetailRow('Pemohon Pengajuan', 'Rafid Dwi Putra Andino', isDark),
                          SizedBox(height: 16.h),

                          // List Item: Nominal (Format Khusus Box Abu-abu)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Nominal',
                                style: TextStyle(fontSize: 13.sp, color: textSecondary),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF282828) : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  '350.000',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.bold,
                                    color: textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),

                          // List Item: Tanggal
                          _buildDetailRow('Tanggal Transaksi', '24 Oktober 2026', isDark),
                          SizedBox(height: 16.h),

                          // List Item: Keperluan
                          Text(
                            'Keperluan Pengeluaran',
                            style: TextStyle(fontSize: 13.sp, color: textSecondary),
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: isDark ? const Color(0xFF282828) : const Color(0xFFF1F5F9)),
                            ),
                            child: Text(
                              '"Untuk beli sebuah alat sensor"',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontStyle: FontStyle.italic,
                                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                              ),
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Divider(color: borderColor, thickness: 1.5.h),
                          SizedBox(height: 16.h),

                          // Bukti Transaksi
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Bukti Transaksi',
                                style: TextStyle(fontSize: 13.sp, color: textSecondary),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF064E3B) : const Color(0xFFCCFBF1),
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Text(
                                  'Terlampir',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? const Color(0xFF34D399) : const Color(0xFF0F766E),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),

                          // File Box
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10.w),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.5) : const Color(0xFFDBEAFE),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Icon(Icons.image_outlined, color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF1D4ED8), size: 24.sp),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  'struk-nota-konsumsi.jpg',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 5. Tombol Kembali ke Beranda (Sticky Bottom)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              decoration: BoxDecoration(
                color: bgApp,
                border: isDark ? Border(top: BorderSide(color: borderColor)) : null,
              ),
              child: SizedBox(
                height: 52.h,
                child: ElevatedButton(
                  onPressed: () {
                    // Redirect kembali ke halaman beranda
                    context.go('/beranda');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: btnBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.home_outlined, color: Colors.white, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'Kembali ke Beranda',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Helper Ornamen Titik
  Widget _buildDot(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  // Widget Helper Baris Detail (Kiri - Kanan)
  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13.sp, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
        ),
        SizedBox(width: 16.w), // Memberi jarak agar nama tidak menabrak label
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }
}