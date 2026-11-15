import 'package:flutter/material.dart';

import 'riwayat_presensi_page.dart';

/// Wrapper kompatibilitas sementara agar rute atau navigasi yang masih
/// mengarah ke [RekapPresensiPage] otomatis menampilkan [RiwayatPresensiPage]
/// terpadu tanpa duplikasi [BlocProvider] maupun pemanggilan API ganda.
///
/// Hapus file ini setelah seluruh referensi rute di router dan halaman
/// pemanggil diarahkan langsung ke [RiwayatPresensiPage].
class RekapPresensiPage extends StatelessWidget {
  const RekapPresensiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const RiwayatPresensiPage();
  }
}