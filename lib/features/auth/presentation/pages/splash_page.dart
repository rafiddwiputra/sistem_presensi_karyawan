import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../../app/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late final AnimationController _lottieController;
  late final AnimationController _exitController;

  late final Animation<double> _footerOpacity;
  late final Animation<double> _exitScale;
  late final Animation<double> _exitOpacity;

  bool _isNavigating = false;
  Timer? _fallbackTimer;

  @override
  void initState() {
    super.initState();
    _setupAnimations();

    context.read<AuthBloc>().add(const CheckAuthStatusRequested());

    _fallbackTimer = Timer(const Duration(milliseconds: 5000), _proceedToNextPage);
  }

  void _setupAnimations() {
    _lottieController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _footerOpacity = CurvedAnimation(
      parent: _lottieController,
      curve: const Interval(0.70, 1.0, curve: Curves.easeOut),
    );

    _exitScale = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _exitController,
        curve: Curves.easeInCubic,
      ),
    );

    _exitOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _exitController,
        curve: Curves.easeIn,
      ),
    );
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _lottieController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  Future<void> _proceedToNextPage() async {
    if (_isNavigating || !mounted) return;
    _isNavigating = true;
    _fallbackTimer?.cancel();

    final authBloc = context.read<AuthBloc>();
    AuthState currentState = authBloc.state;

    if (currentState is AuthInitial || currentState is AuthLoading) {
      currentState = await authBloc.stream.firstWhere(
            (state) =>
        state is AuthSuccess ||
            state is AuthUnauthenticated ||
            state is AuthError,
      );
    }

    if (!mounted) return;

    await _exitController.forward();
    if (!mounted) return;

    if (currentState is AuthSuccess) {
      context.go('/beranda');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: AnimatedBuilder(
        animation: Listenable.merge([_lottieController, _exitController]),
        builder: (context, _) {
          return Opacity(
            opacity: _exitOpacity.value,
            child: Transform.scale(
              scale: _exitScale.value,
              child: Stack(
                fit: StackFit.expand,
                children: [

                  Center(
                    child: Lottie.asset(
                      'assets/animations/splash_robot_logo.json',
                      controller: _lottieController,
                      width: MediaQuery.sizeOf(context).width,
                      height: MediaQuery.sizeOf(context).height,
                      fit: BoxFit.contain,
                      options: LottieOptions(enableMergePaths: true),
                      onWarning: (warning) => debugPrint('Lottie Warning: $warning'),
                      onLoaded: (composition) {
                        debugPrint('Lottie Loaded: ${composition.bounds}');
                        _lottieController
                          ..duration = composition.duration
                          ..forward().whenComplete(_proceedToNextPage);
                      },
                    ),
                  ),

                  Positioned(
                    bottom: 44,
                    left: 24,
                    right: 24,
                    child: FadeTransition(
                      opacity: _footerOpacity,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'SISTEM PRESENSI KARYAWAN',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Powered by TECH ENTHUSIAST',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.75),
                              letterSpacing: 0.8,
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
        },
      ),
    );
  }
}