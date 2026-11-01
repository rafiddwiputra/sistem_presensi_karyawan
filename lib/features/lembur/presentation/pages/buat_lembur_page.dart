import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sistem_presensi_karyawan/features/lembur/presentation/widgets/konfirmasi_lembur_bottom_sheet.dart';

class BuatLemburPage extends StatefulWidget {
  const BuatLemburPage({super.key});

  @override
  State<BuatLemburPage> createState() => _BuatLemburPageState();
}

class _BuatLemburPageState extends State<BuatLemburPage> {
  final TextEditingController _tglLemburController = TextEditingController(text: '24 Okt 2026');
  final TextEditingController _jamMulaiController = TextEditingController(text: '18:00');
  final TextEditingController _jamSelesaiController = TextEditingController(text: '21:00');
  final TextEditingController _alasanController = TextEditingController(
    text: 'Penyelesaian design high fedelity mobile app.',
  );

  @override
  void dispose() {
    _tglLemburController.dispose();
    _jamMulaiController.dispose();
    _jamSelesaiController.dispose();
    _alasanController.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal(BuildContext context) async {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = isDark ? const Color(0xFF60A5FA) : const Color(0xFF135CAE);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? ColorScheme.dark(primary: primaryColor, onPrimary: Colors.white, onSurface: Colors.white)
                : ColorScheme.light(primary: primaryColor, onPrimary: Colors.white, onSurface: const Color(0xFF1E293B)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _tglLemburController.text = "${picked.day} Okt 2026";
      });
    }
  }

  Future<void> _pilihJam(BuildContext context, TextEditingController controller) async {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = isDark ? const Color(0xFF60A5FA) : const Color(0xFF135CAE);

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? ColorScheme.dark(primary: primaryColor, onPrimary: Colors.white, onSurface: Colors.white, surface: const Color(0xFF1E1E1E))
                : ColorScheme.light(primary: primaryColor, onPrimary: Colors.white, onSurface: const Color(0xFF1E293B), surface: Colors.white),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        final hours = picked.hour.toString().padLeft(2, '0');
        final minutes = picked.minute.toString().padLeft(2, '0');
        controller.text = "$hours:$minutes";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgApp = Theme.of(context).scaffoldBackgroundColor;
    final Color primaryBlue = isDark ? const Color(0xFF3B82F6) : const Color(0xFF135CAE);
    final Color headerBlue = isDark ? const Color(0xFF154B8C) : const Color(0xFF135CAE);
    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: bgApp,

        bottomNavigationBar: Container(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          decoration: BoxDecoration(color: bgApp),
          child: SafeArea(
            child: SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const KonfirmasiLemburBottomSheet(),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Ajukan Lembur',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Icon(Icons.send_outlined, color: Colors.white, size: 18.w),
                  ],
                ),
              ),
            ),
          ),
        ),

        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Stack(
            children: [

              Container(
                height: 310.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: headerBlue,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40.r),
                    bottomRight: Radius.circular(40.r),
                  ),
                ),
              ),

              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back, color: Colors.white, size: 24.w),
                            onPressed: () => context.pop(),
                          ),
                          Text(
                            'Pengajuan Lembur',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 12.h),
                          Text(
                            'Pengajuan Lembur',
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Lengkapi formulir berikut untuk mengajukan Lembur.',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                          SizedBox(height: 24.h),

                          Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10.w),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.badge_outlined, color: Colors.white, size: 20.w),
                                ),
                                SizedBox(width: 16.w),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'PEMOHON LEMBUR',
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white.withValues(alpha: 0.8),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      'Rafid Dwi Putra Andino',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
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

                    SizedBox(height: 24.h),

                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 24.w),
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                            blurRadius: 15.r,
                            offset: Offset(0, 5.h),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          _buildInputField(
                            label: 'Tanggal Lembur',
                            isRequired: true,
                            hintText: 'Pilih Tanggal',
                            controller: _tglLemburController,
                            readOnly: true,
                            suffixIcon: Icons.calendar_today_outlined,
                            isDark: isDark,
                            onTap: () => _pilihTanggal(context),
                          ),
                          SizedBox(height: 20.h),

                          Row(
                            children: [
                              Expanded(
                                child: _buildInputField(
                                  label: 'Jam Mulai',
                                  isRequired: true,
                                  hintText: '00:00',
                                  controller: _jamMulaiController,
                                  readOnly: true,
                                  suffixIcon: Icons.access_time,
                                  isDark: isDark,
                                  onTap: () => _pilihJam(context, _jamMulaiController),
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: _buildInputField(
                                  label: 'Jam Selesai',
                                  isRequired: true,
                                  hintText: '00:00',
                                  controller: _jamSelesaiController,
                                  readOnly: true,
                                  suffixIcon: Icons.access_time,
                                  isDark: isDark,
                                  onTap: () => _pilihJam(context, _jamSelesaiController),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),

                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.3) : const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.nights_stay_outlined, color: isDark ? const Color(0xFF60A5FA) : primaryBlue, size: 20.w),
                                SizedBox(width: 8.w),
                                Text(
                                  'Durasi Lembur',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? const Color(0xFF60A5FA) : primaryBlue,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '4 Jam',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? const Color(0xFF60A5FA) : primaryBlue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20.h),

                          _buildInputField(
                            label: 'Alasan Lembur',
                            isRequired: true,
                            hintText: 'Masukkan alasan lembur...',
                            controller: _alasanController,
                            maxLines: 4,
                            trailingLabel: '23 / 30',
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required bool isRequired,
    required String hintText,
    required bool isDark,
    TextEditingController? controller,
    bool readOnly = false,
    IconData? suffixIcon,
    int maxLines = 1,
    VoidCallback? onTap,
    String? trailingLabel,
  }) {
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final Color fieldBg = isDark ? const Color(0xFF121212) : const Color(0xFFEFF6FF);
    final Color borderColor = isDark ? const Color(0xFF333333) : Colors.transparent;
    final Color iconColor = isDark ? const Color(0xFF60A5FA) : const Color(0xFF135CAE);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                if (isRequired) ...[
                  SizedBox(width: 4.w),
                  Text('*', style: TextStyle(color: const Color(0xFFE11D48), fontSize: 13.sp, fontWeight: FontWeight.bold)),
                ]
              ],
            ),
            if (trailingLabel != null)
              Text(
                trailingLabel,
                style: TextStyle(fontSize: 11.sp, color: textSecondary),
              ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: fieldBg,
            borderRadius: BorderRadius.circular(12.r),
            border: isDark ? Border.all(color: borderColor) : null,
          ),
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            onTap: onTap,
            maxLines: maxLines,
            style: TextStyle(fontSize: 14.sp, color: textPrimary),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: textPrimary.withValues(alpha: 0.7)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16.w),
              suffixIcon: suffixIcon != null
                  ? Icon(suffixIcon, color: iconColor, size: 20.w)
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}