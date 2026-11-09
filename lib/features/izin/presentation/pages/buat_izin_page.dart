import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import '../widgets/konfirmasi_izin_bottom_sheet.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../bloc/izin_bloc.dart';

class BuatIzinPage extends StatefulWidget {
  const BuatIzinPage({super.key});

  @override
  State<BuatIzinPage> createState() => _BuatIzinPageState();
}

class _BuatIzinPageState extends State<BuatIzinPage> {
  final TextEditingController _jenisIzinController = TextEditingController();
  final TextEditingController _keteranganController = TextEditingController();
  int _jenisIzinLength = 0;
  int _keteranganLength = 0;

  File? _lampiranFile;
  String? _namaLampiran;
  final ImagePicker _imagePicker = ImagePicker();

  DateTime? _tanggalMulai;
  DateTime? _tanggalSelesai;
  String? _errorTanggal;

  @override
  void initState() {
    super.initState();
    _jenisIzinController.addListener(() {
      setState(() => _jenisIzinLength = _jenisIzinController.text.length);
    });
    _keteranganController.addListener(() {
      setState(() => _keteranganLength = _keteranganController.text.length);
    });
  }

  @override
  void dispose() {
    _jenisIzinController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }

  String _formatTanggal(DateTime? date) {
    if (date == null) return 'Pilih Tanggal';
    const bulan = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Ags',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day} ${bulan[date.month - 1]} ${date.year}';
  }

