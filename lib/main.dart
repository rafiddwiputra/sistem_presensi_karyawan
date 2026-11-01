import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app/theme/app_theme.dart';
import 'core/routes/app_router.dart';
import 'app/theme/theme_notifier.dart';
import 'core/di/injection.dart'; // tambahkan ini

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // wajib sebelum operasi async
  await setupInjection(); // daftarkan semua dependency ke GetIt
  runApp(const EmployeeAttendanceApp());
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
              darkTheme: ThemeData.dark().copyWith(
                scaffoldBackgroundColor: const Color(0xFF121212),
                cardColor: const Color(0xFF1E1E1E),
                colorScheme: const ColorScheme.dark(
                  primary: Color(0xFF1E61B6),
                  surface: Color(0xFF1E1E1E),
                ),
              ),
              themeMode: currentThemeMode,
              routerConfig: appRouter,
            );
          },
        );
      },
    );
  }
}