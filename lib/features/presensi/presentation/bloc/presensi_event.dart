import 'package:equatable/equatable.dart';

abstract class PresensiEvent extends Equatable {
  const PresensiEvent();

  @override
  List<Object?> get props => [];
}

class LoadPresensiData extends PresensiEvent {}

class RefreshLokasi extends PresensiEvent {}

class SubmitPresensi extends PresensiEvent {
  final String uuidPresensi;
  final String jenisPresensi;

  const SubmitPresensi({
    required this.uuidPresensi,
    required this.jenisPresensi,
  });

  @override
  List<Object?> get props => [uuidPresensi, jenisPresensi];
}
