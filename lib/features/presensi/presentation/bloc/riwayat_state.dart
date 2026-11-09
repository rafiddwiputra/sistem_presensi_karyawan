import 'package:equatable/equatable.dart';

import '../../data/models/riwayat_model.dart';

abstract class RiwayatState extends Equatable {
  const RiwayatState();

  @override
  List<Object?> get props => [];
}

class RiwayatInitial extends RiwayatState {}

class RiwayatLoading extends RiwayatState {
  final DateTime currentDate;
  const RiwayatLoading(this.currentDate);

  @override
  List<Object> get props => [currentDate];
}

class RiwayatLoaded extends RiwayatState {
  final DateTime currentDate;
  final RiwayatSummary summary;
  final List<RiwayatItem> riwayatList;

  const RiwayatLoaded({
    required this.currentDate,
    required this.summary,
    required this.riwayatList,
  });

  @override
  List<Object> get props => [currentDate, summary, riwayatList];
}

class RiwayatError extends RiwayatState {
  final String message;
  final DateTime currentDate;

  const RiwayatError(this.message, this.currentDate);

  @override
  List<Object> get props => [message, currentDate];
}
