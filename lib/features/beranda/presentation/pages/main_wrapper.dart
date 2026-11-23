import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class _OffsetNotchedShape extends NotchedShape {
  final NotchedShape shape;
  final double offsetX;

  const _OffsetNotchedShape(this.shape, this.offsetX);

  @override
  Path getOuterPath(Rect host, Rect? guest) {
    if (guest != null) {
      guest = guest.shift(Offset(offsetX, 0));
    }
    return shape.getOuterPath(host, guest);
  }
}

class MainWrapper extends StatelessWidget {
  const MainWrapper({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTap(BuildContext context, int index) {
    HapticFeedback.selectionClick();

    if (index == 2) {
      context.push('/izin');
      return;
    }

    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgApp =
    isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC);
    final Color navBgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color primaryColor =
    isDark ? const Color(0xFF60A5FA) : const Color(0xFF1E61B6);
    final Color inactiveColor =
    isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);

    final int currentIndex = navigationShell.currentIndex;

    final double horizontalMargin = 18.w.clamp(16.0, 22.0);
    final double systemBottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final double bottomMargin = math.max(16.0, systemBottomInset + 4.0);
    const double barHeight = 64.0;
    const double fabSize = 56.0;

    return Scaffold(
      backgroundColor: bgApp,
      extendBody: true,
      body: navigationShell,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        height: fabSize,
        width: fabSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [Color(0xFF3B82F6), Color(0xFF1D4ED8)]
                : const [Color(0xFF2563EB), Color(0xFF154B8C)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E61B6).withValues(
                alpha: isDark ? 0.45 : 0.35,
              ),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              HapticFeedback.lightImpact();
              context.push('/presensi');
            },
            child: const Center(
              child: Icon(
                Icons.fingerprint_rounded,
                color: Colors.white,
                size: 29,
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(
          left: horizontalMargin,
          right: horizontalMargin,
          bottom: bottomMargin,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          removeBottom: true,
          child: BottomAppBar(
            padding: EdgeInsets.zero,
            height: barHeight,
            color: navBgColor,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            notchMargin: 7.0,
            clipBehavior: Clip.antiAlias,
            shape: _OffsetNotchedShape(
              AutomaticNotchedShape(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                const CircleBorder(),
              ),
              -horizontalMargin,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNavItem(
                          context: context,
                          index: 0,
                          currentIndex: currentIndex,
                          activeIcon: Icons.home_rounded,
                          inactiveIcon: Icons.home_outlined,
                          label: 'Beranda',
                          primaryColor: primaryColor,
                          inactiveColor: inactiveColor,
                          isDark: isDark,
                        ),
                        _buildNavItem(
                          context: context,
                          index: 1,
                          currentIndex: currentIndex,
                          activeIcon: Icons.receipt_long_rounded,
                          inactiveIcon: Icons.receipt_long_outlined,
                          label: 'Riwayat',
                          primaryColor: primaryColor,
                          inactiveColor: inactiveColor,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: fabSize + 24),

                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNavItem(
                          context: context,
                          index: 2,
                          currentIndex: currentIndex,
                          activeIcon: Icons.edit_document,
                          inactiveIcon: Icons.description_outlined,
                          label: 'Pengajuan',
                          primaryColor: primaryColor,
                          inactiveColor: inactiveColor,
                          isDark: isDark,
                        ),
                        _buildNavItem(
                          context: context,
                          index: 3,
                          currentIndex: currentIndex,
                          activeIcon: Icons.person_rounded,
                          inactiveIcon: Icons.person_outline_rounded,
                          label: 'Profil',
                          primaryColor: primaryColor,
                          inactiveColor: inactiveColor,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required int currentIndex,
    required IconData activeIcon,
    required IconData inactiveIcon,
    required String label,
    required Color primaryColor,
    required Color inactiveColor,
    required bool isDark,
  }) {
    final bool isSelected = currentIndex == index;
    final Color activePillBg = isDark
        ? const Color(0xFF1E3A8A).withValues(alpha: 0.35)
        : const Color(0xFFEFF6FF);

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTap(context, index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? activePillBg : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: AnimatedScale(
                scale: isSelected ? 1.06 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isSelected ? activeIcon : inactiveIcon,
                  size: 21,
                  color: isSelected ? primaryColor : inactiveColor,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.sp.clamp(9.5, 11.0),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? primaryColor : inactiveColor,
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}