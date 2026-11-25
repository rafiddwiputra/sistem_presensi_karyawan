import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:sistem_presensi_karyawan/core/di/injection.dart';

import 'package:sistem_presensi_karyawan/features/auth/presentation/pages/login_page.dart';
import 'package:sistem_presensi_karyawan/features/auth/presentation/pages/splash_page.dart';

import 'package:sistem_presensi_karyawan/features/beranda/presentation/pages/beranda_page.dart';
import 'package:sistem_presensi_karyawan/features/beranda/presentation/pages/main_wrapper.dart';

import 'package:sistem_presensi_karyawan/features/presensi/presentation/bloc/riwayat_bloc.dart';
import 'package:sistem_presensi_karyawan/features/presensi/presentation/bloc/riwayat_event.dart';
import 'package:sistem_presensi_karyawan/features/presensi/presentation/karyawan/presensi_page.dart';
import 'package:sistem_presensi_karyawan/features/presensi/presentation/pages/presensi_berhasil_page.dart';
import 'package:sistem_presensi_karyawan/features/presensi/presentation/pages/riwayat_presensi_page.dart';

import 'package:sistem_presensi_karyawan/features/izin/presentation/pages/buat_izin_page.dart';
import 'package:sistem_presensi_karyawan/features/izin/presentation/pages/izin_berhasil_page.dart';
import 'package:sistem_presensi_karyawan/features/izin/presentation/pages/izin_page.dart';

import 'package:sistem_presensi_karyawan/features/cuti/presentation/bloc/cuti_bloc.dart';
import 'package:sistem_presensi_karyawan/features/cuti/presentation/pages/buat_cuti.dart';
import 'package:sistem_presensi_karyawan/features/cuti/presentation/pages/cuti_berhasil_page.dart';
import 'package:sistem_presensi_karyawan/features/cuti/presentation/pages/cuti_page.dart';

import 'package:sistem_presensi_karyawan/features/lembur/presentation/bloc/lembur_bloc.dart';
import 'package:sistem_presensi_karyawan/features/lembur/presentation/pages/buat_lembur_page.dart';
import 'package:sistem_presensi_karyawan/features/lembur/presentation/pages/lembur_page.dart';

import 'package:sistem_presensi_karyawan/features/reimbursement/presentation/bloc/reimbursement_bloc.dart';
import 'package:sistem_presensi_karyawan/features/reimbursement/presentation/pages/buat_reimbursement_page.dart';
import 'package:sistem_presensi_karyawan/features/reimbursement/presentation/pages/reimbursement_berhasil_page.dart';
import 'package:sistem_presensi_karyawan/features/reimbursement/presentation/pages/reimbursement_page.dart';

import 'package:sistem_presensi_karyawan/features/profil/presentation/pages/edit_profil_page.dart';
import 'package:sistem_presensi_karyawan/features/profil/presentation/pages/notifikasi_page.dart';
import 'package:sistem_presensi_karyawan/features/profil/presentation/pages/pengaturan_page.dart';
import 'package:sistem_presensi_karyawan/features/profil/presentation/pages/profil_page.dart';
import 'package:sistem_presensi_karyawan/features/profil/presentation/pages/ubah_password_page.dart';

import '../../features/lembur/presentation/pages/lembur_berhasil_page.dart';

