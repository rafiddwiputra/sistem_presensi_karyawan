import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:sistem_presensi_karyawan/app/theme/app_theme.dart';
import 'package:sistem_presensi_karyawan/app/theme/theme_notifier.dart';
import 'package:sistem_presensi_karyawan/core/di/injection.dart';
import 'package:sistem_presensi_karyawan/core/routes/app_router.dart';
import 'package:sistem_presensi_karyawan/core/services/fcm_service.dart';
import 'package:sistem_presensi_karyawan/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sistem_presensi_karyawan/features/profil/presentation/bloc/profil_bloc.dart';

import 'core/services/notification_preferences_service.dart';
import 'features/auth/presentation/bloc/auth_state.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  runZonedGuarded(
        () async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      await initializeDateFormatting('id_ID', null);
      await setupInjection();
      await ThemeNotifier.init();
      await sl<NotificationPreferencesService>().init();
      await sl<FcmService>().initialize();

      runApp(
        MultiBlocProvider(
          providers: [
            BlocProvider.value(value: sl<ProfilBloc>()),
            BlocProvider.value(value: sl<AuthBloc>()),
          ],
          child: const EmployeeAttendanceApp(),
        ),
      );
    },
        (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Uncaught Enterprise Error: $error\n$stackTrace');
      }
    },
  );
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
            return BlocListener<AuthBloc, AuthState>(
              listenWhen: (previous, current) => current is AuthUnauthenticated,
              listener: (context, state) {
                if (state is AuthUnauthenticated) {
                  appRouter.go('/login');
                  final message = state.message;
                  if (message != null && message.isNotEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      final navContext =
                          appRouter.routerDelegate.navigatorKey.currentContext;
                      if (navContext != null) {
                        ScaffoldMessenger.of(navContext)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(
                              content: Text(message),
                              backgroundColor: const Color(0xFFEF4444),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                      }
                    });
                  }
                }
              },
              child: MaterialApp.router(
                title: 'Sistem Presensi Karyawan',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                themeMode: currentThemeMode,
                routerConfig: appRouter,
              ),
            );
          },
        );
      },
    );
  }
}