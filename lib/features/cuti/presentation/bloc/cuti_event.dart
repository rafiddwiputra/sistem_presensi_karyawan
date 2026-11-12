import 'package:equatable/equatable.dart';

sealed class CutiEvent extends Equatable {
  const CutiEvent();

  @override
  List<Object?> get props => [];
}

class SubmitCuti extends CutiEvent {
  final String uuidPengajuan;
  final String jenisCuti;

  // PASTIKAN DUA BARIS INI MENGGUNAKAN DATETIME
  final DateTime tanggalMulai;
  final DateTime tanggalSelesai;

  final String keterangan;

  const SubmitCuti({
    required this.uuidPengajuan,
    required this.jenisCuti,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.keterangan,
  });

  @override
  List<Object?> get props => [
    uuidPengajuan,
    jenisCuti,
    tanggalMulai,
    tanggalSelesai,
    keterangan,
  ];
}

class FetchRiwayatCuti extends CutiEvent {
  const FetchRiwayatCuti();
}