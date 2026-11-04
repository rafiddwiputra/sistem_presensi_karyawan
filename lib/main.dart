import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sistem_presensi_karyawan/app/theme/app_theme.dart';
import 'package:sistem_presensi_karyawan/core/routes/app_router.dart';
import 'package:sistem_presensi_karyawan/app/theme/theme_notifier.dart';
import 'package:sistem_presensi_karyawan/core/di/injection.dart';
import 'package:sistem_presensi_karyawan/features/profil/presentation/bloc/profil_bloc.dart';
import 'package:sistem_presensi_karyawan/features/auth/presentation/bloc/auth_bloc.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await setupInjection();

    runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(
            value: sl<ProfilBloc>(),
          ),
          BlocProvider.value(
            value: sl<AuthBloc>(),
          ),
        ],
        child: const EmployeeAttendanceApp(),
      ),
    );
  }, (error, stackTrace) {
    if (kDebugMode) {
      debugPrint('Uncaught Enterprise Error: $error\n$stackTrace');
    }

  });
}

class EmployeeAttendanceApp extends StatelessWidget {
  const EmployeeAttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: appThemeNotifier,
          builder: (context, currentThemeMode, child) {
            return MaterialApp.router(
              title: 'Sistem Presensi Karyawan',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              // DIPERBAIKI: Menggunakan AppTheme.dark agar terpusat dan konsisten
              darkTheme: AppTheme.dark,
              themeMode: currentThemeMode,
              routerConfig: appRouter,
            );
          },
        );
      },
    );
  }
}