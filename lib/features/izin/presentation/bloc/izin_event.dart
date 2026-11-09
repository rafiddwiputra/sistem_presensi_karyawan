import 'dart:io';

import 'package:equatable/equatable.dart';

abstract class IzinEvent extends Equatable {
  const IzinEvent();

  @override
  List<Object?> get props => [];
}

class SubmitIzin extends IzinEvent {
  final String uuidPengajuan;
  final String jenisIzin;
  final String tanggalMulai;
  final String tanggalSelesai;
  final String keterangan;
  final File? lampiran;

  const SubmitIzin({
    required this.uuidPengajuan,
    required this.jenisIzin,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.keterangan,
    this.lampiran,
  });

  @override
  List<Object?> get props => [
    uuidPengajuan,
    jenisIzin,
    tanggalMulai,
    tanggalSelesai,
    keterangan,
    lampiran,
  ];
}

class FetchIzinHistory extends IzinEvent {
  const FetchIzinHistory();
}
