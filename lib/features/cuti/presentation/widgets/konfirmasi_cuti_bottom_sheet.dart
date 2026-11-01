import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class KonfirmasiCutiBottomSheet extends StatelessWidget {
  const KonfirmasiCutiBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Deteksi Mode Gelap
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // 2. Definisi Warna Dinamis
    final Color primaryBlue = isDark ? const Color(0xFF3B82F6) : const Color(0xFF135CAE);
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final Color borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE2E8F0);
    final Color bgLightBlue = isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.3) : const Color(0xFFEFF6FF);
    final Color bgSheet = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color cardBg = isDark ? const Color(0xFF121212) : Colors.white;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          left: 24.w,
          right: 24.w,
          top: 12.h,
          bottom: MediaQuery.of(context).padding.bottom + 24.h,
        ),
        decoration: BoxDecoration(
          color: bgSheet,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32.r),
            topRight: Radius.circular(32.r),
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- 1. DRAG HANDLE & TOMBOL CLOSE ---
              Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 48.w,
                      height: 5.h,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF282828) : const Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close, size: 16.w, color: textSecondary),
                      ),
                      onPressed: () => context.pop(), // Tutup Bottom Sheet
                    ),
                  )
                ],
              ),
              SizedBox(height: 12.h),

              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: bgLightBlue,
                  shape: BoxShape.circle,
                  border: Border.all(color: bgSheet, width: 4.w),
                  boxShadow: [
                    BoxShadow(
                      color: primaryBlue.withValues(alpha: isDark ? 0.2 : 0.1),
                      blurRadius: 10.r,
                      spreadRadius: 2.r,
                    )
                  ],
                ),
                child: Icon(Icons.event_available_outlined, color: primaryBlue, size: 32.w),
              ),
              SizedBox(height: 16.h),

              Text(
                'Konfirmasi Pengajuan Cuti',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Pastikan data pengajuan cuti Anda sudah benar sebelum dikirim kepada Admin.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: textSecondary,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 24.h),

              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                      blurRadius: 10.r,
                      offset: Offset(0, 4.h),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Row(
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 18.w, color: primaryBlue),
                        SizedBox(width: 8.w),
                        Text(
                          'Ringkasan Pengajuan',
                          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: textPrimary),
                        ),
                        const Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: bgLightBlue,
                            borderRadius: BorderRadius.circular(5.r),
                          ),
                          child: Text(
                            '3 Hari Kerja',
                            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: primaryBlue),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: Divider(color: borderColor, height: 1.h),
                    ),

                    Text('CUTI KARENA APA', style: _labelStyle(isDark)),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(Icons.business_center_outlined, size: 20.w, color: primaryBlue),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'Keperluan keluarga di luar kota',
                            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: textPrimary),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    Row(
                      children: [
                        Expanded(
                          child: _buildDateCard(
                            label: 'MULAI CUTI',
                            date: '20 Okt 2026',
                            day: 'Selasa',
                            isDark: isDark,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _buildDateCard(
                            label: 'SELESAI CUTI',
                            date: '22 Okt 2026',
                            day: 'Kamis',
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Alasan Cuti
                    Text('ALASAN CUTI', style: _labelStyle(isDark)),
                    SizedBox(height: 8.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: isDark ? const Color(0xFF282828) : const Color(0xFFF1F5F9)),
                      ),
                      child: Text(
                        '“Menghadiri acara pernikahan saudara kandung dan mendampingi keluarga di luar kota.”',
                        style: TextStyle(
                            fontSize: 13.sp,
                            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                            fontStyle: FontStyle.italic,
                            height: 1.5
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.h),

              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.pop();
                    context.push('/cuti-berhasil');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    elevation: 0,
                  ),
                  icon: Icon(Icons.send_outlined, color: Colors.white, size: 18.w),
                  label: Text('Konfirmasi & Kirim', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),

              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: OutlinedButton(
                  onPressed: () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: Text(
                      'Periksa Kembali',
                      style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF334155)
                      )
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle _labelStyle(bool isDark) {
    return TextStyle(
        fontSize: 10.sp,
        fontWeight: FontWeight.bold,
        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8),
        letterSpacing: 0.5
    );
  }

  Widget _buildDateCard({required String label, required String date, required String day, required bool isDark}) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 14.w, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
              SizedBox(width: 6.w),
              Text(label, style: _labelStyle(isDark)),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
              date,
              style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E293B)
              )
          ),
          SizedBox(height: 2.h),
          Text(
              day,
              style: TextStyle(
                  fontSize: 12.sp,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)
              )
          ),
        ],
      ),
    );
  }
}