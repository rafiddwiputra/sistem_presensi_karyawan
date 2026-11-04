import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sistem_presensi_karyawan/core/di/injection.dart';
import 'package:sistem_presensi_karyawan/core/services/secure_storage_service.dart';

class AuthenticatedProfileImage extends StatelessWidget {
  final String? imagePath;
  final double size;
  final bool isDark;
  final double borderWidth;

  const AuthenticatedProfileImage({
    super.key,
    required this.imagePath,
    required this.size,
    required this.isDark,
    this.borderWidth = 3.0,
  });

  Widget _buildPlaceholder() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFFBBF24), width: borderWidth.w),
        color: isDark ? const Color(0xFF333333) : const Color(0xFFE2E8F0),
      ),
      child: Icon(Icons.person, color: isDark ? const Color(0xFF64748B) : Colors.white, size: size * 0.5),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (imagePath == null || imagePath!.isEmpty) return _buildPlaceholder();

    return FutureBuilder<String?>(
      future: sl<SecureStorageService>().getToken(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return _buildPlaceholder();

        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFFBBF24), width: borderWidth.w),
          ),
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: imagePath!,
              httpHeaders: {
                'Authorization': 'Bearer ${snapshot.data}',
                'Accept': 'application/json',
              },
              width: size,
              height: size,
              fit: BoxFit.cover,
              placeholder: (context, url) => Center(
                child: SizedBox(
                  width: size * 0.3,
                  height: size * 0.3,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (context, url, error) {
                if (kDebugMode) debugPrint('Gagal memuat foto profil dari $url: $error');
                return _buildPlaceholder();
              },
              memCacheWidth: (size * 2).toInt(),
            ),
          ),
        );
      },
    );
  }
}