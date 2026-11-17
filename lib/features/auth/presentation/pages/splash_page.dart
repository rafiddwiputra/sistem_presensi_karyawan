import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
  late final AnimationController _mainController;
  late final AnimationController _exitController;

  late final Animation<double> _traceProgress;
  late final Animation<double> _nodesOpacity;
  late final Animation<double> _logoReveal;
  late final Animation<double> _logoScale;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;

  late final Animation<double> _exitScale;
  late final Animation<double> _exitOpacity;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _navigateToNext();
  }

  void _setupAnimations() {
    // Total durasi animasi masuk: 2.2 detik
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    // Durasi transisi keluar sebelum pindah halaman
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    // 1. Menggambar garis vektor sirkuit & robot (0% - 58%)
    _traceProgress = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.58, curve: Curves.easeInOutCubic),
    );

    // 2. Titik simpul kotak (anchor nodes) memudar setelah garis selesai (52% - 72%)
    _nodesOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.52, 0.72, curve: Curves.easeOut),
      ),
    );

    // 3. Logo asli menyatu halus menggantikan wireframe (55% - 80%)
    _logoReveal = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.55, 0.80, curve: Curves.easeInOut),
    );

    _logoScale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.55, 0.85, curve: Curves.easeOutBack),
      ),
    );

    // 4. Teks judul & footer muncul bertahap (65% - 100%)
    _textOpacity = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.65, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // 5. Efek zoom-fade saat keluar menuju halaman berikutnya
    _exitScale = Tween<double>(begin: 1.0, end: 1.2).animate(
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

    _mainController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  Future<void> _navigateToNext() async {
    // Beri jeda singkat 350ms agar frame awal animasi berjalan mulus 60 FPS
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;

    final authBloc = context.read<AuthBloc>();
    authBloc.add(const CheckAuthStatusRequested());

    // Tahan sisa waktu hingga total ±2.45 detik agar seluruh animasi selesai tampil
    await Future.delayed(const Duration(milliseconds: 2100));
    if (!mounted) return;

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
        animation: Listenable.merge([_mainController, _exitController]),
        builder: (context, _) {
          return Opacity(
            opacity: _exitOpacity.value,
            child: Transform.scale(
              scale: _exitScale.value,
              child: Stack(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 124,
                            width: 124,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Layer 1: Vector Path Tracing + Anchor Nodes (60 FPS Cached)
                                Opacity(
                                  opacity: 1.0 - (_logoReveal.value * 0.85),
                                  child: CustomPaint(
                                    size: const Size(124, 124),
                                    painter: _LogoVectorPainter(
                                      progress: _traceProgress.value,
                                      nodesOpacity: _nodesOpacity.value,
                                      bgColor: AppColors.primary,
                                    ),
                                  ),
                                ),
                                // Layer 2: Logo resmi tim muncul menyatu
                                Opacity(
                                  opacity: _logoReveal.value,
                                  child: Transform.scale(
                                    scale: _logoScale.value,
                                    child: Container(
                                      height: 112,
                                      width: 112,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(28),
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: 0.35 * _logoReveal.value,
                                          ),
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.16 * _logoReveal.value,
                                            ),
                                            blurRadius: 20,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(26),
                                        child: Image.asset(
                                          'assets/images/logo.jpeg',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          FadeTransition(
                            opacity: _textOpacity,
                            child: SlideTransition(
                              position: _textSlide,
                              child: Column(
                                children: [
                                  const Text(
                                    'SISTEM PRESENSI KARYAWAN',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 1.8,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Portal Karyawan Terpadu',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white.withValues(alpha: 0.85),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 48,
                    left: 0,
                    right: 0,
                    child: FadeTransition(
                      opacity: _textOpacity,
                      child: Column(
                        children: [
                          Text(
                            'Powered by',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'TECH ENTHUSIAST',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.0,
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

class _LogoVectorPainter extends CustomPainter {
  final double progress;
  final double nodesOpacity;
  final Color bgColor;

  // Cache PathMetric agar tidak dihitung ulang setiap frame (kunci 60 FPS)
  static Size? _cachedSize;
  static List<PathMetric>? _cachedMetrics;
  static List<List<dynamic>>? _cachedNodes;

  _LogoVectorPainter({
    required this.progress,
    required this.nodesOpacity,
    required this.bgColor,
  });

  static void _ensureGeometryCached(Size size) {
    if (_cachedSize == size && _cachedMetrics != null) return;

    final double w = size.width;
    final double h = size.height;
    Offset p(double x, double y) => Offset(x * w, y * h);

    final List<Path> tracks = [
      // Bingkai luar sirkuit oval dengan lekukan kanan atas
      Path()
        ..moveTo(0.24 * w, 0.72 * h)
        ..lineTo(0.24 * w, 0.34 * h)
        ..quadraticBezierTo(0.24 * w, 0.14 * h, 0.50 * w, 0.14 * h)
        ..quadraticBezierTo(0.64 * w, 0.14 * h, 0.70 * w, 0.22 * h)
        ..lineTo(0.75 * w, 0.18 * h)
        ..quadraticBezierTo(0.82 * w, 0.28 * h, 0.80 * w, 0.54 * h)
        ..lineTo(0.74 * w, 0.68 * h)
        ..lineTo(0.56 * w, 0.86 * h),

      // Jalur sirkuit kedua mengelilingi kepala robot
      Path()
        ..moveTo(0.31 * w, 0.66 * h)
        ..lineTo(0.31 * w, 0.36 * h)
        ..quadraticBezierTo(0.31 * w, 0.22 * h, 0.50 * w, 0.22 * h)
        ..lineTo(0.62 * w, 0.27 * h)
        ..lineTo(0.72 * w, 0.27 * h)
        ..lineTo(0.72 * w, 0.56 * h)
        ..lineTo(0.50 * w, 0.78 * h)
        ..lineTo(0.36 * w, 0.64 * h),

      // Kepala robot di tengah
      Path()
        ..moveTo(0.39 * w, 0.35 * h)
        ..lineTo(0.61 * w, 0.35 * h)
        ..lineTo(0.61 * w, 0.50 * h)
        ..lineTo(0.56 * w, 0.55 * h)
        ..lineTo(0.44 * w, 0.55 * h)
        ..lineTo(0.39 * w, 0.50 * h)
        ..close(),

      // Mata kiri & kanan robot
      Path()
        ..moveTo(0.455 * w, 0.41 * h)
        ..lineTo(0.455 * w, 0.48 * h),
      Path()
        ..moveTo(0.545 * w, 0.41 * h)
        ..lineTo(0.545 * w, 0.48 * h),

      // Sensor telinga kiri & kanan
      Path()
        ..moveTo(0.345 * w, 0.40 * h)
        ..lineTo(0.345 * w, 0.50 * h),
      Path()
        ..moveTo(0.655 * w, 0.40 * h)
        ..lineTo(0.655 * w, 0.50 * h),

      // Chevron bawah sidik jari
      Path()
        ..moveTo(0.42 * w, 0.83 * h)
        ..lineTo(0.50 * w, 0.75 * h)
        ..lineTo(0.58 * w, 0.83 * h),
    ];

    final metrics = <PathMetric>[];
    for (final path in tracks) {
      metrics.addAll(path.computeMetrics());
    }

    _cachedSize = size;
    _cachedMetrics = metrics;
    _cachedNodes = [
      [p(0.24, 0.34), 0.15],
      [p(0.50, 0.14), 0.35],
      [p(0.75, 0.18), 0.55],
      [p(0.80, 0.54), 0.75],
      [p(0.56, 0.86), 0.92],
      [p(0.31, 0.36), 0.20],
      [p(0.50, 0.22), 0.42],
      [p(0.72, 0.27), 0.62],
      [p(0.50, 0.78), 0.85],
      [p(0.39, 0.35), 0.10],
      [p(0.61, 0.35), 0.30],
      [p(0.61, 0.50), 0.50],
      [p(0.56, 0.55), 0.65],
      [p(0.44, 0.55), 0.78],
      [p(0.39, 0.50), 0.90],
      [p(0.42, 0.83), 0.30],
      [p(0.50, 0.75), 0.60],
      [p(0.58, 0.83), 0.90],
    ];
  }

  @override
  void paint(Canvas canvas, Size size) {
    _ensureGeometryCached(size);

    final metrics = _cachedMetrics!;
    final nodes = _cachedNodes!;

    final Paint strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.miter;

    final Paint tipPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final Paint tipHaloPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    for (final metric in metrics) {
      final double currentLen = metric.length * progress;
      if (currentLen > 0) {
        canvas.drawPath(metric.extractPath(0, currentLen), strokePaint);

        if (progress > 0.02 && progress < 0.98) {
          final Tangent? tangent = metric.getTangentForOffset(currentLen);
          if (tangent != null) {
            canvas.drawCircle(tangent.position, 4.5, tipHaloPaint);
            canvas.drawCircle(tangent.position, 2.2, tipPaint);
          }
        }
      }
    }

    if (nodesOpacity > 0.01) {
      final Paint nodeStroke = Paint()
        ..color = Colors.white.withValues(alpha: nodesOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3;

      final Paint nodeFill = Paint()
        ..color = bgColor.withValues(alpha: nodesOpacity)
        ..style = PaintingStyle.fill;

      for (final item in nodes) {
        final Offset pos = item[0] as Offset;
        final double threshold = item[1] as double;
        if (progress >= threshold) {
          final Rect rect = Rect.fromCenter(center: pos, width: 5.5, height: 5.5);
          canvas.drawRect(rect, nodeFill);
          canvas.drawRect(rect, nodeStroke);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LogoVectorPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.nodesOpacity != nodesOpacity;
  }
}