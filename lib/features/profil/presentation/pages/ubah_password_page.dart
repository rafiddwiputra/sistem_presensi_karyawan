import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class UbahPasswordPage extends StatefulWidget {
  const UbahPasswordPage({super.key});

  @override
  State<UbahPasswordPage> createState() => _UbahPasswordPageState();
}

class _UbahPasswordPageState extends State<UbahPasswordPage> {
  // Controllers
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // State Visibility (Mata)
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Deteksi Mode Gelap
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // 2. Definisi Warna Dinamis
    final Color bgApp = isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC);
    final Color headerBg = isDark ? const Color(0xFF154B8C) : const Color(0xFF1E61B6);
    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE2E8F0);
    final Color btnBlue = isDark ? const Color(0xFF3B82F6) : const Color(0xFF1E61B6);

    return Scaffold(
      backgroundColor: bgApp,
      body: Stack(
        children: [
          // 1. Latar Belakang Biru Header
          Container(
            height: 120.h,
            width: double.infinity,
            color: headerBg,
          ),

          SafeArea(
            child: Column(
              children: [
                // 2. Custom App Bar
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
                        'Ubah Password',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. Area Konten Scrollable
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        SizedBox(height: 12.h),

                        // --- HEADER ICON KEMANAN ---
                        Center(
                          child: Container(
                            width: 90.w,
                            height: 90.w,
                            decoration: BoxDecoration(
                              color: cardBg,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                                  blurRadius: 15.r,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Container(
                                width: 66.w,
                                height: 66.w,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.3) : const Color(0xFFEFF6FF),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.shield_outlined, color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF3B82F6), size: 32.sp),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 24.h),

                        // --- CARD UTAMA: FORM PASSWORD ---
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(24.w),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(20.r),
                            border: isDark ? Border.all(color: borderColor) : null,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.03),
                                blurRadius: 15.r,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. Password Lama
                              _buildPasswordField(
                                label: 'Password Saat Ini',
                                controller: _currentPasswordController,
                                isObscure: _obscureCurrent,
                                onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
                                isDark: isDark,
                              ),
                              SizedBox(height: 20.h),

                              Divider(color: borderColor, thickness: 1.5.h),
                              SizedBox(height: 20.h),

                              // 2. Password Baru
                              _buildPasswordField(
                                label: 'Password Baru',
                                controller: _newPasswordController,
                                isObscure: _obscureNew,
                                onToggle: () => setState(() => _obscureNew = !_obscureNew),
                                isDark: isDark,
                              ),
                              SizedBox(height: 12.h),

                              // Indikator Kekuatan Sandi (Visual Dummy UI)
                              Row(
                                children: [
                                  Expanded(child: Container(height: 4.h, decoration: BoxDecoration(color: isDark ? const Color(0xFF34D399) : const Color(0xFF10B981), borderRadius: BorderRadius.circular(2.r)))),
                                  SizedBox(width: 4.w),
                                  Expanded(child: Container(height: 4.h, decoration: BoxDecoration(color: isDark ? const Color(0xFF34D399) : const Color(0xFF10B981), borderRadius: BorderRadius.circular(2.r)))),
                                  SizedBox(width: 4.w),
                                  Expanded(child: Container(height: 4.h, decoration: BoxDecoration(color: isDark ? const Color(0xFF333333) : const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2.r)))),
                                  SizedBox(width: 12.w),
                                  Text('Kuat', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF34D399) : const Color(0xFF10B981))),
                                ],
                              ),
                              SizedBox(height: 20.h),

                              _buildPasswordField(
                                label: 'Konfirmasi Password Baru',
                                controller: _confirmPasswordController,
                                isObscure: _obscureConfirm,
                                onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24.h),

                        // --- KOTAK INFO KEAMANAN ---
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF064E3B).withValues(alpha: 0.3) : const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: isDark ? const Color(0xFF047857) : const Color(0xFFDCFCE7), width: 1.w),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.info_outline, color: isDark ? const Color(0xFF34D399) : const Color(0xFF10B981), size: 20.sp),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  'Gunakan minimal 8 karakter dengan kombinasi huruf dan angka agar akun Anda tetap aman.',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857),
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 32.h), // Jarak lega ke tombol bawah
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // 4. Tombol Simpan & Batal (Sticky)
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: bgApp,
          border: isDark ? Border(top: BorderSide(color: borderColor)) : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Handle API Ubah Password
                  context.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: btnBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_reset, color: Colors.white, size: 20.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'Ubah Password',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: TextButton(
                onPressed: () => context.pop(),
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Batal',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF475569),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool isObscure,
    required VoidCallback onToggle,
    required bool isDark,
  }) {
    final Color inputBg = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8FAFC);
    final Color inputBorderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE2E8F0);
    final Color focusedBorderColor = isDark ? const Color(0xFF3B82F6) : const Color(0xFF1E61B6);
    final Color textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color iconColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          obscureText: isObscure,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: textColor,
            letterSpacing: isObscure ? 2.0 : 0.0,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: inputBg,
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            suffixIcon: IconButton(
              icon: Icon(
                isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: iconColor,
                size: 20.sp,
              ),
              onPressed: onToggle,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: inputBorderColor, width: 1.w),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: inputBorderColor, width: 1.w),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: focusedBorderColor, width: 1.5.w),
            ),
          ),
        ),
      ],
    );
  }
}