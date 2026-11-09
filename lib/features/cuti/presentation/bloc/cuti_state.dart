import 'package:equatable/equatable.dart';

enum CutiStatus { initial, submitting, success, error }

class CutiState extends Equatable {
  final CutiStatus status;
  final String? errorMessage;
  final String? successMessage;

  const CutiState({
    this.status = CutiStatus.initial,
    this.errorMessage,
    this.successMessage,
  });

  CutiState copyWith({
    CutiStatus? status,
    String? errorMessage,
    String? successMessage,
  }) {
    return CutiState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, successMessage];
}