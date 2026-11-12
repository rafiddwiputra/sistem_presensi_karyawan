import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

// Import yang diperlukan untuk memanggil Data dari BLoC
import '../../../../core/di/injection.dart';
import '../bloc/riwayat_bloc.dart';
import '../bloc/riwayat_event.dart';
import '../bloc/riwayat_state.dart';

class RekapPresensiPage extends StatelessWidget {
  const RekapPresensiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RiwayatBloc>()..add(LoadRiwayatRequested(DateTime.now())),
      child: const RekapPresensiView(),
    );
  }
}

class RekapPresensiView extends StatefulWidget {
  const RekapPresensiView({super.key});

  @override
  State<RekapPresensiView> createState() => _RekapPresensiViewState();
}

class _RekapPresensiViewState extends State<RekapPresensiView> {
  // Fungsi format bulan/tahun untuk header (misal: "Oktober 2026")
  String _formatMonthYear(DateTime date) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  // Fungsi format tanggal untuk list (misal: "Kamis, 12 Nov 2026")
  String _formatDateString(DateTime date) {
    return DateFormat('EEEE, dd MMM yyyy', 'id_ID').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgApp = Theme.of(context).scaffoldBackgroundColor;
    final Color headerBlue = isDark ? const Color(0xFF154B8C) : const Color(0xFF135CAE);
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: headerBlue,
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<RiwayatBloc, RiwayatState>(
            builder: (context, state) {
              DateTime currentDate = DateTime.now();
              String totalHadir = '0';
              String totalIzin = '0';
              String totalCuti = '0';
              String totalAlpha = '0';
              List<dynamic> rekapList = [];

              if (state is RiwayatLoading) {
                currentDate = state.currentDate;
              } else if (state is RiwayatLoaded) {
                currentDate = state.currentDate;
                totalHadir = state.summary.hadir.toString();
                totalIzin = state.summary.izin.toString();
                totalCuti = state.summary.cuti.toString();
                totalAlpha = state.summary.tidakHadir.toString();
                rekapList = state.riwayatList;
              } else if (state is RiwayatError) {
                currentDate = state.currentDate;
              }

              return Column(
                children: [
                  // --- 1. HEADER & FILTER BULAN ---
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => context.pop(),
                              child: Icon(Icons.arrow_back, color: Colors.white, size: 24.sp),
                            ),
                            SizedBox(width: 16.w),
                            Text(
                              'Rekap Presensi',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        // Tombol Pilih Bulan dengan DatePicker Bawaan
                        GestureDetector(
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: currentDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: headerBlue,
                                      onPrimary: Colors.white,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null && picked.month != currentDate.month) {
                              if (context.mounted) {
                                context.read<RiwayatBloc>().add(LoadRiwayatRequested(picked));
                              }
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_month, color: Colors.white, size: 16.w),
                                SizedBox(width: 6.w),
                                Text(
                                  _formatMonthYear(currentDate),
                                  style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- 2. KARTU DASHBOARD RINGKASAN & DAFTAR RIWAYAT ---
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: bgApp,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24.r),
                          topRight: Radius.circular(24.r),
                        ),
                      ),
                      child: (state is RiwayatLoading)
                          ? const Center(child: CircularProgressIndicator())
                          : (state is RiwayatError)
                          ? Center(
                        child: Text(
                          state.message,
                          style: TextStyle(color: Colors.red, fontSize: 14.sp),
                        ),
                      )
                          : SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.all(20.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'RINGKASAN BULAN INI',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: textSecondary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 12.h),

                            // Grid Statistik (Hadir, Izin, Cuti, Alpha)
                            Row(
                              children: [
                                Expanded(child: _buildStatCard(title: 'Hadir', value: totalHadir, color: Colors.green, isDark: isDark)),
                                SizedBox(width: 12.w),
                                Expanded(child: _buildStatCard(title: 'Izin', value: totalIzin, color: Colors.orange, isDark: isDark)),
                                SizedBox(width: 12.w),
                                Expanded(child: _buildStatCard(title: 'Cuti', value: totalCuti, color: Colors.blue, isDark: isDark)),
                                SizedBox(width: 12.w),
                                Expanded(child: _buildStatCard(title: 'Alpha', value: totalAlpha, color: Colors.red, isDark: isDark)),
                              ],
                            ),
                            SizedBox(height: 32.h),

                            // --- 3. DAFTAR DETAIL ---
                            Text(
                              'DETAIL PRESENSI',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: textSecondary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 16.h),

                            if (rekapList.isEmpty)
                              Padding(
                                padding: EdgeInsets.only(top: 50.h),
                                child: Center(
                                  child: Text(
                                    'Belum ada data kehadiran bulan ini.',
                                    style: TextStyle(color: textSecondary, fontSize: 14.sp),
                                  ),
                                ),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: rekapList.length,
                                separatorBuilder: (context, index) => SizedBox(height: 16.h),
                                itemBuilder: (context, index) {
                                  final data = rekapList[index];
                                  return _buildDetailCard(data, isDark, textPrimary, textSecondary);
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // --- Widget Bantuan ---

  Widget _buildStatCard({required String title, required String value, required Color color, required bool isDark}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02), blurRadius: 10.r, offset: Offset(0, 4.h)),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: color),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(fontSize: 11.sp, color: isDark ? Colors.grey : const Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(dynamic data, bool isDark, Color textPrimary, Color textSecondary) {
    final String status = data.status ?? '-';
    Color statusColor;

    if (status == 'Hadir') {
      statusColor = Colors.green;
    } else if (status == 'Izin') {
      statusColor = Colors.orange;
    } else if (status == 'Cuti') {
      statusColor = Colors.blue;
    } else {
      statusColor = Colors.red; // Untuk Alpha / Tidak Hadir
    }

    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFF1F5F9);

    final String formattedDate = _formatDateString(data.tanggal);
    final String waktuMasuk = data.waktuMasuk ?? '--:--';
    final String waktuKeluar = data.waktuKeluar ?? '--:--';
    final int menitTerlambat = data.menitTerlambat ?? 0;
    final String jamLembur = data.isLembur ? 'Ya' : '-';

    // Anggap saja kita mendapat keterangan dari properti 'keterangan' atau 'catatan'
    // Jika API belum menyediakan field ini, maka sementara di fallback ke "Keperluan keluarga" jika statusnya izin/cuti
    // (Sesuaikan field `data.keterangan` dengan properti riil dari backendmu jika ada)
    final String keterangan = (status == 'Izin' || status == 'Cuti')
        ? (data.subtitle.isNotEmpty ? data.subtitle : 'Keterangan tidak tersedia')
        : '';

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02), blurRadius: 10.r, offset: Offset(0, 4.h)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Tanggal & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.date_range, size: 16.w, color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF135CAE)),
                  SizedBox(width: 8.w),
                  Text(
                    formattedDate,
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: textPrimary),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                ),
                child: Text(
                  status,
                  style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: statusColor),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Divider(color: borderColor, height: 1),
          ),

          // Data: Masuk & Keluar
          Row(
            children: [
              Expanded(child: _buildInfoItem(Icons.login, 'Masuk', waktuMasuk, Colors.green, textPrimary, textSecondary)),
              Expanded(child: _buildInfoItem(Icons.logout, 'Keluar', waktuKeluar, Colors.red, textPrimary, textSecondary)),
            ],
          ),
          SizedBox(height: 12.h),

          // Data Tambahan: Keterlambatan & Lembur
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                    Icons.warning_amber_rounded,
                    'Terlambat',
                    '$menitTerlambat Menit',
                    menitTerlambat > 0 ? Colors.orange : textSecondary,
                    textPrimary, textSecondary
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                    Icons.nights_stay,
                    'Lembur',
                    jamLembur,
                    data.isLembur ? Colors.indigo : textSecondary,
                    textPrimary, textSecondary
                ),
              ),
            ],
          ),

          // KETERANGAN (Hanya Muncul jika Status Izin atau Cuti)
          if (status == 'Izin' || status == 'Cuti') ...[
            SizedBox(height: 16.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: statusColor.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.notes, size: 14.w, color: statusColor),
                      SizedBox(width: 6.w),
                      Text(
                        'Keterangan',
                        style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: statusColor),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    keterangan,
                    style: TextStyle(fontSize: 12.sp, color: textPrimary),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value, Color iconColor, Color textPrimary, Color textSecondary) {
    return Row(
      children: [
        Icon(icon, size: 16.w, color: iconColor),
        SizedBox(width: 8.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 10.sp, color: textSecondary)),
            SizedBox(height: 2.h),
            Text(value, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: textPrimary)),
          ],
        ),
      ],
    );
  }
}