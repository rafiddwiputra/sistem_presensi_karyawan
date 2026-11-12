import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

sealed class LemburEvent extends Equatable {
  const LemburEvent();

  @override
  List<Object?> get props => [];
}

class FetchRiwayatLembur extends LemburEvent {}

class SubmitLembur extends LemburEvent {
  final String uuidPengajuan;
  final DateTime tanggalLembur;
  final TimeOfDay jamMulai;
  final TimeOfDay jamSelesai;
  final String alasanLembur;

  const SubmitLembur({
    required this.uuidPengajuan,
    required this.tanggalLembur,
    required this.jamMulai,
    required this.jamSelesai,
    required this.alasanLembur,
  });

  @override
  List<Object?> get props => [
    uuidPengajuan,
    tanggalLembur,
    jamMulai,
    jamSelesai,
    alasanLembur,
  ];
}