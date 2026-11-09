import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

// Import BLoC & Widgets
import '../../../../features/profil/presentation/bloc/profil_bloc.dart';
import '../../../../features/profil/presentation/bloc/profil_state.dart';
import '../bloc/cuti_bloc.dart';
import '../widgets/konfirmasi_cuti_bottom_sheet.dart';

class BuatCutiPage extends StatefulWidget {
  const BuatCutiPage({super.key});

  @override
  State<BuatCutiPage> createState() => _BuatCutiPageState();
}

class _BuatCutiPageState extends State<BuatCutiPage> {
  late final String _uuidPengajuan;

  final TextEditingController _kategoriController = TextEditingController();
  final TextEditingController _tglMulaiController = TextEditingController();
  final TextEditingController _tglSelesaiController = TextEditingController();
  final TextEditingController _alasanController = TextEditingController();

  DateTime? _tanggalMulai;
  DateTime? _tanggalSelesai;

  // Daftar Pilihan Jenis Cuti
  final List<String> _opsiJenisCuti = [
    'Cuti Tahunan',
    'Cuti Sakit (Dengan Surat Dokter)',
    'Cuti Melahirkan / Kehamilan',
    'Cuti Alasan Penting',
    'Cuti Besar / Khusus',
  ];

  @override
  void initState() {
    super.initState();
    // 1. Generate UUID Pengajuan sekali saat halaman dibuat (Idempotency)
    _uuidPengajuan = const Uuid().v4();

    // 2. Listener untuk meng-update counter karakter alasan secara real-time
    _alasanController.addListener(_onAlasanChanged);
  }