  Future<void> _pilihTanggalMulai() async {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = isDark
        ? const Color(0xFF60A5FA)
        : const Color(0xFF135CAE);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggalMulai ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? ColorScheme.dark(
                    primary: primaryColor,
                    onPrimary: Colors.white,
                    onSurface: Colors.white,
                  )
                : ColorScheme.light(
                    primary: primaryColor,
                    onPrimary: Colors.white,
                    onSurface: const Color(0xFF1E293B),
                  ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _tanggalMulai = picked;
        _errorTanggal = null;
        if (_tanggalSelesai != null &&
            _tanggalSelesai!.isBefore(_tanggalMulai!)) {
          _tanggalSelesai = null;
        }
      });
    }
  }

  Future<void> _pilihTanggalSelesai() async {
    if (_tanggalMulai == null) {
      setState(
        () => _errorTanggal = '* Silakan pilih Tanggal Mulai terlebih dahulu!',
      );
      return;
    }

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = isDark
        ? const Color(0xFF60A5FA)
        : const Color(0xFF135CAE);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggalSelesai ?? _tanggalMulai!,
      firstDate: _tanggalMulai!,
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? ColorScheme.dark(
                    primary: primaryColor,
                    onPrimary: Colors.white,
                    onSurface: Colors.white,
                  )
                : ColorScheme.light(
                    primary: primaryColor,
                    onPrimary: Colors.white,
                    onSurface: const Color(0xFF1E293B),
                  ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _tanggalSelesai = picked;
        _errorTanggal = null;
      });
    }
  }

  Future<void> _bukaKamera() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (photo != null) {
        setState(() {
          _lampiranFile = File(photo.path);
          _namaLampiran = photo.name;
        });
      }
    } catch (e) {
      debugPrint("Error akses kamera: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mengakses kamera. Periksa izin aplikasi.'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  Future<void> _bukaGaleriDokumen() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'pdf'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final sizeInBytes = await file.length();
        const maxSizeInBytes = 2 * 1024 * 1024; // 2 MB

        if (sizeInBytes > maxSizeInBytes) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ukuran file maksimal 2 MB.'),
                backgroundColor: Color(0xFFEF4444),
              ),
            );
          }
          return;
        }

        setState(() {
          _lampiranFile = file;
          _namaLampiran = result.files.single.name;
        });
      }
    } catch (e) {
      debugPrint("Error akses dokumen: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color headerBlue = isDark
        ? const Color(0xFF154B8C)
        : const Color(0xFF135CAE);
    final Color textSecondary = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color primaryBlue = isDark
        ? const Color(0xFF3B82F6)
        : const Color(0xFF135CAE);
    final Color borderColor = isDark
        ? const Color(0xFF333333)
        : const Color(0xFFE2E8F0);

    final double paddingTop = MediaQuery.of(context).padding.top;
    final double headerBackgroundHeight = paddingTop + 260.h;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: headerBackgroundHeight,
                decoration: BoxDecoration(
                  color: headerBlue,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(32.r),
                  ),
                ),
              ),
            ),

            Positioned.fill(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildHeaderContent(paddingTop),

                    Container(
                      transform: Matrix4.translationValues(0, -30.h, 0),
                      margin: EdgeInsets.symmetric(horizontal: 20.w),
                      padding: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(24.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.3 : 0.04,
                            ),
                            blurRadius: 20.r,
                            offset: Offset(0, 4.h),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildLabel(
                                'Izin Karena Apa?',
                                isRequired: true,
                                isDark: isDark,
                              ),
                              Text(
                                '$_jenisIzinLength / 30',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          _buildTextInput(
                            controller: _jenisIzinController,
                            hintText: 'Misal: Sakit demam, Acara keluarga...',
                            maxLength: 30,
                            maxLines: 1,
                            isDark: isDark,
                          ),
                          SizedBox(height: 24.h),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel(
                                      'Tanggal Mulai Izin',
                                      isRequired: true,
                                      isDark: isDark,
                                    ),
                                    SizedBox(height: 8.h),
                                    _buildDateField(
                                      _formatTanggal(_tanggalMulai),
                                      onTap: _pilihTanggalMulai,
                                      isDisabled: false,
                                      isDark: isDark,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel(
                                      'Tanggal Selesai Izin',
                                      isRequired: true,
                                      isDark: isDark,
                                    ),
                                    SizedBox(height: 8.h),
                                    _buildDateField(
                                      _formatTanggal(_tanggalSelesai),
                                      onTap: _pilihTanggalSelesai,
                                      isDisabled: _tanggalMulai == null,
                                      isDark: isDark,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (_errorTanggal != null)
                            Padding(
                              padding: EdgeInsets.only(top: 8.h),
                              child: Text(
                                _errorTanggal!,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: const Color(0xFFEF4444),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          SizedBox(height: 24.h),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildLabel(
                                'Alasan Izin',
                                isRequired: true,
                                isDark: isDark,
                              ),
                              Text(
                                '$_keteranganLength / 30',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          _buildTextInput(
                            controller: _keteranganController,
                            hintText: 'Tuliskan detail alasan Anda di sini...',
                            maxLength: 30,
                            maxLines: 4,
                            isDark: isDark,
                          ),
                          SizedBox(height: 24.h),

                          _buildLabel(
                            'Lampiran Bukti',
                            isRequired: true,
                            isDark: isDark,
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              Expanded(
                                child: _buildAttachmentCard(
                                  icon: Icons.camera_alt_outlined,
                                  title: 'Kamera',
                                  subtitle: 'Ambil foto',
                                  onTap: _bukaKamera,
                                  isDark: isDark,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: _buildAttachmentCard(
                                  icon: Icons.folder_open_outlined,
                                  title: 'Dokumen',
                                  subtitle: 'Pilih file',
                                  onTap: _bukaGaleriDokumen,
                                  isDark: isDark,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),

                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              vertical: 12.h,
                              horizontal: 16.w,
                            ),
                            decoration: BoxDecoration(
                              color: _lampiranFile != null
                                  ? (isDark
                                        ? const Color(0xFF1E3A8A)
                                              .withValues(alpha: 0.3)
                                        : const Color(0xFFEFF6FF))
                                  : (isDark
                                        ? const Color(0xFF121212)
                                        : const Color(0xFFF8FAFC)),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: _lampiranFile != null
                                    ? (isDark
                                          ? const Color(0xFF1E3A8A)
                                          : const Color(0xFFBFDBFE))
                                    : borderColor,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                _lampiranFile != null
                                    ? 'Terlampir: $_namaLampiran'
                                    : 'Format didukung: JPG, PNG, PDF (Max 2 Mb)',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: _lampiranFile != null
                                      ? (isDark
                                            ? const Color(0xFF60A5FA)
                                            : const Color(0xFF1E40AF))
                                      : textSecondary,
                                  fontWeight: _lampiranFile != null
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      margin: EdgeInsets.only(top: 10.h, bottom: 40.h),
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      width: double.infinity,
                      height: 55.h,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // 1. Validasi Form Kosong
                          if (_jenisIzinController.text.isEmpty ||
                              _tanggalMulai == null ||
                              _tanggalSelesai == null ||
                              _keteranganController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Harap lengkapi semua form yang bertanda bintang (*)',
                                ),
                                backgroundColor: Color(0xFFEF4444),
                              ),
                            );
                            return;
                          }

                          // 2. Validasi Lampiran Wajib (Sesuai aturan Laravel)
                          if (_jenisIzinController.text.toLowerCase() ==
                                  'sakit' &&
                              _lampiranFile == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Lampiran bukti wajib diunggah untuk izin Sakit.',
                                ),
                                backgroundColor: Color(0xFFEF4444),
                              ),
                            );
                            return;
                          }

                          // 3. Tampilkan Bottom Sheet dengan membawa data form
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (bottomSheetContext) =>
                                BlocProvider<IzinBloc>(
                                  // Mengambil BLoC yang sudah kita daftarkan di injection.dart
                                  create: (context) =>
                                      GetIt.instance<IzinBloc>(),
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      bottom: MediaQuery.of(bottomSheetContext)
                                          .viewInsets
                                          .bottom,
                                    ),
                                    child: KonfirmasiIzinBottomSheet(
                                      jenisIzin: _jenisIzinController.text,
                                      tanggalMulai: _tanggalMulai!,
                                      tanggalSelesai: _tanggalSelesai!,
                                      keterangan: _keteranganController.text,
                                      lampiran: _lampiranFile,
                                    ),
                                  ),
                                ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          elevation: 0,
                        ),
                        icon: Icon(
                          Icons.send_outlined,
                          color: Colors.white,
                          size: 20.w,
                        ),
                        label: Text(
                          'Ajukan Izin',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderContent(double paddingTop) {
    return Padding(
      padding: EdgeInsets.only(
        top: paddingTop + 16.h,
        left: 24.w,
        right: 24.w,
        bottom: 60.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  color: Colors.transparent,
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24.w,
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Text(
                'Pengajuan Izin',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 28.h),
          Text(
            'Pengajuan Izin',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Lengkapi formulir berikut untuk mengajukan izin.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 13.sp,
            ),
          ),
          SizedBox(height: 24.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.badge_outlined,
                    color: Colors.white,
                    size: 20.w,
                  ),
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PEMOHON IZIN',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Rafid Dwi Putra Andino',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(
    String text, {
    required bool isRequired,
    required bool isDark,
  }) {
    return RichText(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : const Color(0xFF1E293B),
        ),
        children: isRequired
            ? [
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: const Color(0xFFEF4444),
                    fontSize: 13.sp,
                  ),
                ),
              ]
            : [],
      ),
    );
  }

  Widget _buildTextInput({
    required TextEditingController controller,
    required String hintText,
    required int maxLength,
    required bool isDark,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121212) : const Color(0xFFF4F7FA),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? const Color(0xFF333333) : Colors.transparent,
        ),
      ),
      child: TextField(
        controller: controller,
        maxLength: maxLength,
        maxLines: maxLines,
        style: TextStyle(
          fontSize: 14.sp,
          color: isDark ? Colors.white : const Color(0xFF1E293B),
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 14.sp,
            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
          ),
          contentPadding: EdgeInsets.all(16.w),
          border: InputBorder.none,
          counterText: '',
        ),
      ),
    );
  }

  Widget _buildDateField(
    String value, {
    required VoidCallback onTap,
    required bool isDisabled,
    required bool isDark,
  }) {
    final Color disabledBg = isDark
        ? const Color(0xFF282828)
        : const Color(0xFFF8FAFC);
    final Color enabledBg = isDark
        ? const Color(0xFF121212)
        : const Color(0xFFF4F7FA);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: isDisabled ? disabledBg : enabledBg,
            borderRadius: BorderRadius.circular(12.r),
            border: isDark && !isDisabled
                ? Border.all(color: const Color(0xFF333333))
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: isDisabled
                      ? const Color(0xFF94A3B8)
                      : (isDark ? Colors.white : const Color(0xFF1E293B)),
                  fontWeight: isDisabled ? FontWeight.normal : FontWeight.w500,
                ),
              ),
              Icon(
                Icons.calendar_today_outlined,
                color: isDisabled
                    ? const Color(0xFF94A3B8)
                    : (isDark
                          ? const Color(0xFF60A5FA)
                          : const Color(0xFF135CAE)),
                size: 18.w,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF121212) : const Color(0xFFF4F7FA),
            borderRadius: BorderRadius.circular(16.r),
            border: isDark ? Border.all(color: const Color(0xFF333333)) : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E3A8A)
                      : const Color(0xFFE0E7FF),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isDark
                      ? const Color(0xFF60A5FA)
                      : const Color(0xFF135CAE),
                  size: 22.w,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
