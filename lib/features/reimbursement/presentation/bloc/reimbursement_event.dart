import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class ReimbursementEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadRiwayatReimbursement extends ReimbursementEvent {}

class SubmitReimbursement extends ReimbursementEvent {
  final String tanggal;
  final String keperluan;
  final String nominal;
  final File lampiran;

  SubmitReimbursement({
    required this.tanggal,
    required this.keperluan,
    required this.nominal,
    required this.lampiran,
  });

  @override
  List<Object?> get props => [tanggal, keperluan, nominal, lampiran];
}