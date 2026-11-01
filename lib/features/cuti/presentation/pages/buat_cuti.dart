import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sistem_presensi_karyawan/features/cuti/presentation/widgets/konfirmasi_cuti_bottom_sheet.dart';

class BuatCutiPage extends StatefulWidget {
  const BuatCutiPage({super.key});

  @override
  State<BuatCutiPage> createState() => _BuatCutiPageState();
}

class _BuatCutiPageState extends State<BuatCutiPage> {
  final TextEditingController _kategoriController = TextEditingController();
  final TextEditingController _tglMulaiController = TextEditingController();
  final TextEditingController _tglSelesaiController = TextEditingController();
  final TextEditingController _alasanController = TextEditingController();

  @override
  void dispose() {
    _kategoriController.dispose();
    _tglMulaiController.dispose();
    _tglSelesaiController.dispose();
    _alasanController.dispose();
    super.dispose();
  }

  // Simulasi DatePicker yang sudah Dark Mode Ready
  Future<void> _pilihTanggal(BuildContext context, TextEditingController controller) async {
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
        controller.text = "${picked.day} Okt 2026"; // Mockup format
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Deteksi Mode Gelap
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // 2. Definisi Warna Dinamis
    final Color bgApp = Theme.of(context).scaffoldBackgroundColor;
    final Color primaryBlue = isDark ? const Color(0xFF3B82F6) : const Color(0xFF135CAE);
    final Color headerBlue = isDark ? const Color(0xFF154B8C) : const Color(0xFF135CAE);
    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: bgApp,

        // TOMBOL AJUKAN CUTI DI BAGIAN BAWAH
        bottomNavigationBar: Container(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          decoration: BoxDecoration(color: bgApp),
          child: SafeArea(
            child: SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const KonfirmasiCutiBottomSheet(),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  elevation: 0,
                ),
                icon: Icon(Icons.send_outlined, color: Colors.white, size: 18.w),
                label: Text(
                  'Ajukan Cuti',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),

        // KONTEN UTAMA
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Stack(
            children: [
              // --- HEADER BIRU ---
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
                    // --- APP BAR CUSTOM ---
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back, color: Colors.white, size: 24.w),
                            onPressed: () => context.pop(),
                          ),
                          Text(
                            'Pengajuan Cuti',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // --- TEKS HEADER ---
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 12.h),
                          Text(
                            'Pengajuan Cuti',
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Lengkapi formulir berikut untuk mengajukan cuti.',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                          SizedBox(height: 24.h),

                          // --- KARTU PEMOHON CUTI ---
                          Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12.r),
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
                                      'PEMOHON CUTI',
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

                    // --- FORM KONTINER ---
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
                          // Field 1: Kategori Cuti
                          _buildInputField(
                            label: 'Cuti Karena Apa?',
                            isRequired: true,
                            hintText: 'Keperluan keluarga di luar kota',
                            controller: _kategoriController,
                            readOnly: true,
                            isDark: isDark,
                            onTap: () {
                              // Aksi membuka pilihan cuti
                            },
                          ),
                          SizedBox(height: 20.h),

                          // Field 2 & 3: Tanggal (Dibagi 2 kolom)
                          Row(
                            children: [
                              Expanded(
                                child: _buildInputField(
                                  label: 'Tanggal Mulai Cuti',
                                  isRequired: true,
                                  hintText: '20 Okt 2026',
                                  controller: _tglMulaiController,
                                  readOnly: true,
                                  suffixIcon: Icons.calendar_month_outlined,
                                  isDark: isDark,
                                  onTap: () => _pilihTanggal(context, _tglMulaiController),
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: _buildInputField(
                                  label: 'Tanggal Selesai',
                                  isRequired: true,
                                  hintText: '22 Okt 2026',
                                  controller: _tglSelesaiController,
                                  readOnly: true,
                                  suffixIcon: Icons.calendar_today_outlined,
                                  isDark: isDark,
                                  onTap: () => _pilihTanggal(context, _tglSelesaiController),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.h),

                          // Field 4: Alasan Cuti
                          _buildInputField(
                            label: 'Alasan Cuti',
                            isRequired: true,
                            hintText: 'Menghadiri acara pernikahan saudara kandung dan mendampingi keluarga di luar kota.',
                            controller: _alasanController,
                            maxLines: 4,
                            trailingLabel: '72 / 30', // Mockup counter
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

  // Helper Widget untuk Input Form seragam
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