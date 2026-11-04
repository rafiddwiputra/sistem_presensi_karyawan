import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_colors.dart';
import '../widgets/menu_card.dart';
import 'package:sistem_presensi_karyawan/features/profil/presentation/bloc/profil_bloc.dart';
import 'package:sistem_presensi_karyawan/features/profil/presentation/bloc/profil_state.dart';
import '../../../../core/widgets/authenticated_profile_image.dart';

class BerandaPage extends StatelessWidget {
  const BerandaPage({super.key});

  String _getFormattedDate() {
    final now = DateTime.now();
    final List<String> months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    final List<String> days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];

    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Stack(
          children: [
            Positioned(
              top: -500,
              left: 0,
              right: 0,
              child: Container(
                height: 500 + 210.h,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF154B8C) : const Color(0xFF1961B6),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40.r),
                    bottomRight: Radius.circular(40.r),
                  ),
                ),
              ),
            ),

            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 60.h, left: 24.w, right: 24.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Langsung membaca data dari ProfilBloc Global di RAM
                      BlocBuilder<ProfilBloc, ProfilState>(
                        builder: (context, state) {
                          String namaPanggilan = 'Karyawan';
                          String? fotoProfilUrl;

                          if (state is ProfilLoaded) {
                            String namaLengkap = state.user['nama'] ?? 'Karyawan';
                            namaPanggilan = namaLengkap.split(' ').first;
                            fotoProfilUrl = state.user['foto_url'];
                          }

                          return Row(
                            children: [
                              // MENGGUNAKAN WIDGET CUSTOM KITA:
                              AuthenticatedProfileImage(
                                imagePath: fotoProfilUrl,
                                size: 50.w,
                                isDark: isDark,
                                borderWidth: 2.0, // Border lebih tipis untuk ukuran Beranda
                              ),
                              SizedBox(width: 12.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hi, $namaPanggilan',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Fullstack Dev & Database Administrator',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFFFCD34D),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),

                      GestureDetector(
                        onTap: () => context.push('/notifikasi'),
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF282828) : Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Stack(
                            children: [
                              Icon(Icons.notifications_none, color: isDark ? Colors.white : AppColors.textPrimary),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: CircleAvatar(radius: 4.r, backgroundColor: AppColors.error),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                Text(
                  _getFormattedDate(),
                  style: TextStyle(fontSize: 14.sp, color: Colors.white),
                ),

                SizedBox(height: 42.h),

                Padding(
                  padding: EdgeInsets.only(left: 24.w, right: 24.w, bottom: 100.h),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 24.w),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                          borderRadius: BorderRadius.circular(24.r),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                                blurRadius: 15.r,
                                spreadRadius: 2.r,
                                offset: const Offset(0, 5)
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10.w),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0EA5E9).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(24.r),
                                  ),
                                  child: const Icon(Icons.login, color: Color(0xFF0EA5E9)),
                                ),
                                SizedBox(width: 12.w),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Jam Masuk', style: TextStyle(fontSize: 12.sp, color: const Color(0xFF0EA5E9), fontWeight: FontWeight.bold)),
                                    Text('08.00', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textPrimary)),
                                  ],
                                ),
                              ],
                            ),
                            Container(height: 40.h, width: 1.w, color: isDark ? const Color(0xFF333333) : AppColors.border),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10.w),
                                  decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12.r)),
                                  child: const Icon(Icons.logout, color: AppColors.error),
                                ),
                                SizedBox(width: 12.w),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Jam Selesai', style: TextStyle(fontSize: 12.sp, color: AppColors.error, fontWeight: FontWeight.bold)),
                                    Text('--.--', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 32.h),

                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 16.w,
                        mainAxisSpacing: 16.h,
                        childAspectRatio: 0.95,
                        children: [
                          MenuCard(
                            title: 'IZIN',
                            subtitle: 'Izin bulan ini',
                            count: '2',
                            backgroundColor: isDark ? const Color(0xFF282828) : const Color(0xFFF1F0FD),
                            iconBackgroundColor: const Color(0xFF5E548E),
                            icon: Icons.mail_outline,
                            onTap: () => context.push('/izin'),
                          ),
                          MenuCard(
                            title: 'CUTI',
                            subtitle: 'Cuti bulan ini',
                            count: '1',
                            backgroundColor: isDark ? const Color(0xFF282828) : const Color(0xFFE9F6F1),
                            iconBackgroundColor: const Color(0xFF3B8365),
                            icon: Icons.calendar_today_outlined,
                            onTap: () => context.push('/cuti'),
                          ),
                          MenuCard(
                            title: 'LEMBUR',
                            subtitle: 'Pengajuan lembur',
                            count: '0',
                            backgroundColor: isDark ? const Color(0xFF282828) : const Color(0xFFFFF3E0),
                            iconBackgroundColor: const Color(0xFFE65100),
                            icon: Icons.access_time,
                            onTap: () => context.push('/lembur'),
                          ),
                          MenuCard(
                            title: 'REIMBURSEMENT',
                            subtitle: 'Reimburs bulan ini',
                            count: '0',
                            backgroundColor: isDark ? const Color(0xFF282828) : const Color(0xFFFDEFF4),
                            iconBackgroundColor: const Color(0xFF9E3E6E),
                            icon: Icons.receipt_long_outlined,
                            onTap: () => context.push('/reimbursement'),
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
    );
  }
}