import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PresensiPage extends StatefulWidget {
  const PresensiPage({super.key});

  @override
  State<PresensiPage> createState() => _PresensiPageState();
}

class _PresensiPageState extends State<PresensiPage> {
  final bool isDalamRadius = false;

  @override
  Widget build(BuildContext context) {
    const Color headerBlue = Color(0xFF1961B6);
    const Color textPrimary = Color(0xFF1E293B);
    const Color textSecondary = Color(0xFF64748B);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: headerBlue,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 24.w),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Absensi Hari ini',
          style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
      ),
      body: Stack(
        children: [

          Container(
            height: MediaQuery.of(context).size.height * 0.65,
            width: double.infinity,
            color: const Color(0xFFE8EDF2),
            child: Stack(
              children: [

                Positioned(
                  bottom: 120.h,
                  right: 40.w,
                  child: Container(
                    width: 120.w,
                    height: 120.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1961B6).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF1961B6).withValues(alpha: 0.3), width: 1.w),
                    ),
                  ),
                ),

                // Pin Posisi Anda (Kiri Atas)
                Positioned(
                  top: 100.h,
                  left: 60.w,
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B), // Orange
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.white, size: 14.w),
                            SizedBox(width: 4.w),
                            Text('Posisi Anda (250m)', style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        width: 24.w,
                        height: 24.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1961B6).withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Container(
                            width: 12.w,
                            height: 12.w,
                            decoration: const BoxDecoration(color: Color(0xFF1961B6), shape: BoxShape.circle),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tombol Center Location
          Positioned(
            top: 16.h,
            right: 16.w,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'btn_location',
                  backgroundColor: Colors.white,
                  onPressed: () {},
                  child: Icon(Icons.my_location, color: const Color(0xFF1961B6), size: 20.w),
                ),
                SizedBox(height: 8.h),
                FloatingActionButton.small(
                  heroTag: 'btn_layers',
                  backgroundColor: Colors.white,
                  onPressed: () {},
                  child: Icon(Icons.layers_outlined, color: textSecondary, size: 20.w),
                ),
              ],
            ),
          ),

          // BAGIAN BOTTOM SHEET
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.r),
                  topRight: Radius.circular(30.r),
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 20.r, offset: Offset(0, -5.h)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 5.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  isDalamRadius
                      ? _buildDalamRadiusCard()
                      : _buildLuarRadiusCard(),

                  SizedBox(height: 16.h),

                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0).withValues(alpha: 0.7),
                        width: 1.0.w,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10.w),
                                decoration: BoxDecoration(
                                  color: headerBlue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Icon(Icons.calendar_today_outlined, color: headerBlue, size: 20.w),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text('Tanggal Presensi', maxLines: 1, style: TextStyle(fontSize: 12.sp, color: textSecondary))),
                                    SizedBox(height: 2.h),
                                    FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text('Senin, 28 Sep 2026', maxLines: 1, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: textPrimary))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(height: 40.h, width: 1.w, color: const Color(0xFFE2E8F0)),
                        SizedBox(width: 12.w),
                        Expanded(
                          flex: 4,
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10.w),
                                decoration: BoxDecoration(color: headerBlue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10.r)),
                                child: Icon(Icons.access_time_outlined, color: headerBlue, size: 20.w),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text('Waktu Presensi', maxLines: 1, style: TextStyle(fontSize: 12.sp, color: textSecondary))),
                                    SizedBox(height: 2.h),
                                    FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text('07:45 WIB', maxLines: 1, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: textPrimary))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Lokasi Kantor
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(color: headerBlue.withValues(alpha: 0.1), shape: BoxShape.circle),
                        child: Icon(Icons.location_on_outlined, color: headerBlue, size: 24.w),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('LOKASI KANTOR', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: textSecondary)),
                            SizedBox(height: 4.h),
                            Text('Cyber Olympus Software House', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: textPrimary)),
                            SizedBox(height: 4.h),
                            Text('Jl. Padma No. 22, Sleman, D.I. Yogyakarta', style: TextStyle(fontSize: 12.sp, color: textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 32.h),

                  SizedBox(
                    width: double.infinity,
                    height: 55.h,
                    child: isDalamRadius
                        ? ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: headerBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                        elevation: 0,
                      ),
                      child: Text('Masuk Kerja', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                    )
                        : ElevatedButton.icon(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE2E8F0),
                        disabledBackgroundColor: const Color(0xFFE2E8F0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                        elevation: 0,
                      ),
                      icon: Icon(Icons.lock_outline, color: const Color(0xFF94A3B8), size: 20.w),
                      label: Text(
                        'Masuk Kerja',
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF94A3B8)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER UNTUK TAMPILAN DI LUAR RADIUS ---
  Widget _buildLuarRadiusCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFFDE68A), width: 1.w),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Icon Peringatan
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: const BoxDecoration(color: Color(0xFFFEF3C7), shape: BoxShape.circle),
                child: Icon(Icons.warning_amber_rounded, color: const Color(0xFFD97706), size: 18.w),
              ),
              SizedBox(width: 12.w),

              // Teks Judul & Deskripsi
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Di Luar Radius', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp, color: const Color(0xFF92400E))),
                    SizedBox(height: 2.h),
                    Text(
                        'Lokasi Anda berada di luar area presensi',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11.sp, color: const Color(0xFF92400E).withValues(alpha: 0.8))
                    ),
                  ],
                ),
              ),

              // Garis Vertikal Pemisah
              SizedBox(width: 8.w),
              Container(height: 35.h, width: 1.w, color: const Color(0xFFFDE68A)),
              SizedBox(width: 12.w),

              // Teks Jarak (250m)
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('250 m', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: const Color(0xFF92400E))),
                  SizedBox(height: 2.h),
                  Text('Jarak ke kantor', style: TextStyle(fontSize: 10.sp, color: const Color(0xFF92400E).withValues(alpha: 0.7))),
                ],
              )
            ],
          ),

          // Garis Horizontal Pemisah
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Divider(color: const Color(0xFFFDE68A), height: 1.h, thickness: 1.h),
          ),

          // Pesan Bawah & Badge
          Row(
            children: [
              Icon(Icons.info_outline, color: const Color(0xFFD97706), size: 14.w),
              SizedBox(width: 8.w),
              Expanded(
                  child: Text(
                      'Silahkan mendekat ke area kantor ...',
                      style: TextStyle(fontSize: 11.sp, color: const Color(0xFF92400E).withValues(alpha: 0.8))
                  )
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(4.r)
                ),
                child: Text(
                    'Maks. 15 m',
                    style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: const Color(0xFFD97706))
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  // --- WIDGET HELPER UNTUK TAMPILAN DALAM RADIUS ---
  Widget _buildDalamRadiusCard() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFBBF7D0), width: 1.0.w),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
            child: Icon(Icons.check, color: Colors.white, size: 16.w),
          ),
          SizedBox(width: 12.w),
          Text('Dalam Radius', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: const Color(0xFF1E293B))),
          const Spacer(),
          Container(height: 40.h, width: 1.w, color: const Color(0xFFBBF7D0)),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('15 m', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp, color: const Color(0xFF1E293B))),
              SizedBox(height: 2.h),
              Text('Jarak ke kantor', style: TextStyle(fontSize: 12.sp, color: const Color(0xFF64748B))),
            ],
          )
        ],
      ),
    );
  }
}