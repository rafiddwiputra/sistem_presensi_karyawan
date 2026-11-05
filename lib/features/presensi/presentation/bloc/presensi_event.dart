import 'package:equatable/equatable.dart';

abstract class PresensiEvent extends Equatable {
  const PresensiEvent();

  @override
  List<Object?> get props => [];
}

// Event 1: Mengambil data jadwal dan kantor saat halaman pertama dibuka
class LoadPresensiData extends PresensiEvent {}

// Event 2: Meminta izin GPS, mencari koordinat, dan mengecek radius ke backend
class RefreshLokasi extends PresensiEvent {}

// Event 3: Eksekusi tombol "Masuk Kerja" atau "Pulang Kerja"
class SubmitPresensi extends PresensiEvent {
  final String uuidPresensi;

  const SubmitPresensi({required this.uuidPresensi});

  @override
  List<Object?> get props => [uuidPresensi];
}