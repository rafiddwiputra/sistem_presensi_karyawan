import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../profil/presentation/bloc/profil_bloc.dart';
import '../../../profil/presentation/bloc/profil_state.dart';
import '../bloc/reimbursement_bloc.dart';
import '../bloc/reimbursement_state.dart';
import '../widgets/konfirmasi_reimbursement_bottom_sheet.dart';

class BuatReimbursementPage extends StatefulWidget {
  const BuatReimbursementPage({super.key});

  @override
  State<BuatReimbursementPage> createState() => _BuatReimbursementPageState();
}

class _BuatReimbursementPageState extends State<BuatReimbursementPage> {
  // Controller (Kosong saat inisialisasi)
  final TextEditingController _keperluanController = TextEditingController();
  final TextEditingController _nominalController = TextEditingController();

  // State Dinamis
  DateTime _selectedDate = DateTime.now();
  File? _lampiranFile;
  String? _namaLampiran;
  String? _selectedSource; // 'kamera' atau 'galeri'

  // Pelacak Overlay agar context.pop() aman & tidak double-pop
  bool _isLoadingDialogOpen = false;
  bool _isBottomSheetOpen = false;

  final ImagePicker _imagePicker = ImagePicker();
  static const int _maxKeperluanLength = 30;
  static const int _maxFileSizeBytes = 2 * 1024 * 1024; // 2 MB

  @override
  void dispose() {
    _keperluanController.dispose();
    _nominalController.dispose();
    super.dispose();
  }

  // Helper Format Tanggal Indonesia (Untuk tampilan UI)
  String _formatDate(DateTime date) {
    const List<String> months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // Helper Format Tanggal Backend (YYYY-MM-DD)
  String _formatDateForBackend(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Validasi ukuran file maksimal 2 MB
  bool _isFileSizeValid(File file) {
    if (file.lengthSync() > _maxFileSizeBytes) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ukuran file melebihi batas maksimal 2 MB!'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
    return true;
  }

  // Function Pop-up Picker Tanggal
  Future<void> _selectDate(BuildContext context) async {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
              primary: Color(0xFF3B82F6),
              onPrimary: Colors.white,
              onSurface: Colors.white,
              surface: Color(0xFF1E1E1E),
            )
                : const ColorScheme.light(
              primary: Color(0xFF0B56A6),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E293B),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Function Riil Buka Kamera
  Future<void> _bukaKamera() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (photo != null) {
        final File file = File(photo.path);
        if (!_isFileSizeValid(file)) return;

        setState(() {
          _lampiranFile = file;
          _namaLampiran = photo.name;
          _selectedSource = 'kamera';
        });
      }
    } catch (e) {
      debugPrint('Error akses kamera: $e');
    }
  }

