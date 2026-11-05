import 'package:equatable/equatable.dart';

abstract class RiwayatEvent extends Equatable {
  const RiwayatEvent();

  @override
  List<Object> get props => [];
}

class LoadRiwayatRequested extends RiwayatEvent {
  final DateTime date;

  const LoadRiwayatRequested(this.date);

  @override
  List<Object> get props => [date];
}