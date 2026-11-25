import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class TentangAplikasiPage extends StatelessWidget {
  const TentangAplikasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color headerBlue =
    isDark ? const Color(0xFF154B8C) : const Color(0xFF1E61B6);
    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color borderColor =
    isDark ? const Color(0xFF333333) : const Color(0xFFE2E8F0);
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color textSecondary =
    isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // App Bar Solid Blue
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16.h,
              bottom: 16.h,
              left: 20.w,
              right: 20.w,
            ),
            color: headerBlue,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Text(
                  'Tentang Aplikasi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Konten Utama
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kartu Identitas Aplikasi
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: isDark ? 0.2 : 0.03),
                          blurRadius: 12.r,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16.r),
                          child: Image.asset(
                            'assets/images/logo.jpeg',
                            width: 64.w,
                            height: 64.w,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 64.w,
                              height: 64.w,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E61B6),
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: Icon(
                                Icons.fingerprint_rounded,
                                color: Colors.white,
                                size: 34.sp,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 14.h),
                        Text(
                          'Sistem Presensi Karyawan',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E3A8A)
                                : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            'Versi 1.0.0 (Build 1)',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? const Color(0xFF60A5FA)
                                  : const Color(0xFF1E61B6),
                            ),
                          ),
                        ),
                        SizedBox(height: 14.h),
                        Text(
                          'Aplikasi resmi manajemen kehadiran dan administrasi kepegawaian untuk pencatatan presensi berbasis GPS maupun mesin IoT Fingerprint, rekapitulasi jam kerja, serta pengajuan izin, cuti, lembur, dan reimbursement.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Section Fitur Utama
                  _buildSectionTitle('FITUR UTAMA', textSecondary),
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      children: [
                        _buildFeatureRow(
                          icon: Icons.location_on_outlined,
                          title: 'Presensi Multi-Metode',
                          description:
                          'Mendukung presensi masuk/keluar melalui geofencing GPS smartphone dan sinkronisasi otomatis mesin IoT Fingerprint.',
                          isDark: isDark,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                        _buildDivider(isDark),
                        _buildFeatureRow(
                          icon: Icons.assignment_turned_in_outlined,
                          title: 'Pengajuan & Persetujuan Digital',
                          description:
                          'Pengajuan izin, cuti, lembur, serta klaim reimbursement lengkap dengan lampiran dokumen dan bukti transfer admin.',
                          isDark: isDark,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                        _buildDivider(isDark),
                        _buildFeatureRow(
                          icon: Icons.bar_chart_rounded,
                          title: 'Rekapitulasi & Notifikasi Real-Time',
                          description:
                          'Pemantauan riwayat kehadiran bulanan, durasi keterlambatan, lembur, serta pemberitahuan status pengajuan.',
                          isDark: isDark,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Section Ketentuan Layanan & Kebijakan Privasi
                  _buildSectionTitle(
                    'KETENTUAN LAYANAN & KEBIJAKAN PRIVASI',
                    textSecondary,
                  ),
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPolicyItem(
                          title: '1. Penggunaan Data Lokasi (GPS)',
                          body:
                          'Akses lokasi hanya digunakan saat karyawan melakukan perekaman presensi masuk atau keluar untuk memverifikasi radius area kerja yang ditetapkan perusahaan.',
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                        SizedBox(height: 14.h),
                        _buildPolicyItem(
                          title: '2. Penyimpanan Lampiran & Bukti',
                          body:
                          'Dokumen surat keterangan izin, struk reimbursement, dan bukti transfer disimpan secara terenkripsi pada server internal dan hanya dapat diakses oleh pihak berwenang.',
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                        SizedBox(height: 14.h),
                        _buildPolicyItem(
                          title: '3. Keamanan Akun Karyawan',
                          body:
                          'Setiap karyawan bertanggung jawab menjaga kerahasiaan kredensial akun pribadi dan dianjurkan memperbarui kata sandi secara berkala melalui menu Keamanan Akun.',
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 28.h),

                  // Hak Cipta
                  Center(
                    child: Text(
                      '© 2026 Sistem Presensi Karyawan • Hak Cipta Dilindungi',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: textSecondary,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 12.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.6,
          color: color,
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Divider(
        color: isDark ? const Color(0xFF333333) : const Color(0xFFF1F5F9),
        height: 1,
      ),
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required String title,
    required String description,
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38.w,
          height: 38.w,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF282828) : const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            icon,
            size: 20.sp,
            color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF1E61B6),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPolicyItem({
    required String title,
    required String body,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          body,
          style: TextStyle(
            fontSize: 12.sp,
            color: textSecondary,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}