import 'package:sistem_presensi_karyawan/features/profil/presentation/pages/tentang_aplikasi_page.dart';
import 'package:sistem_presensi_karyawan/features/profil/presentation/pages/tim_developer_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Helper aman untuk membaca tanggal dari `state.extra`
/// Mendukung objek [DateTime] maupun [String] ISO-8601 saat State Restoration.
DateTime _parseExtraDateTime(dynamic value) {
  if (value is DateTime) return value;
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value) ?? DateTime.now();
  }
  return DateTime.now();
}

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  redirect: (context, state) {
    final currentPath = state.uri.path;
    const publicRoutes = {'/splash', '/login'};

    // Jika rute publik, izinkan langsung
    if (publicRoutes.contains(currentPath)) {
      return null;
    }

    // Hook pengecekan sesi login terpusat:
    // Hubungkan dengan pengecekan token storage / AuthBloc jika ingin memblokir
    // akses deep link atau notifikasi FCM saat sesi sudah logout.
    return null;
  },
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            const Text(
              'Halaman tidak ditemukan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/beranda'),
              child: const Text('Kembali ke Beranda'),
            ),
          ],
        ),
      ),
    ),
  ),
  routes: [
    // --- AUTH & ONBOARDING ---
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),

    // --- PROFIL & PENGATURAN ---
    GoRoute(
      path: '/edit-profil',
      name: 'edit-profil',
      builder: (context, state) => const EditProfilPage(),
    ),
    GoRoute(
      path: '/ubah-password',
      name: 'ubah-password',
      builder: (context, state) => const UbahPasswordPage(),
    ),
    GoRoute(
      path: '/notifikasi',
      name: 'notifikasi',
      builder: (context, state) => const NotifikasiPage(),
    ),
    GoRoute(
      path: '/pengaturan',
      name: 'pengaturan',
      builder: (context, state) => const PengaturanPage(),
    ),

    GoRoute(
      path: '/tim-developer',
      name: 'tim-developer',
      builder: (context, state) => const TimDeveloperPage(),
    ),
    GoRoute(
      path: '/tentang-aplikasi',
      name: 'tentang-aplikasi',
      builder: (context, state) => const TentangAplikasiPage(),
    ),

    // --- PRESENSI ---
    GoRoute(
      path: '/presensi',
      name: 'presensi',
      builder: (context, state) => const PresensiPage(),
    ),
    GoRoute(
      path: '/rekap-presensi',
      name: 'rekap-presensi',
      redirect: (context, state) => '/riwayat',
    ),
    GoRoute(
      path: '/presensi-berhasil',
      name: 'presensi-berhasil',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>? ?? {};

        return PresensiBerhasilPage(
          namaKaryawan: args['namaKaryawan'] as String? ?? 'Karyawan',
          lokasiKantor: args['lokasiKantor'] as String? ?? '-',
          jenisPresensi: args['jenisPresensi'] as String? ?? 'Masuk',
          jarakMeter: args['jarakMeter'] as String? ?? '0',
          waktuPresensi: _parseExtraDateTime(args['waktuPresensi']),
        );
      },
    ),

    // --- IZIN ---
    GoRoute(
      path: '/izin',
      name: 'izin',
      builder: (context, state) => const IzinPage(),
    ),
    GoRoute(
      path: '/buat-izin',
      name: 'buat-izin',
      builder: (context, state) => const BuatIzinPage(),
    ),
    GoRoute(
      path: '/izin-berhasil',
      name: 'izin-berhasil',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>? ?? {};

        return IzinBerhasilPage(
          namaKaryawan: args['namaKaryawan'] as String? ?? 'Karyawan',
          jenisIzin: args['jenisIzin'] as String? ?? 'Sakit',
          keterangan: args['keterangan'] as String? ?? '-',
          tanggalMulai: _parseExtraDateTime(args['tanggalMulai']),
          tanggalSelesai: _parseExtraDateTime(args['tanggalSelesai']),
          namaLampiran: args['namaLampiran'] as String?,
        );
      },
    ),

    // --- CUTI (Berbagi 1 Instance CutiBloc) ---
    ShellRoute(
      builder: (context, state, child) => BlocProvider(
        create: (_) => sl<CutiBloc>(),
        child: child,
      ),
      routes: [
        GoRoute(
          path: '/cuti',
          name: 'cuti',
          builder: (context, state) => const CutiPage(),
        ),
        GoRoute(
          path: '/buat-cuti',
          name: 'buat-cuti',
          builder: (context, state) => const BuatCutiPage(),
        ),
        GoRoute(
          path: '/cuti-berhasil',
          name: 'cuti-berhasil',
          builder: (context, state) {
            final args = state.extra as Map<String, dynamic>? ?? {};

            return CutiBerhasilPage(
              namaKaryawan: args['namaKaryawan'] as String? ?? 'Karyawan',
              jenisCuti: args['jenisCuti'] as String? ?? 'Cuti Tahunan',
              keterangan: args['keterangan'] as String? ?? '-',
              tanggalMulai: _parseExtraDateTime(args['tanggalMulai']),
              tanggalSelesai: _parseExtraDateTime(args['tanggalSelesai']),
            );
          },
        ),
      ],
    ),

    ShellRoute(
      builder: (context, state, child) => BlocProvider(
        create: (_) => sl<LemburBloc>(),
        child: child,
      ),
      routes: [
        GoRoute(
          path: '/lembur',
          name: 'lembur',
          builder: (context, state) => const LemburPage(),
        ),
        GoRoute(
          path: '/buat-lembur',
          name: 'buat-lembur',
          builder: (context, state) => const BuatLemburPage(),
        ),
        GoRoute(
          path: '/lembur-berhasil',
          name: 'lembur-berhasil',
          builder: (context, state) {
            final args = state.extra as Map<String, dynamic>? ?? {};

            return LemburBerhasilPage(
              namaKaryawan: args['namaKaryawan'] as String? ?? 'Karyawan',
              tanggalLembur: args['tanggalLembur'] as String? ?? '-',
              waktuLembur: args['waktuLembur'] as String? ?? '-',
              durasi: args['durasi'] as String? ?? '-',
              alasanLembur: args['alasanLembur'] as String? ?? '-',
            );
          },
        ),
      ],
    ),

    // --- REIMBURSEMENT (Berbagi 1 Instance ReimbursementBloc & Aman dari Closed BLoC) ---
    ShellRoute(
      builder: (context, state, child) => BlocProvider(
        create: (_) => sl<ReimbursementBloc>(),
        child: child,
      ),
      routes: [
        GoRoute(
          path: '/reimbursement',
          name: 'reimbursement',
          builder: (context, state) => const ReimbursementPage(),
        ),
        GoRoute(
          path: '/buat-reimbursement',
          name: 'buat-reimbursement',
          builder: (context, state) => const BuatReimbursementPage(),
        ),
        GoRoute(
          path: '/reimbursement-berhasil',
          name: 'reimbursement-berhasil',
          builder: (context, state) {
            final args = state.extra as Map<String, dynamic>? ?? {};
            final bloc = args['bloc'] as ReimbursementBloc?;

            if (bloc != null && !bloc.isClosed) {
              return BlocProvider.value(
                value: bloc,
                child: const ReimbursementBerhasilPage(),
              );
            }

            return const ReimbursementBerhasilPage();
          },
        ),
      ],
    ),

    // --- MAIN BOTTOM NAVIGATION SHELL ---
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainWrapper(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/beranda',
              name: 'beranda',
              builder: (context, state) => BlocProvider(
                create: (_) =>
                sl<RiwayatBloc>()..add(LoadRiwayatRequested(DateTime.now())),
                child: const BerandaPage(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/riwayat',
              name: 'riwayat',
              builder: (context, state) => const RiwayatPresensiPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dummy-izin',
              redirect: (context, state) => '/beranda',
              builder: (context, state) => const SizedBox.shrink(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profil',
              name: 'profil',
              builder: (context, state) => const ProfilPage(),
            ),
          ],
        ),
      ],
    ),
  ],
);