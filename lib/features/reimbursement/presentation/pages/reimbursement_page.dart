import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/reimbursement_model.dart';
import '../bloc/reimbursement_bloc.dart';
import '../bloc/reimbursement_event.dart';
import '../bloc/reimbursement_state.dart';

class ReimbursementPage extends StatefulWidget {
  const ReimbursementPage({super.key});

  @override
  State<ReimbursementPage> createState() => _ReimbursementPageState();
}

class _ReimbursementPageState extends State<ReimbursementPage> {
  @override
  void initState() {
    super.initState();
    _loadRiwayat();
  }

  void _loadRiwayat() {
    context.read<ReimbursementBloc>().add(LoadRiwayatReimbursement());
  }

  // Helper format tanggal YYYY-MM-DD (atau ISO8601) -> '12 Nov 2026'
  String _formatTanggalUI(String rawDate) {
    if (rawDate.isEmpty) return '-';
    try {
      final DateTime date = DateTime.parse(rawDate);
      const List<String> months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return rawDate;
    }
  }

  String _formatNamaFileUI(String rawFileName) {
    if (rawFileName.isEmpty) return '';

    final int dotIndex = rawFileName.lastIndexOf('.');
    final String ext = dotIndex != -1 ? rawFileName.substring(dotIndex) : '';
    final String nameWithoutExt =
    dotIndex != -1 ? rawFileName.substring(0, dotIndex) : rawFileName;

    final bool isRandomHash =
        nameWithoutExt.length >= 32 && !nameWithoutExt.contains(' ');

    if (isRandomHash) {
      return 'Bukti_Transaksi$ext';
    }
    return rawFileName;
  }

