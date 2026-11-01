import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilPage extends StatefulWidget {
  const EditProfilPage({super.key});

  @override
  State<EditProfilPage> createState() => _EditProfilPageState();
}

class _EditProfilPageState extends State<EditProfilPage> {

  final TextEditingController _namaController = TextEditingController(text: 'Exclipse');
  final TextEditingController _emailController = TextEditingController(text: 'Exclipse@mail.com');
  final TextEditingController _noTlpController = TextEditingController(text: '085755791370');
  final TextEditingController _alamatController = TextEditingController(text: 'Jogja, Jawa Tengah, Indonesia');
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _noTlpController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  void _showImageSourceActionSheet(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  'Ubah Foto Profil',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 16.h),
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.5) : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(Icons.camera_alt, color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF0B56A6)),
                  ),
                  title: Text('Ambil dari Kamera', style: TextStyle(fontSize: 14.sp, color: isDark ? Colors.white : const Color(0xFF1E293B))),
                  onTap: () {
                    context.pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF064E3B).withValues(alpha: 0.5) : const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(Icons.photo_library, color: isDark ? const Color(0xFF34D399) : const Color(0xFF10B981)),
                  ),
                  title: Text('Pilih dari Galeri', style: TextStyle(fontSize: 14.sp, color: isDark ? Colors.white : const Color(0xFF1E293B))),
                  onTap: () {
                    context.pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Gagal mengambil gambar: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgApp = isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC);
    final Color headerBg = isDark ? const Color(0xFF154B8C) : const Color(0xFF1E61B6);
    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final Color borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE2E8F0);
    final Color btnBlue = isDark ? const Color(0xFF3B82F6) : const Color(0xFF1E61B6);

    return Scaffold(
      backgroundColor: bgApp,
      body: Stack(
        children: [

          Container(
            height: 120.h,
            width: double.infinity,
            color: headerBg,
          ),

          SafeArea(
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
                        'Edit Profil',
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
                        SizedBox(height: 8.h),

                        // --- CARD 1: FOTO PROFIL ---
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 24.h),
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
                            children: [
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  Container(
                                    width: 86.w,
                                    height: 86.w,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xFFFCD34D), width: 4.w),
                                      color: isDark ? const Color(0xFF333333) : const Color(0xFFE2E8F0),
                                      image: _imageFile != null
                                          ? DecorationImage(
                                        image: FileImage(_imageFile!),
                                        fit: BoxFit.cover,
                                      )
                                          : const DecorationImage(
                                        image: AssetImage('assets/images/placeholder_profil.png'),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _showImageSourceActionSheet(context),
                                    child: Container(
                                      padding: EdgeInsets.all(6.w),
                                      decoration: BoxDecoration(
                                        color: btnBlue,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: cardBg, width: 2.w),
                                      ),
                                      child: Icon(Icons.camera_alt_outlined, color: Colors.white, size: 14.sp),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                'Exclipse',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'Full Stack Dev & Database Administrator',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20.h),

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
                              _buildModernFormField('Nama Lengkap', _namaController, isDark: isDark),
                              _buildModernFormField('Email', _emailController, isEnabled: false, isDark: isDark),
                              _buildModernFormField('Nomor Tlp', _noTlpController, isNumber: true, isDark: isDark),
                              _buildModernFormField('Alamat Domisili', _alamatController, isLast: true, maxLines: 2, isDark: isDark),
                            ],
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
        ],
      ),

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
                  // TODO: Handle API Update Profile
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
                    Icon(Icons.save_outlined, color: Colors.white, size: 20.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'Simpan Perubahan',
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

  Widget _buildModernFormField(String label, TextEditingController controller, {bool isEnabled = true, bool isNumber = false, bool isLast = false, int maxLines = 1, required bool isDark}) {
    final Color inputBg = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8FAFC);
    final Color disabledBg = isDark ? const Color(0xFF282828) : const Color(0xFFF1F5F9);
    final Color inputBorderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE2E8F0);
    final Color focusedBorderColor = isDark ? const Color(0xFF3B82F6) : const Color(0xFF1E61B6);
    final Color textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color disabledTextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8);

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 20.h),
      child: Column(
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
            enabled: isEnabled,
            maxLines: maxLines,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: isEnabled ? textColor : disabledTextColor,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: isEnabled ? inputBg : disabledBg,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
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
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: isDark ? const Color(0xFF333333) : const Color(0xFFF1F5F9), width: 1.w),
              ),
            ),
          ),
        ],
      ),
    );
  }
}