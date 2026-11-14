import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../data/models/reimbursement_model.dart';


enum ReimbursementStatus { initial, loading, success, submitSuccess, error, submitFailure }

class ReimbursementState extends Equatable {
  final ReimbursementStatus status;
  final List<ReimbursementModel>? riwayat;
  final String? successMessage;
  final String? errorMessage;

  // Data Form & Berhasil
  final String? tanggal;
  final String? keperluan;
  final String? nominal;
  final File? lampiran;

  const ReimbursementState({
    this.status = ReimbursementStatus.initial,
    this.riwayat,
    this.successMessage,
    this.errorMessage,
    this.tanggal,
    this.keperluan,
    this.nominal,
    this.lampiran,
  });

  ReimbursementState copyWith({
    ReimbursementStatus? status,
    List<ReimbursementModel>? riwayat,
    String? successMessage,
    String? errorMessage,
    String? tanggal,
    String? keperluan,
    String? nominal,
    File? lampiran,
  }) {
    return ReimbursementState(
      status: status ?? this.status,
      riwayat: riwayat ?? this.riwayat,
      successMessage: successMessage ?? this.successMessage,
      errorMessage: errorMessage ?? this.errorMessage,
      tanggal: tanggal ?? this.tanggal,
      keperluan: keperluan ?? this.keperluan,
      nominal: nominal ?? this.nominal,
      lampiran: lampiran ?? this.lampiran,
    );
  }

  @override
  List<Object?> get props => [
    status,
    riwayat,
    successMessage,
    errorMessage,
    tanggal,
    keperluan,
    nominal,
    lampiran,
  ];
}