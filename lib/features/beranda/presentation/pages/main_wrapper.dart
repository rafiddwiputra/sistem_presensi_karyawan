import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
  const MainWrapper({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  void _onTap(BuildContext context, int index) {
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
    final Color bgApp = isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC);
    final Color navBgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color primaryColor = isDark ? const Color(0xFF3B82F6) : const Color(0xFF1E61B6);
    final Color inactiveColor = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);

    final int currentIndex = navigationShell.currentIndex;

    return Scaffold(
      backgroundColor: bgApp,
      extendBody: true,
      body: navigationShell,

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        height: 60.w,
        width: 60.w,
        child: FloatingActionButton(
          onPressed: () => context.push('/presensi'),
          backgroundColor: primaryColor,
          elevation: isDark ? 2 : 8,
          shape: const CircleBorder(),
          child: Icon(Icons.fingerprint, color: Colors.white, size: 32.w),
        ),
      ),

      bottomNavigationBar: Container(
        margin: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 24.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 20.r,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: BottomAppBar(
          padding: EdgeInsets.zero,
          height: 70.h,
          color: navBgColor,
          surfaceTintColor: navBgColor,
          elevation: 0,
          notchMargin: 10.w,
          clipBehavior: Clip.antiAlias,
          shape: _OffsetNotchedShape(
            AutomaticNotchedShape(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32.r),
              ),
              const CircleBorder(),
            ),
            -20.w,
          ),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildDotNavItem(
                      activeIcon: Icons.home_rounded,
                      inactiveIcon: Icons.home_outlined,
                      index: 0,
                      currentIndex: currentIndex,
                      context: context,
                      primaryColor: primaryColor,
                      inactiveColor: inactiveColor,
                    ),
                    _buildDotNavItem(
                      activeIcon: Icons.receipt_long,
                      inactiveIcon: Icons.receipt_long_outlined,
                      index: 1,
                      currentIndex: currentIndex,
                      context: context,
                      primaryColor: primaryColor,
                      inactiveColor: inactiveColor,
                    ),
                  ],
                ),
              ),

              SizedBox(width: 60.w),

              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildDotNavItem(
                      activeIcon: Icons.edit_document,
                      inactiveIcon: Icons.edit_document,
                      index: 2,
                      currentIndex: currentIndex,
                      context: context,
                      primaryColor: primaryColor,
                      inactiveColor: inactiveColor,
                    ),
                    _buildDotNavItem(
                      activeIcon: Icons.person_rounded,
                      inactiveIcon: Icons.person_outline_rounded,
                      index: 3,
                      currentIndex: currentIndex,
                      context: context,
                      primaryColor: primaryColor,
                      inactiveColor: inactiveColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDotNavItem({
    required IconData activeIcon,
    required IconData inactiveIcon,
    required int index,
    required int currentIndex,
    required BuildContext context,
    required Color primaryColor,
    required Color inactiveColor,
  }) {
    final bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => _onTap(context, index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 50.w,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
        AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: Icon(
          isSelected ? activeIcon : inactiveIcon,
          key: ValueKey<bool>(isSelected),
          size: 26.sp,
          color: isSelected ? primaryColor : inactiveColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}