  // Tambahkan kembali helper ini
  String _formatNominal(int amount, String? amountLabel) {
    if (amount > 0) {
      final String formatted = amount.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
      );
      return 'Rp $formatted';
    }
    if (amountLabel != null && amountLabel.isNotEmpty) {
      return amountLabel.replaceFirst(RegExp(r'^Rp\s*'), 'Rp ');
    }
    return 'Rp 0';
  }

  // Helper konfigurasi warna & label berdasarkan field 'status' dari backend
  ({
  String label,
  Color textColor,
  Color bgColor,
  Color amountColor,
  }) _getStatusStyle(String rawStatus, String? statusLabel, bool isDark) {
    final String normalized = rawStatus.toLowerCase().trim();

    if (normalized == 'disetujui' || normalized == 'approved') {
      return (
      label: (statusLabel != null && statusLabel.isNotEmpty)
          ? statusLabel
          : 'Disetujui',
      textColor: isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
      bgColor: isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5),
      amountColor: isDark ? const Color(0xFF60A5FA) : const Color(0xFF1E61B6),
      );
    } else if (normalized == 'ditolak' || normalized == 'rejected') {
      return (
      label: (statusLabel != null && statusLabel.isNotEmpty)
          ? statusLabel
          : 'Ditolak',
      textColor: isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626),
      bgColor: isDark ? const Color(0xFF450A0A) : const Color(0xFFFEE2E2),
      amountColor: isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626),
      );
    } else {
      return (
      label: (statusLabel != null && statusLabel.isNotEmpty)
          ? statusLabel
          : 'Menunggu Persetujuan',
      textColor: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
      bgColor: isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7),
      amountColor: isDark ? const Color(0xFF60A5FA) : const Color(0xFF1E61B6),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryBlue =
    isDark ? const Color(0xFF154B8C) : const Color(0xFF0B56A6);
    final Color bgApp =
    isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA);

    return Scaffold(
      backgroundColor: primaryBlue,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // AppBar Custom
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
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
                    'Pengajuan Reimbursement',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Konten Utama
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
                child: RefreshIndicator(
                  onRefresh: () async => _loadRiwayat(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAjukanCard(context, isDark),
                        SizedBox(height: 24.h),
                        Text(
                          'RIWAYAT PENGAJUAN REIMBURSEMENT',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                            letterSpacing: 0.8,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        _buildHistorySection(isDark),
                      ],
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

  Widget _buildAjukanCard(BuildContext context, bool isDark) {
    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color borderColor =
    isDark ? const Color(0xFF333333) : const Color(0xFFF1F5F9);
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color textSecondary =
    isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final Color iconBg =
    isDark ? const Color(0xFF1E3A8A) : const Color(0xFFE0E7FF);
    final Color iconColor =
    isDark ? const Color(0xFF60A5FA) : const Color(0xFF0B56A6);
    final Color btnBg =
    isDark ? const Color(0xFF3B82F6) : const Color(0xFF1E61B6);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: borderColor, width: 1.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  color: iconColor,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ajukan Reimbursement',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Klaim pengeluaran operasional pekerjaan',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            height: 44.h,
            child: ElevatedButton.icon(
              onPressed: () async {
                await context.push('/buat-reimbursement');
                if (mounted) {
                  _loadRiwayat();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: btnBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              icon: Icon(Icons.add, color: Colors.white, size: 20.sp),
              label: Text(
                'Ajukan Reimbursement',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(bool isDark) {
    final Color textSecondary =
    isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color borderColor =
    isDark ? const Color(0xFF333333) : const Color(0xFFF1F5F9);

    return BlocBuilder<ReimbursementBloc, ReimbursementState>(
      builder: (context, state) {
        final List<ReimbursementModel> riwayatList = state.riwayat ?? [];

        if (state.status == ReimbursementStatus.loading && riwayatList.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 48.h),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state.status == ReimbursementStatus.error && riwayatList.isEmpty) {
          return Container(
            width: double.infinity,
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 36.sp,
                  color: const Color(0xFFDC2626),
                ),
                SizedBox(height: 12.h),
                Text(
                  state.errorMessage ?? 'Gagal memuat riwayat reimbursement',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13.sp, color: textSecondary),
                ),
                SizedBox(height: 12.h),
                TextButton.icon(
                  onPressed: _loadRiwayat,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        if (riwayatList.isEmpty) {
          return Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 40.sp,
                  color: textSecondary,
                ),
                SizedBox(height: 12.h),
                Text(
                  'Belum ada riwayat pengajuan reimbursement',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13.sp, color: textSecondary),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: riwayatList.length,
          separatorBuilder: (context, index) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            final ReimbursementModel item = riwayatList[index];
            final statusStyle = _getStatusStyle(
              item.status,
              item.statusLabel,
              isDark,
            );

            final String? adminNote =
            (item.catatanAdmin != null && item.catatanAdmin!.trim().isNotEmpty)
                ? 'Catatan Admin:\n"${item.catatanAdmin}"'
                : null;

            return ReimbursementHistoryCard(
              date: _formatTanggalUI(item.tanggal),
              status: statusStyle.label,
              statusColor: statusStyle.textColor,
              statusBgColor: statusStyle.bgColor,
              title: item.keperluan.isNotEmpty ? item.keperluan : '-',
              fileName: item.lampiranName ?? '',
              amount: _formatNominal(item.nominal, item.amountLabel),
              amountColor: statusStyle.amountColor,
              adminNote: adminNote,
              isDark: isDark,
              onTap: () {
                // Opsional: navigasi ke detail reimbursement jika rutenya sudah tersedia
                // context.push('/detail-reimbursement/${item.id}');
              },
            );
          },
        );
      },
    );
  }
}

class ReimbursementHistoryCard extends StatelessWidget {
  final String date;
  final String status;
  final Color statusColor;
  final Color statusBgColor;
  final String title;
  final String fileName;
  final String amount;
  final Color amountColor;
  final String? adminNote;
  final bool isDark;
  final VoidCallback? onTap;

  const ReimbursementHistoryCard({
    super.key,
    required this.date,
    required this.status,
    required this.statusColor,
    required this.statusBgColor,
    required this.title,
    required this.fileName,
    required this.amount,
    required this.amountColor,
    this.adminNote,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color borderColor =
    isDark ? const Color(0xFF333333) : const Color(0xFFF1F5F9);
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color textSecondary =
    isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: borderColor, width: 1.w),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14.sp,
                      color: textSecondary,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      date,
                      style: TextStyle(fontSize: 12.sp, color: textSecondary),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(8.r),
                    border: isDark
                        ? Border.all(
                      color: statusColor.withValues(alpha: 0.3),
                      width: 1.w,
                    )
                        : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6.w,
                        height: 6.w,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        status,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 20.sp,
                  color: isDark
                      ? const Color(0xFF475569)
                      : const Color(0xFFCBD5E1),
                ),
              ],
            ),

            if (fileName.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Row(
                children: [
                  Container(
                    padding:
                    EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF282828)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.attach_file,
                          size: 12.sp,
                          color: textSecondary,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'File',
                          style:
                          TextStyle(fontSize: 10.sp, color: textSecondary),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      fileName,
                      style: TextStyle(fontSize: 12.sp, color: textSecondary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],

            if (adminNote != null) ...[
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF450A0A)
                      : const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(8.r),
                  border: isDark
                      ? Border.all(color: const Color(0xFF7F1D1D))
                      : null,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16.sp,
                      color: isDark
                          ? const Color(0xFFF87171)
                          : const Color(0xFFE11D48),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        adminNote!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isDark
                              ? const Color(0xFFFCA5A5)
                              : const Color(0xFFE11D48),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 12.h),
            Divider(color: borderColor, height: 1.h),
            SizedBox(height: 12.h),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Nominal Pengajuan',
                  style: TextStyle(fontSize: 12.sp, color: textSecondary),
                ),
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: amountColor,
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