  // Function Riil Buka Galeri / Dokumen
  Future<void> _bukaGaleriDokumen() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'pdf'],
      );

      if (result != null && result.files.single.path != null) {
        final File file = File(result.files.single.path!);
        if (!_isFileSizeValid(file)) return;

        setState(() {
          _lampiranFile = file;
          _namaLampiran = result.files.single.name;
          _selectedSource = 'galeri';
        });
      }
    } catch (e) {
      debugPrint('Error akses dokumen: $e');
    }
  }

  // Function Hapus File Terlampir
  void _removeFile() {
    setState(() {
      _lampiranFile = null;
      _namaLampiran = null;
      _selectedSource = null;
    });
  }

  // Validasi Form Sebelum Membuka Bottom Sheet Konfirmasi
  void _onAjukanPressed(BuildContext context) {
    final String cleanNominal = _nominalController.text.replaceAll('.', '');
    final int nominalValue = int.tryParse(cleanNominal) ?? 0;

    if (_keperluanController.text.trim().isEmpty ||
        nominalValue <= 0 ||
        _lampiranFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap lengkapi semua data dengan benar beserta bukti transaksi!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _isBottomSheetOpen = true;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return BlocProvider.value(
          value: context.read<ReimbursementBloc>(),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: KonfirmasiReimbursementBottomSheet(
              tanggal: _formatDateForBackend(_selectedDate),
              keperluan: _keperluanController.text.trim(),
              nominal: _nominalController.text,
              lampiran: _lampiranFile!,
            ),
          ),
        );
      },
    ).whenComplete(() {
      _isBottomSheetOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final profilState = context.watch<ProfilBloc>().state;
    final String namaKaryawan = profilState is ProfilLoaded
        ? (profilState.user['nama'] as String? ?? 'Karyawan')
        : 'Karyawan';

    final Color headerBlue = isDark ? const Color(0xFF154B8C) : const Color(0xFF0B56A6);
    final Color btnBlue = isDark ? const Color(0xFF3B82F6) : const Color(0xFF1E61B6);
    final Color bgApp = isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final Color borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE2E8F0);
    final Color inputBg = isDark ? const Color(0xFF282828) : const Color(0xFFF1F5F9);

    return BlocListener<ReimbursementBloc, ReimbursementState>(
      listener: (context, state) {
        if (state.status == ReimbursementStatus.loading) {
          if (!_isLoadingDialogOpen) {
            _isLoadingDialogOpen = true;
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(child: CircularProgressIndicator()),
            ).whenComplete(() => _isLoadingDialogOpen = false);
          }
        } else if (state.status == ReimbursementStatus.submitSuccess) {
          if (_isLoadingDialogOpen) {
            _isLoadingDialogOpen = false;
            Navigator.of(context, rootNavigator: true).pop();
          }
          if (_isBottomSheetOpen) {
            _isBottomSheetOpen = false;
            context.pop();
          }

          // Arahkan ke halaman berhasil sambil meneruskan instance BLoC aktif
          context.pushReplacement(
            '/reimbursement-berhasil',
            extra: {'bloc': context.read<ReimbursementBloc>()},
          );
        } else if (state.status == ReimbursementStatus.error ||
            state.status == ReimbursementStatus.submitFailure) {
          if (_isLoadingDialogOpen) {
            _isLoadingDialogOpen = false;
            Navigator.of(context, rootNavigator: true).pop();
          }
          if (_isBottomSheetOpen) {
            _isBottomSheetOpen = false;
            context.pop();
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Terjadi kesalahan saat mengirim pengajuan'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: bgApp,
        body: Stack(
          children: [
            // Latar Belakang Biru Melengkung
            Container(
              height: 290.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: headerBlue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32.r),
                  bottomRight: Radius.circular(32.r),
                ),
              ),
            ),

            // Konten Utama
            SafeArea(
              child: Column(
                children: [
                  // Custom Appbar
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
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Area Scroll Form
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8.h),
                          Text(
                            'Pengajuan Reimbursement',
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            'Lengkapi formulir berikut untuk mengajukan Reimbursement.',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          SizedBox(height: 20.h),

                          // Kotak Info Pemohon
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E3A8A).withValues(alpha: 0.5)
                                  : const Color(0xFF1D64B9),
                              borderRadius: BorderRadius.circular(12.r),
                              border: isDark ? Border.all(color: const Color(0xFF1E40AF)) : null,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8.w),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Icon(
                                    Icons.assignment_ind_outlined,
                                    color: Colors.white,
                                    size: 20.sp,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'PEMOHON PENGAJUAN REIMBURSEMENT',
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white.withValues(alpha: 0.8),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      namaKaryawan,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16.h),

                          // Card White Form Container
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(20.w),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(24.r),
                              border: isDark ? Border.all(color: borderColor) : null,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: isDark ? 0.3 : 0.03,
                                  ),
                                  blurRadius: 10.r,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Field 1: Tanggal Transaksi
                                _buildLabel(
                                  'Tanggal Transaksi',
                                  isRequired: true,
                                  subtitle: 'Tanggal pembayaran saat pengeluaran dilakukan',
                                  isDark: isDark,
                                ),
                                SizedBox(height: 8.h),
                                GestureDetector(
                                  onTap: () => _selectDate(context),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color: isDark ? const Color(0xFF282828) : const Color(0xFFE2E8F0),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _formatDate(_selectedDate),
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: textPrimary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Icon(
                                          Icons.calendar_today_outlined,
                                          size: 20.sp,
                                          color: btnBlue,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20.h),

                                // Field 2: Keperluan Pengeluaran
                                _buildLabel(
                                  'Keperluan Pengeluaran',
                                  isRequired: true,
                                  trailingText: '${_keperluanController.text.length} / $_maxKeperluanLength',
                                  isDark: isDark,
                                ),
                                SizedBox(height: 8.h),
                                TextFormField(
                                  controller: _keperluanController,
                                  maxLength: _maxKeperluanLength,
                                  textCapitalization: TextCapitalization.sentences,
                                  onChanged: (_) => setState(() {}),
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: textPrimary,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Contoh: Pembelian sensor',
                                    hintStyle: TextStyle(
                                      fontSize: 14.sp,
                                      color: textSecondary,
                                    ),
                                    filled: true,
                                    fillColor: inputBg,
                                    counterText: '',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                                  ),
                                ),
                                SizedBox(height: 20.h),

                                // Field 3: Nominal Pengajuan
                                _buildLabel(
                                  'Nominal Pengajuan',
                                  isRequired: true,
                                  isDark: isDark,
                                ),
                                SizedBox(height: 8.h),
                                Container(
                                  decoration: BoxDecoration(
                                    color: inputBg,
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? const Color(0xFF1E3A8A).withValues(alpha: 0.3)
                                              : const Color(0xFFE0E7FF),
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(12.r),
                                            bottomLeft: Radius.circular(12.r),
                                          ),
                                        ),
                                        child: Text(
                                          'Rp',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.bold,
                                            color: btnBlue,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _nominalController,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.digitsOnly,
                                            _ThousandsSeparatorInputFormatter(),
                                          ],
                                          style: TextStyle(
                                            fontSize: 20.sp,
                                            fontWeight: FontWeight.bold,
                                            color: textPrimary,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: '0',
                                            hintStyle: TextStyle(
                                              fontSize: 20.sp,
                                              fontWeight: FontWeight.bold,
                                              color: textSecondary,
                                            ),
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20.h),

                          // Field 4: Bukti Transaksi
                          _buildLabel(
                            'Bukti Transaksi',
                            isRequired: true,
                            subtitle: 'Upload bukti transaksi (Foto, Struk Transaksi)',
                            isDark: isDark,
                          ),
                          SizedBox(height: 12.h),
                          Row(
                            children: [
                              Expanded(
                                child: _buildUploadCard(
                                  icon: Icons.camera_alt_outlined,
                                  title: 'Kamera',
                                  subtitle: 'Ambil langsung',
                                  isSelected: _selectedSource == 'kamera',
                                  onTap: _bukaKamera,
                                  isDark: isDark,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: _buildUploadCard(
                                  icon: Icons.folder_outlined,
                                  title: 'Galeri / Dokumen',
                                  subtitle: 'Pilih dari perangkat',
                                  isSelected: _selectedSource == 'galeri',
                                  onTap: _bukaGaleriDokumen,
                                  isDark: isDark,
                                ),
                              ),
                            ],
                          ),

                          // Menampilkan Nama File Terpilih & Icon Tong Sampah
                          if (_lampiranFile != null) ...[
                            SizedBox(height: 12.h),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1E3A8A).withValues(alpha: 0.2)
                                    : const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: isDark ? const Color(0xFF1E40AF) : const Color(0xFFBFDBFE),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.insert_drive_file,
                                    color: btnBlue,
                                    size: 20.sp,
                                  ),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: Text(
                                      _namaLampiran ?? '',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w500,
                                        color: textPrimary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: _removeFile,
                                    child: Icon(
                                      Icons.delete_outline,
                                      color: const Color(0xFFDC2626),
                                      size: 20.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          SizedBox(height: 16.h),

                          // Helper Text Upload
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: borderColor),
                            ),
                            child: Text(
                              'Upload dengan format: Jpg, Png, atau PDF (Max 2 Mb)',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: textSecondary,
                              ),
                            ),
                          ),
                          SizedBox(height: 100.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // Tombol Submit Sticky
        bottomNavigationBar: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: bgApp,
            border: isDark ? Border(top: BorderSide(color: borderColor)) : null,
          ),
          child: SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              onPressed: () => _onAjukanPressed(context),
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
                  Text(
                    'Ajukan Reimbursement',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(Icons.arrow_forward, color: Colors.white, size: 20.sp),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget Bantuan Label Form
  Widget _buildLabel(
      String title, {
        bool isRequired = false,
        String? subtitle,
        String? trailingText,
        required bool isDark,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              text: TextSpan(
                text: title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
                children: [
                  if (isRequired)
                    TextSpan(
                      text: ' *',
                      style: TextStyle(
                        color: isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626),
                        fontSize: 14.sp,
                      ),
                    ),
                ],
              ),
            ),
            if (trailingText != null)
              Text(
                trailingText,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        if (subtitle != null) ...[
          SizedBox(height: 4.h),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12.sp,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
        ],
      ],
    );
  }

  // Widget Bantuan Card Upload Dinamis
  Widget _buildUploadCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color selectedBg = isDark
        ? const Color(0xFF1E3A8A).withValues(alpha: 0.3)
        : const Color(0xFFEFF6FF);
    final Color borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE2E8F0);
    final Color selectedBorderColor = isDark ? const Color(0xFF3B82F6) : const Color(0xFF0B56A6);
    final Color iconBg = isDark ? const Color(0xFF282828) : const Color(0xFFF1F5F9);
    final Color selectedIconBg = isDark ? const Color(0xFF3B82F6) : const Color(0xFF0B56A6);
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : cardBg,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? selectedBorderColor : borderColor,
            width: isSelected ? 2.w : 1.w,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: isSelected ? selectedIconBg : iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : selectedBorderColor,
                size: 24.sp,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: isSelected ? selectedBorderColor : textPrimary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: TextStyle(fontSize: 10.sp, color: textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Formatter Pemisah Ribuan Otomatis (Contoh: 55000 -> 55.000)
class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final String normalized = digitsOnly.replaceFirst(RegExp(r'^0+'), '');
    if (normalized.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final String formatted = normalized.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
    );

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}