import 'package:equatable/equatable.dart';
import '../../data/models/lembur_model.dart';

enum LemburStatus { initial, loading, loaded, submitting, success, error }

class LemburState extends Equatable {
  final LemburStatus status;
  final List<LemburModel> riwayatLembur;
  final String? errorMessage;
  final String? successMessage;

  const LemburState({
    this.status = LemburStatus.initial,
    this.riwayatLembur = const [],
    this.errorMessage,
    this.successMessage,
  });

  LemburState copyWith({
    LemburStatus? status,
    List<LemburModel>? riwayatLembur,
    String? errorMessage,
    String? successMessage,
  }) {
    return LemburState(
      status: status ?? this.status,
      riwayatLembur: riwayatLembur ?? this.riwayatLembur,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [status, riwayatLembur, errorMessage, successMessage];
}