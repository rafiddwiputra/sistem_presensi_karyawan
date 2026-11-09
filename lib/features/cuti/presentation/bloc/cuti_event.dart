import 'package:equatable/equatable.dart';

sealed class CutiEvent extends Equatable {
  const CutiEvent();

  @override
  List<Object?> get props => [];
}

class SubmitCuti extends CutiEvent {
  final String uuidPengajuan;
  final String jenisCuti;
  final String tanggalMulai;
  final String tanggalSelesai;
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