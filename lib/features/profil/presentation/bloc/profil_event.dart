import 'dart:io';
import 'package:equatable/equatable.dart';


abstract class ProfilEvent extends Equatable {
  const ProfilEvent();
  @override
  List<Object?> get props => [];
}

class LoadProfilRequested extends ProfilEvent {}

class UpdateProfilRequested extends ProfilEvent {
  final String nama;
  final String email;
  final String noHp;
  final String alamat;
  final File? image;

  const UpdateProfilRequested({
    required this.nama,
    required this.email,
    required this.noHp,
    required this.alamat,
    this.image,
  });

  @override
  List<Object?> get props => [nama, noHp, alamat, image];
}

class UbahPasswordRequested extends ProfilEvent {
  final String currentPassword;
  final String newPassword;
  final String newPasswordConfirmation;

  const UbahPasswordRequested({
    required this.currentPassword,
    required this.newPassword,
    required this.newPasswordConfirmation,
  });

  @override
  List<Object> get props => [currentPassword, newPassword, newPasswordConfirmation];
}