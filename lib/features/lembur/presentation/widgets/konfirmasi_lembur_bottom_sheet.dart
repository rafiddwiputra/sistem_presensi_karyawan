import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class KonfirmasiLemburBottomSheet extends StatelessWidget {
  const KonfirmasiLemburBottomSheet({super.key});

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
                      onPressed: () => context.pop(),
                    ),
                  )
                ],
              ),
              SizedBox(height: 12.h),

              SizedBox(
                width: 72.w,
                height: 72.w,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 64.w,
                      height: 64.w,
                      decoration: BoxDecoration(
                        color: bgLightBlue,
                        shape: BoxShape.circle,
                        border: Border.all(color: bgSheet, width: 4.w),
                      ),
                      child: Icon(Icons.access_time, color: primaryBlue, size: 32.w),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: bgSheet,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.verified, color: const Color(0xFF2DD4BF), size: 18.w),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              Text(
                'Konfirmasi Pengajuan Lembur',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: textPrimary),
              ),
              SizedBox(height: 8.h),
              Text(
                'Periksa kembali detail pengajuan lembur Anda sebelum dikirim.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.sp, color: textSecondary, height: 1.5),
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
                            'Durasi 4 Jam',
                            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: primaryBlue),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),

                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: bgLightBlue,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(Icons.badge_outlined, color: primaryBlue, size: 20.w),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Pemohon Lembur', style: TextStyle(fontSize: 11.sp, color: textSecondary)),
                              SizedBox(height: 2.h),
                              Text('Rafid Dwi Putra Andino', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: textPrimary)),
                            ],
                          ),
                        ),
                      ],
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: Divider(color: borderColor, height: 1.h),
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(color: bgLightBlue, borderRadius: BorderRadius.circular(8.r)),
                                child: Icon(Icons.calendar_today_outlined, color: primaryBlue, size: 16.w),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Tanggal Lembur', style: TextStyle(fontSize: 11.sp, color: textSecondary)),
                                    SizedBox(height: 2.h),
                                    Text('24 Okt 2026', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: textPrimary)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(color: bgLightBlue, borderRadius: BorderRadius.circular(8.r)),
                                child: Icon(Icons.access_time, color: primaryBlue, size: 16.w),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Waktu Lembur', style: TextStyle(fontSize: 11.sp, color: textSecondary)),
                                    SizedBox(height: 2.h),
                                    Text('18:00 – 21:30', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: textPrimary)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),

                    Text('ALASAN LEMBUR:', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: textSecondary, letterSpacing: 0.5)),
                    SizedBox(height: 8.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: isDark ? const Color(0xFF282828) : const Color(0xFFF1F5F9)),
                      ),
                      child: Text(
                        '“Deployment Project Laravel & Konfigurasi Server”',
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
                    context.push('/lembur-berhasil');
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
              SizedBox(height: 8.h),
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: TextButton(
                  onPressed: () => context.pop(),
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: Text(
                      'Periksa Kembali',
                      style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF475569)
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
}