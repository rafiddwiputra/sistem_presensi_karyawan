import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ReimbursementPage extends StatelessWidget {
  const ReimbursementPage({super.key});

  @override
  Widget build(BuildContext context) {

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryBlue = isDark ? const Color(0xFF154B8C) : const Color(0xFF0B56A6);
    final Color bgApp = isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA);

    return Scaffold(
      backgroundColor: primaryBlue,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Icon(Icons.arrow_back, color: Colors.white, size: 24.sp),
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
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
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
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          letterSpacing: 0.8,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      _buildHistoryList(isDark),
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

  Widget _buildAjukanCard(BuildContext context, bool isDark) {
    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFF1F5F9);
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final Color iconBg = isDark ? const Color(0xFF1E3A8A) : const Color(0xFFE0E7FF);
    final Color iconColor = isDark ? const Color(0xFF60A5FA) : const Color(0xFF0B56A6);
    final Color btnBg = isDark ? const Color(0xFF3B82F6) : const Color(0xFF1E61B6);

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
              onPressed: () {
                context.push('/buat-reimbursement');
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

  Widget _buildHistoryList(bool isDark) {
    return Column(
      children: [
        ReimbursementHistoryCard(
          date: '22 Okt 2026',
          status: 'Menunggu Persetujuan',
          statusColor: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
          statusBgColor: isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7),
          title: 'Pembelian Sensor',
          fileName: 'struk nota pembelian sensor.png',
          amount: 'Rp 350.000',
          amountColor: isDark ? const Color(0xFF60A5FA) : const Color(0xFF1E61B6),
          isDark: isDark,
        ),
        SizedBox(height: 12.h),
        ReimbursementHistoryCard(
          date: '25 Okt 2026',
          status: 'Disetujui',
          statusColor: isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
          statusBgColor: isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5),
          title: 'Biaya Transportasi',
          fileName: 'struk nota pembelian bensin.jpg',
          amount: 'Rp 30.000',
          amountColor: isDark ? const Color(0xFF60A5FA) : const Color(0xFF1E61B6),
          isDark: isDark,
        ),
        SizedBox(height: 12.h),
        ReimbursementHistoryCard(
          date: '30 Okt 2026',
          status: 'Disetujui',
          statusColor: isDark ? const Color(0xFF34D399) : const Color(0xFF059669),
          statusBgColor: isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5),
          title: 'Biaya Konsumsi & Jajan',
          fileName: 'foto-nota.jpg',
          amount: 'Rp 240.000',
          amountColor: isDark ? const Color(0xFF60A5FA) : const Color(0xFF1E61B6),
          isDark: isDark,
        ),
        SizedBox(height: 12.h),
        ReimbursementHistoryCard(
          date: '18 Sep 2026',
          status: 'Ditolak',
          statusColor: isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626),
          statusBgColor: isDark ? const Color(0xFF450A0A) : const Color(0xFFFEE2E2),
          title: 'Kuota habis beliin dong',
          fileName: '',
          amount: 'Rp 150.000',
          amountColor: isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626),
          adminNote: 'Catatan Admin:\n"Cuih ga modal"',
          isDark: isDark,
        ),
      ],
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
  });

  @override
  Widget build(BuildContext context) {
    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFF1F5F9);
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
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
                  Icon(Icons.calendar_today_outlined, size: 14.sp, color: textSecondary),
                  SizedBox(width: 6.w),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(8.r),
                  border: isDark ? Border.all(color: statusColor.withValues(alpha: 0.3), width: 1.w) : null,
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
              Icon(Icons.chevron_right, size: 20.sp, color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
            ],
          ),

          if (fileName.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF282828) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.attach_file, size: 12.sp, color: textSecondary),
                      SizedBox(width: 4.w),
                      Text(
                        'File',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    fileName,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: textSecondary,
                    ),
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
                color: isDark ? const Color(0xFF450A0A) : const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(8.r),
                border: isDark ? Border.all(color: const Color(0xFF7F1D1D)) : null,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 16.sp, color: isDark ? const Color(0xFFF87171) : const Color(0xFFE11D48)),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      adminNote!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFFE11D48),
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
                style: TextStyle(
                  fontSize: 12.sp,
                  color: textSecondary,
                ),
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
    );
  }
}