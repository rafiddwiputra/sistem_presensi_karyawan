import 'package:equatable/equatable.dart';

import '../../data/models/cuti_model.dart';

enum CutiStatus { initial, loading, loaded, submitting, success, error }

class CutiState extends Equatable {
  final CutiStatus status;
  final String? errorMessage;
  final String? successMessage;

  // 2. Tambahkan wadah penampung data dari Backend
  final List<CutiModel> riwayatCuti;

  const CutiState({
    this.status = CutiStatus.initial,
    this.errorMessage,
    this.successMessage,
    this.riwayatCuti = const [],
  });

  CutiState copyWith({
    CutiStatus? status,
    String? errorMessage,
    String? successMessage,
    List<CutiModel>? riwayatCuti,
  }) {
    return CutiState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      successMessage: successMessage,
      riwayatCuti: riwayatCuti ?? this.riwayatCuti,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    successMessage,
    riwayatCuti,
  ];
}