  void _onAlasanChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _alasanController.removeListener(_onAlasanChanged);
    _kategoriController.dispose();
    _tglMulaiController.dispose();
    _tglSelesaiController.dispose();
    _alasanController.dispose();
    super.dispose();
  }

  // Helper mendapatkan nama karyawan dari ProfilBloc secara aman
  String _getNamaKaryawan(BuildContext context) {
    try {
      final state = context.watch<ProfilBloc>().state;
      if (state is ProfilLoaded) {
        // Menggunakan dynamic untuk mencegah error getter jika properti bernama 'user', 'profile', dll.
        final dynState = state as dynamic;
        return dynState.profil?.nama ?? dynState.user?.nama ?? dynState.profile?.nama ?? 'Rafid Dwi Putra Andino';
      }
    } catch (_) {}
    return 'Rafid Dwi Putra Andino';
  }

  // --- MODAL SELEKSI JENIS CUTI ---
  void _tampilkanPilihanCuti(BuildContext context, bool isDark) {
    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textPrimary = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color primaryBlue = isDark ? const Color(0xFF3B82F6) : const Color(0xFF135CAE);

    showModalBottomSheet(
      context: context,
      backgroundColor: cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (bottomSheetContext) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pilih Jenis Cuti',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              SizedBox(height: 16.h),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _opsiJenisCuti.length,
                  separatorBuilder: (context, index) => Divider(
                    color: isDark ? const Color(0xFF333333) : const Color(0xFFE2E8F0),
                  ),
                  itemBuilder: (context, index) {
                    final opsi = _opsiJenisCuti[index];
                    final isSelected = _kategoriController.text == opsi;

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        opsi,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? primaryBlue : textPrimary,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check_circle, color: primaryBlue, size: 20.w)
                          : null,
                      onTap: () {
                        setState(() {
                          _kategoriController.text = opsi;
                        });
                        Navigator.pop(bottomSheetContext);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- PICKER TANGGAL MULAI ---
  Future<void> _pilihTanggalMulai(BuildContext context) async {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = isDark ? const Color(0xFF60A5FA) : const Color(0xFF135CAE);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggalMulai ?? today,
      firstDate: today, // Restriksi API: Tanggal mulai tidak boleh sebelum hari ini
      lastDate: DateTime(now.year + 2),
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
        _tglMulaiController.text = DateFormat('dd MMM yyyy', 'id_ID').format(picked);

        // Reset atau sesuaikan tanggal selesai jika lebih awal dari tanggal mulai
        if (_tanggalSelesai != null && _tanggalSelesai!.isBefore(picked)) {
          _tanggalSelesai = picked;
          _tglSelesaiController.text = DateFormat('dd MMM yyyy', 'id_ID').format(picked);
        }
      });
    }
  }

  // --- PICKER TANGGAL SELESAI ---
  Future<void> _pilihTanggalSelesai(BuildContext context) async {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = isDark ? const Color(0xFF60A5FA) : const Color(0xFF135CAE);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final minDate = _tanggalMulai ?? today;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggalSelesai ?? minDate,
      firstDate: minDate, // Restriksi API: Tanggal selesai tidak boleh sebelum tanggal mulai
      lastDate: DateTime(now.year + 2),
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
        _tglSelesaiController.text = DateFormat('dd MMM yyyy', 'id_ID').format(picked);
      });
    }
  }

  // --- VALIDASI SEBELUM KONFIRMASI ---
  void _validasiDanBukaKonfirmasi(BuildContext context, String namaKaryawan) {
    if (_kategoriController.text.trim().isEmpty) {
      _tampilkanSnackBar('Silakan pilih jenis cuti terlebih dahulu.');
      return;
    }
    if (_tanggalMulai == null) {
      _tampilkanSnackBar('Silakan pilih tanggal mulai cuti.');
      return;
    }
    if (_tanggalSelesai == null) {
      _tampilkanSnackBar('Silakan pilih tanggal selesai cuti.');
      return;
    }
    if (_alasanController.text.trim().isEmpty) {
      _tampilkanSnackBar('Silakan isi alasan pengajuan cuti.');
      return;
    }

    // Ambil CutiBloc dari context saat ini
    final cutiBloc = context.read<CutiBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        // Teruskan instance CutiBloc ke dalam Modal Bottom Sheet
        return BlocProvider.value(
          value: cutiBloc,
          child: KonfirmasiCutiBottomSheet(
            uuidPengajuan: _uuidPengajuan,
            namaKaryawan: namaKaryawan,
            jenisCuti: _kategoriController.text.trim(),
            tanggalMulai: _tanggalMulai!,
            tanggalSelesai: _tanggalSelesai!,
            keterangan: _alasanController.text.trim(),
          ),
        );
      },
    );
  }

  void _tampilkanSnackBar(String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(pesan),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgApp = Theme.of(context).scaffoldBackgroundColor;
    final Color primaryBlue = isDark ? const Color(0xFF3B82F6) : const Color(0xFF135CAE);
    final Color headerBlue = isDark ? const Color(0xFF154B8C) : const Color(0xFF135CAE);
    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    final String namaKaryawan = _getNamaKaryawan(context);

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
              child: ElevatedButton.icon(
                onPressed: () => _validasiDanBukaKonfirmasi(context, namaKaryawan),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                icon: Icon(
                  Icons.send_outlined,
                  color: Colors.white,
                  size: 18.w,
                ),
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
                            icon: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 24.w,
                            ),
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
                                  child: Icon(
                                    Icons.badge_outlined,
                                    color: Colors.white,
                                    size: 20.w,
                                  ),
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
                                      namaKaryawan, // <- Nama Karyawan Dinamis
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
                          // Field 1: Kategori Cuti (Pilihan Dialog)
                          _buildInputField(
                            label: 'Cuti Karena Apa?',
                            isRequired: true,
                            hintText: 'Pilih jenis cuti',
                            controller: _kategoriController,
                            readOnly: true,
                            suffixIcon: Icons.arrow_drop_down_circle_outlined,
                            isDark: isDark,
                            onTap: () => _tampilkanPilihanCuti(context, isDark),
                          ),
                          SizedBox(height: 20.h),

                          // Field 2 & 3: Tanggal Mulai dan Selesai
                          Row(
                            children: [
                              Expanded(
                                child: _buildInputField(
                                  label: 'Tanggal Mulai Cuti',
                                  isRequired: true,
                                  hintText: 'Pilih tanggal',
                                  controller: _tglMulaiController,
                                  readOnly: true,
                                  suffixIcon: Icons.calendar_month_outlined,
                                  isDark: isDark,
                                  onTap: () => _pilihTanggalMulai(context),
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: _buildInputField(
                                  label: 'Tanggal Selesai',
                                  isRequired: true,
                                  hintText: 'Pilih tanggal',
                                  controller: _tglSelesaiController,
                                  readOnly: true,
                                  suffixIcon: Icons.calendar_today_outlined,
                                  isDark: isDark,
                                  onTap: () => _pilihTanggalSelesai(context),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.h),

                          // Field 4: Alasan Cuti (Dengan Dynamic Character Counter)
                          _buildInputField(
                            label: 'Alasan Cuti',
                            isRequired: true,
                            hintText: 'Tuliskan alasan pengajuan cuti Anda secara rinci...',
                            controller: _alasanController,
                            maxLines: 4,
                            trailingLabel: '${_alasanController.text.length} / 500',
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
                  Text(
                    '*',
                    style: TextStyle(
                      color: const Color(0xFFE11D48),
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
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
              hintStyle: TextStyle(color: textSecondary),
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