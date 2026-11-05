import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:sistem_presensi_karyawan/features/auth/presentation/pages/splash_page.dart';

import 'package:sistem_presensi_karyawan/features/beranda/presentation/pages/main_wrapper.dart';

import 'package:sistem_presensi_karyawan/features/auth/presentation/pages/login_page.dart';
import 'package:sistem_presensi_karyawan/features/beranda/presentation/pages/beranda_page.dart';
import 'package:sistem_presensi_karyawan/features/presensi/presentation/karyawan/presensi_page.dart';
import 'package:sistem_presensi_karyawan/features/presensi/presentation/pages/riwayat_presensi_page.dart'; // Sesuaikan path jika berbeda

import 'package:sistem_presensi_karyawan/features/izin/presentation/pages/izin_page.dart';
import 'package:sistem_presensi_karyawan/features/izin/presentation/pages/buat_izin_page.dart';
import 'package:sistem_presensi_karyawan/features/izin/presentation/pages/izin_berhasil_page.dart';

import 'package:sistem_presensi_karyawan/features/cuti/presentation/pages/cuti_page.dart';
import 'package:sistem_presensi_karyawan/features/cuti/presentation/pages/buat_cuti.dart';
import 'package:sistem_presensi_karyawan/features/cuti/presentation/pages/cuti_berhasil_page.dart';

import 'package:sistem_presensi_karyawan/features/lembur/presentation/pages/lembur_page.dart';
import 'package:sistem_presensi_karyawan/features/lembur/presentation/pages/buat_lembur_page.dart';
import 'package:sistem_presensi_karyawan/features/lembur/presentation/pages/lembur_berhasil_page.dart';

import 'package:sistem_presensi_karyawan/features/reimbursement/presentation/pages/reimbursement_page.dart';
import 'package:sistem_presensi_karyawan/features/reimbursement/presentation/pages/buat_reimbursement_page.dart';
import 'package:sistem_presensi_karyawan/features/reimbursement/presentation/pages/reimbursement_berhasil_page.dart';

import 'package:sistem_presensi_karyawan/features/profil/presentation/pages/profil_page.dart';
import 'package:sistem_presensi_karyawan/features/profil/presentation/pages/edit_profil_page.dart';
import 'package:sistem_presensi_karyawan/features/profil/presentation/pages/ubah_password_page.dart';
import 'package:sistem_presensi_karyawan/features/profil/presentation/pages/notifikasi_page.dart';
import 'package:sistem_presensi_karyawan/features/profil/presentation/pages/pengaturan_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [

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
      path: '/presensi',
      name: 'presensi',
      builder: (context, state) => const PresensiPage(),
    ),
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
      builder: (context, state) => const IzinBerhasilPage(),
    ),
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
      builder: (context, state) => const CutiBerhasilPage(),
    ),
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
      builder: (context, state) => const LemburBerhasilPage(),
    ),
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
      builder: (context, state) => const ReimbursementBerhasilPage(),
    ),

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
              builder: (context, state) => const BerandaPage(),
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
              builder: (context, state) => const SizedBox(),
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