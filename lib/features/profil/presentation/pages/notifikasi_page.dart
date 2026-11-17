import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/fcm_service.dart';
import '../../data/models/notifikasi_model.dart';
import '../bloc/notifikasi_bloc.dart';
import '../bloc/notifikasi_event.dart';
import '../bloc/notifikasi_state.dart';

class NotifikasiPage extends StatelessWidget {
  const NotifikasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
      sl<NotifikasiBloc>()..add(const LoadNotifikasiRequested()),
      child: const NotifikasiView(),
    );
  }
}

class NotifikasiView extends StatefulWidget {
  const NotifikasiView({super.key});

  @override
  State<NotifikasiView> createState() => _NotifikasiViewState();
}

class _NotifikasiViewState extends State<NotifikasiView> {
  final ScrollController _scrollController = ScrollController();
  StreamSubscription<void>? _fcmSubscription;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fcmSubscription = sl<FcmService>().onNotificationReceived.listen((_) {
      if (!mounted) return;
      final currentState = context.read<NotifikasiBloc>().state;
      String? kategori;
      bool unreadOnly = false;

      if (currentState is NotifikasiLoaded) {
        kategori = currentState.selectedKategori;
        unreadOnly = currentState.unreadOnly;
      } else if (currentState is NotifikasiLoading) {
        kategori = currentState.selectedKategori;
        unreadOnly = currentState.unreadOnly;
      } else if (currentState is NotifikasiError) {
        kategori = currentState.selectedKategori;
        unreadOnly = currentState.unreadOnly;
      }

      context.read<NotifikasiBloc>().add(
        LoadNotifikasiRequested(
          kategori: kategori,
          unreadOnly: unreadOnly,
          silent: true,
        ),
      );
    });
  }

  @override
  void dispose() {
    _fcmSubscription?.cancel();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll - 200) {
      context.read<NotifikasiBloc>().add(const LoadMoreNotifikasiRequested());
    }
  }

  String _formatItemTime(NotifikasiModel item) {
    if (item.isToday) {
      return DateFormat('HH.mm').format(item.dibuatPada);
    }
    return DateFormat('dd/MM/yyyy').format(item.dibuatPada);
  }

  _NotificationVisualStyle _resolveVisualStyle(
      NotifikasiModel item,
      bool isDark,
      ) {
    final kategori = item.kategori.toLowerCase();
    final tipe = item.tipe.toLowerCase();
    final metode = item.referensi['metode']?.toString().toLowerCase() ?? '';
    final statusRef = item.referensi['status']?.toString().toLowerCase() ?? '';

    if (kategori == 'presensi' || tipe.contains('presensi')) {
      final isBiometric = metode == 'fingerprint' ||
          metode == 'biometrik' ||
          tipe.contains('fingerprint') ||
          tipe.contains('biometrik');

      return _NotificationVisualStyle(
        icon: Icons.check_circle,
        iconBgColor: isDark
            ? const Color(0xFF064E3B).withValues(alpha: 0.4)
            : const Color(0xFFCCFBF1),
        iconColor: isDark
            ? const Color(0xFF2DD4BF)
            : const Color(0xFF0F766E),
        badgeText: isBiometric ? 'Biometrik Terverifikasi' : 'Presensi Valid',
        badgeBgColor: isBiometric
            ? (isDark
            ? const Color(0xFF312E81).withValues(alpha: 0.4)
            : const Color(0xFFE0E7FF))
            : (isDark
            ? const Color(0xFF064E3B).withValues(alpha: 0.4)
            : const Color(0xFFCCFBF1)),
        badgeTextColor: isBiometric
            ? (isDark ? const Color(0xFF818CF8) : const Color(0xFF4338CA))
            : (isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0F766E)),
        badgeIcon: isBiometric ? Icons.fingerprint : null,
      );
    }

    final isRejected = statusRef == 'ditolak' ||
        statusRef == 'rejected' ||
        tipe.contains('ditolak');
    final isPending = statusRef == 'menunggu' ||
        statusRef == 'pending' ||
        tipe.contains('menunggu');

    final IconData leadingIcon =
    (tipe.contains('lembur') || tipe.contains('reimbursement'))
        ? Icons.description_outlined
        : Icons.calendar_today_outlined;

    if (isRejected) {
      return _NotificationVisualStyle(
        icon: leadingIcon,
        iconBgColor: isDark
            ? const Color(0xFF7F1D1D).withValues(alpha: 0.35)
            : const Color(0xFFFEE2E2),
        iconColor: isDark
            ? const Color(0xFFF87171)
            : const Color(0xFFDC2626),
        badgeText: 'Ditolak',
        badgeBgColor: isDark
            ? const Color(0xFF7F1D1D).withValues(alpha: 0.35)
            : const Color(0xFFFEE2E2),
        badgeTextColor: isDark
            ? const Color(0xFFF87171)
            : const Color(0xFFDC2626),
        badgeIcon: Icons.cancel_outlined,
      );
    }

    if (isPending) {
      return _NotificationVisualStyle(
        icon: leadingIcon,
        iconBgColor: isDark
            ? const Color(0xFF78350F).withValues(alpha: 0.35)
            : const Color(0xFFFEF3C7),
        iconColor: isDark
            ? const Color(0xFFFBBF24)
            : const Color(0xFFD97706),
        badgeText: 'Menunggu Persetujuan',
        badgeBgColor: isDark
            ? const Color(0xFF78350F).withValues(alpha: 0.35)
            : const Color(0xFFFEF3C7),
        badgeTextColor: isDark
            ? const Color(0xFFFBBF24)
            : const Color(0xFFD97706),
        badgeIcon: Icons.schedule,
      );
    }

    return _NotificationVisualStyle(
      icon: leadingIcon,
      iconBgColor: isDark
          ? const Color(0xFF1E3A8A).withValues(alpha: 0.3)
          : const Color(0xFFEFF6FF),
      iconColor: isDark
          ? const Color(0xFF94A3B8)
          : const Color(0xFF64748B),
      badgeText: statusRef == 'disetujui_admin'
          ? 'Disetujui Admin'
          : 'Disetujui',
      badgeBgColor: isDark
          ? const Color(0xFF064E3B).withValues(alpha: 0.4)
          : const Color(0xFFCCFBF1),
      badgeTextColor: isDark
          ? const Color(0xFF2DD4BF)
          : const Color(0xFF0F766E),
      badgeIcon: Icons.verified_outlined,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool canPop = context.canPop();

    final Color bgApp = isDark
        ? const Color(0xFF121212)
        : const Color(0xFFF8FAFC);
    final Color headerBg = isDark
        ? const Color(0xFF154B8C)
        : const Color(0xFF1E61B6);
    final Color sectionTextColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF475569);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: BlocConsumer<NotifikasiBloc, NotifikasiState>(
        listenWhen: (prev, curr) =>
        curr is NotifikasiLoaded && curr.actionMessage != null,
        listener: (context, state) {
          if (state is NotifikasiLoaded && state.actionMessage != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.actionMessage!),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
          }
        },
        builder: (context, state) {
          final String? selectedKategori = state is NotifikasiLoaded
              ? state.selectedKategori
              : (state is NotifikasiLoading
              ? state.selectedKategori
              : (state is NotifikasiError
              ? state.selectedKategori
              : null));

          final bool hasUnread =
              state is NotifikasiLoaded && state.unreadCount > 0;
          final bool isMarkingAll =
              state is NotifikasiLoaded && state.isMarkingAll;

          return Scaffold(
            backgroundColor: bgApp,
            body: Column(
              children: [
                // 1. Custom App Bar Solid Blue
                Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 16.h,
                    bottom: 16.h,
                    left: 20.w,
                    right: 20.w,
                  ),
                  color: headerBg,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          if (canPop) ...[
                            GestureDetector(
                              onTap: () => context.pop(),
                              child: Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 24.sp,
                              ),
                            ),
                            SizedBox(width: 16.w),
                          ],
                          Expanded(
                            child: Text(
                              'Notifikasi',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (hasUnread)
                            GestureDetector(
                              onTap: isMarkingAll
                                  ? null
                                  : () => context.read<NotifikasiBloc>().add(
                                const MarkAllNotifikasiReadRequested(),
                              ),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  isMarkingAll
                                      ? 'Memproses...'
                                      : 'Tandai Dibaca',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 14.h),
                      Row(
                        children: [
                          _buildFilterChip(
                            label: 'Semua',
                            isSelected: selectedKategori == null,
                            onTap: () => context.read<NotifikasiBloc>().add(
                              const LoadNotifikasiRequested(),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          _buildFilterChip(
                            label: 'Presensi',
                            isSelected: selectedKategori == 'presensi',
                            onTap: () => context.read<NotifikasiBloc>().add(
                              const LoadNotifikasiRequested(
                                kategori: 'presensi',
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          _buildFilterChip(
                            label: 'Pengajuan',
                            isSelected: selectedKategori == 'pengajuan',
                            onTap: () => context.read<NotifikasiBloc>().add(
                              const LoadNotifikasiRequested(
                                kategori: 'pengajuan',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 2. Konten Utama
                Expanded(
                  child: _buildBody(
                    context: context,
                    state: state,
                    isDark: isDark,
                    sectionTextColor: sectionTextColor,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white
              : Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: isSelected ? const Color(0xFF1E61B6) : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildBody({
    required BuildContext context,
    required NotifikasiState state,
    required bool isDark,
    required Color sectionTextColor,
  }) {
    if (state is NotifikasiLoading || state is NotifikasiInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is NotifikasiError) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.notifications_off_outlined,
                size: 48.sp,
                color: sectionTextColor,
              ),
              SizedBox(height: 12.h),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: sectionTextColor,
                ),
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () => context.read<NotifikasiBloc>().add(
                  LoadNotifikasiRequested(
                    kategori: state.selectedKategori,
                    unreadOnly: state.unreadOnly,
                  ),
                ),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (state is NotifikasiLoaded) {
      if (state.items.isEmpty) {
        return RefreshIndicator(
          onRefresh: () async {
            context.read<NotifikasiBloc>().add(
              LoadNotifikasiRequested(
                kategori: state.selectedKategori,
                unreadOnly: state.unreadOnly,
              ),
            );
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            children: [
              SizedBox(height: 140.h),
              Icon(
                Icons.notifications_none_rounded,
                size: 56.sp,
                color: sectionTextColor,
              ),
              SizedBox(height: 12.h),
              Center(
                child: Text(
                  'Belum ada notifikasi',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: sectionTextColor,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      final todayItems = state.todayItems;
      final earlierItems = state.earlierItems;

      return RefreshIndicator(
        onRefresh: () async {
          context.read<NotifikasiBloc>().add(
            LoadNotifikasiRequested(
              kategori: state.selectedKategori,
              unreadOnly: state.unreadOnly,
            ),
          );
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (todayItems.isNotEmpty) ...[
                Text(
                  'HARI INI',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: sectionTextColor,
                  ),
                ),
                SizedBox(height: 12.h),
                ...todayItems.map((item) {
                  final style = _resolveVisualStyle(item, isDark);
                  return Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: _buildNotificationItem(
                      isDark: isDark,
                      icon: style.icon,
                      iconBgColor: style.iconBgColor,
                      iconColor: style.iconColor,
                      title: item.judul,
                      time: _formatItemTime(item),
                      description: item.pesan,
                      isUnread: item.isUnread,
                      badgeText: style.badgeText,
                      badgeBgColor: style.badgeBgColor,
                      badgeTextColor: style.badgeTextColor,
                      badgeIcon: style.badgeIcon,
                      onTap: item.isUnread
                          ? () => context.read<NotifikasiBloc>().add(
                        MarkNotifikasiReadRequested(item.id),
                      )
                          : null,
                    ),
                  );
                }),
              ],

              if (todayItems.isNotEmpty && earlierItems.isNotEmpty)
                SizedBox(height: 12.h),

              if (earlierItems.isNotEmpty) ...[
                Text(
                  'SEBELUMNYA',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: sectionTextColor,
                  ),
                ),
                SizedBox(height: 12.h),
                ...earlierItems.map((item) {
                  final style = _resolveVisualStyle(item, isDark);
                  return Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: _buildNotificationItem(
                      isDark: isDark,
                      icon: style.icon,
                      iconBgColor: style.iconBgColor,
                      iconColor: style.iconColor,
                      title: item.judul,
                      time: _formatItemTime(item),
                      description: item.pesan,
                      isUnread: item.isUnread,
                      badgeText: style.badgeText,
                      badgeBgColor: style.badgeBgColor,
                      badgeTextColor: style.badgeTextColor,
                      badgeIcon: style.badgeIcon,
                      onTap: item.isUnread
                          ? () => context.read<NotifikasiBloc>().add(
                        MarkNotifikasiReadRequested(item.id),
                      )
                          : null,
                    ),
                  );
                }),
              ],

              if (state.isLoadingMore)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: const Center(child: CircularProgressIndicator()),
                ),

              SizedBox(height: 16.h),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildNotificationItem({
    required bool isDark,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String time,
    required String description,
    bool isUnread = false,
    required String badgeText,
    required Color badgeBgColor,
    required Color badgeTextColor,
    IconData? badgeIcon,
    VoidCallback? onTap,
  }) {
    final Color cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color titleColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color descColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final Color timeColor = isDark
        ? const Color(0xFF64748B)
        : const Color(0xFF94A3B8);
    final Color unreadDotColor = isDark
        ? const Color(0xFF60A5FA)
        : const Color(0xFF2563EB);
    final Color borderColor = isDark
        ? const Color(0xFF333333)
        : Colors.transparent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20.r),
          border: isDark ? Border.all(color: borderColor) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
              blurRadius: 15.r,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: titleColor,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        time,
                        style: TextStyle(fontSize: 12.sp, color: timeColor),
                      ),
                      if (isUnread) ...[
                        SizedBox(width: 6.w),
                        Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: BoxDecoration(
                            color: unreadDotColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ] else ...[
                        SizedBox(width: 14.w),
                      ],
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: descColor,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: badgeBgColor,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (badgeIcon != null) ...[
                          Icon(badgeIcon, color: badgeTextColor, size: 14.sp),
                          SizedBox(width: 6.w),
                        ],
                        Text(
                          badgeText,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: badgeTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationVisualStyle {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String badgeText;
  final Color badgeBgColor;
  final Color badgeTextColor;
  final IconData? badgeIcon;

  const _NotificationVisualStyle({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.badgeText,
    required this.badgeBgColor,
    required this.badgeTextColor,
    this.badgeIcon,
  });
}