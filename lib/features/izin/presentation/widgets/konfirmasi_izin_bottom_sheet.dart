import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class KonfirmasiIzinBottomSheet extends StatelessWidget {
  const KonfirmasiIzinBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Deteksi Mode Gelap
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // 2. Definisi Warna Dinamis
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final Color primaryBlue = isDark ? const Color(0xFF60A5FA) : const Color(0xFF135CAE);
    final Color bgSheet = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color bgGrey = isDark ? const Color(0xFF121212) : const Color(0xFFF4F7FA);
    final Color borderGrey = isDark ? const Color(0xFF333333) : const Color(0xFFE2E8F0);
    final Color cardBg = isDark ? const Color(0xFF121212) : Colors.white;

    // PENAMBAHAN CONSTRAINEDBOX ADA DI SINI
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: bgSheet,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Menyesuaikan tinggi dengan isi konten
          children: [
            // --- HEADER & DRAG HANDLE ---
            Padding(
              padding: EdgeInsets.only(top: 12.h, right: 16.w, left: 16.w),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Drag Handle
                  Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(4.r)
                    ),
                  ),
                  // Tombol Close
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(Icons.close, color: textSecondary, size: 24.w),
                      onPressed: () => context.pop(),
                    ),
                  ),
                ],
              ),
            ),

            // --- KONTEN SCROLLABLE ---
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    // Ikon Tas/Clipboard dengan Badge Ceklis Hijau
                    SizedBox(
                      width: 64.w,
                      height: 64.w,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 56.w,
                            height: 56.w,
                            decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.5) : const Color(0xFFEFF6FF),
                                shape: BoxShape.circle
                            ),
                            child: Icon(Icons.assignment_turned_in_outlined, color: primaryBlue, size: 28.w),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(2.w),
                              decoration: BoxDecoration(color: bgSheet, shape: BoxShape.circle),
                              child: Container(
                                padding: EdgeInsets.all(4.w),
                                decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                                child: Icon(Icons.check, color: Colors.white, size: 10.w),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Judul & Subjudul
                    Text('Konfirmasi Pengajuan Izin', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: textPrimary)),
                    SizedBox(height: 8.h),
                    Text(
                      'Periksa kembali data pengajuan Anda sebelum\ndikirim ke Admin.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13.sp, color: textSecondary, height: 1.5),
                    ),
                    SizedBox(height: 24.h),

                    // --- KARTU 1: RINGKASAN PENGAJUAN ---
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: borderGrey),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                              blurRadius: 10.r,
                              offset: Offset(0, 4.h)
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Kartu
                          Row(
                            children: [
                              Icon(Icons.receipt_long_outlined, color: primaryBlue, size: 18.w),
                              SizedBox(width: 8.w),
                              Text('Ringkasan Pengajuan', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: textPrimary)),
                              const Spacer(),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1E3A8A) : const Color(0xFFE0E7FF),
                                    borderRadius: BorderRadius.circular(5.r)
                                ),
                                child: Text('2 Hari', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: primaryBlue)),
                              ),
                            ],
                          ),
                          Padding(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              child: Divider(color: borderGrey, height: 1.h)
                          ),

                          // Detail Karyawan
                          _buildDetailRow(icon: Icons.person_outline, label: 'Nama Karyawan', value: 'Rafid Dwi Putra Andino', isDark: isDark),
                          SizedBox(height: 16.h),

                          // Detail Kategori
                          _buildDetailRow(
                              icon: Icons.medical_services_outlined,
                              label: 'Izin Karena?',
                              value: 'Sakit',
                              isDark: isDark
                          ),
                          SizedBox(height: 16.h),

                          // Detail Tanggal (Baris 2 Kolom)
                          Row(
                            children: [
                              Expanded(child: _buildDateDetail(icon: Icons.calendar_today_outlined, label: 'Tanggal Mulai', date: '28 Sep 2026', day: 'Senin', isDark: isDark)),
                              Expanded(child: _buildDateDetail(icon: Icons.event_available_outlined, label: 'Tanggal Selesai', date: '29 Sep 2026', day: 'Selasa', isDark: isDark)),
                            ],
                          ),
                          SizedBox(height: 16.h),

                          // Detail Alasan Izin
                          Text('Alasan / Catatan Izin', style: TextStyle(fontSize: 11.sp, color: textSecondary)),
                          SizedBox(height: 6.h),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(color: bgGrey, borderRadius: BorderRadius.circular(12.r)),
                            child: Text(
                              '"Demam tinggi dan flu sejak kemarin malam, disarankan dokter istirahat total 2 hari."',
                              style: TextStyle(fontSize: 13.sp, fontStyle: FontStyle.italic, color: textPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // --- KARTU 2: LAMPIRAN BUKTI ---
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: borderGrey),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                              blurRadius: 10.r,
                              offset: Offset(0, 4.h)
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          // Header Lampiran
                          Row(
                            children: [
                              Icon(Icons.attach_file, color: primaryBlue, size: 18.w),
                              SizedBox(width: 8.w),
                              Text('Lampiran Bukti Izin', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: textPrimary)),
                              const Spacer(),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5),
                                    borderRadius: BorderRadius.circular(12.r)
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.check_circle, color: isDark ? const Color(0xFF34D399) : const Color(0xFF059669), size: 12.w),
                                    SizedBox(width: 4.w),
                                    Text('Terlampir', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF34D399) : const Color(0xFF059669))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),

                          // Kotak File Terlampir
                          Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(color: bgGrey, borderRadius: BorderRadius.circular(12.r)),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8.w),
                                  decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF4C0519) : const Color(0xFFFFE4E6),
                                      borderRadius: BorderRadius.circular(8.r)
                                  ),
                                  child: Icon(Icons.picture_as_pdf, color: isDark ? const Color(0xFFFDA4AF) : const Color(0xFFE11D48), size: 24.w),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Surat_Keterangan_Dokter.pdf', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      SizedBox(height: 2.h),
                                      Text('1.4 MB', style: TextStyle(fontSize: 11.sp, color: textSecondary)),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Container(
                                  padding: EdgeInsets.all(4.w),
                                  decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF0F766E) : const Color(0xFF0D9488),
                                      shape: BoxShape.circle
                                  ),
                                  child: Icon(Icons.check, color: Colors.white, size: 16.w),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // --- TOMBOL AKSI ---
                    SizedBox(
                      width: double.infinity,
                      height: 52.h,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.pop();
                          context.go('/izin-berhasil');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? const Color(0xFF3B82F6) : const Color(0xFF135CAE),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          elevation: 0,
                        ),
                        icon: Icon(Icons.send_outlined, color: Colors.white, size: 18.w),
                        label: Text('Konfirmasi & Kirim Izin', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    SizedBox(
                      width: double.infinity,
                      height: 52.h,
                      child: TextButton(
                        onPressed: () => context.pop(),
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        child: Text('Periksa Kembali', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: textSecondary)),
                      ),
                    ),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget untuk Baris Detail
  Widget _buildDetailRow({required IconData icon, required String label, required String value, Color? valueColor, Widget? trailingBadge, required bool isDark}) {
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final Color iconBg = isDark ? const Color(0xFF282828) : const Color(0xFFF1F5F9);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, color: textSecondary, size: 20.w),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11.sp, color: textSecondary)),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Text(value, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: valueColor ?? textPrimary)),
                  if (trailingBadge != null) ...[
                    SizedBox(width: 8.w),
                    trailingBadge,
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper Widget untuk Detail Tanggal
  Widget _buildDateDetail({required IconData icon, required String label, required String date, required String day, required bool isDark}) {
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final Color primaryBlue = isDark ? const Color(0xFF60A5FA) : const Color(0xFF135CAE);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: primaryBlue, size: 18.w),
        SizedBox(width: 8.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 10.sp, color: textSecondary)),
            SizedBox(height: 2.h),
            Text(date, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: textPrimary)),
            Text(day, style: TextStyle(fontSize: 11.sp, color: textSecondary)),
          ],
        ),
      ],
    );
  }
}