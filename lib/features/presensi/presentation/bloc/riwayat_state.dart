import 'package:equatable/equatable.dart';

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
  final Map<String, dynamic> summary;
  final List<dynamic> riwayatList;

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
  final DateTime currentDate; // Tetap simpan tanggal agar UI tidak hilang/rusak

  const RiwayatError(this.message, this.currentDate);

  @override
  List<Object> get props => [message, currentDate];
}