import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_presensi_karyawan/core/errors/app_exception.dart';

import '../../repositories/profil_repository.dart';
import 'profil_event.dart';
import 'profil_state.dart';

class ProfilBloc extends Bloc<ProfilEvent, ProfilState> {
  final ProfilRepository repository;

  ProfilBloc({required this.repository}) : super(ProfilInitial()) {
    on<LoadProfilRequested>((event, emit) async {
      final localUser = await repository.getProfilLocal();
      if (localUser != null) {
        emit(ProfilLoaded(localUser));
      } else {
        emit(ProfilLoading());
      }

      try {
        final remoteUser = await repository.getProfil();
        emit(ProfilLoaded(remoteUser));
      } on AppException catch (e) {
        final isAccessRevoked = e is UnauthorizedException ||
            (e is ServerException && e.statusCode == 403);

        if (isAccessRevoked) {
          await repository.clearProfilLocal();
          emit(ProfilError(e.message));
          return;
        }

        if (localUser == null) {
          emit(ProfilError(e.message));
        }
      } catch (_) {
        if (localUser == null) {
          emit(const ProfilError('Terjadi kesalahan tidak terduga.'));
        }
      }
    });

    on<UpdateProfilRequested>((event, emit) async {
      emit(ProfilLoading());
      try {
        await repository.updateProfil(
          nama: event.nama,
          email: event.email,
          noHp: event.noHp,
          alamat: event.alamat,
          image: event.image,
        );

        emit(ProfilUpdateSuccess());
        add(LoadProfilRequested());
      } on AppException catch (e) {
        emit(ProfilError(e.message));
      } catch (_) {
        emit(const ProfilError('Gagal memperbarui profil.'));
      }
    });

    on<UbahPasswordRequested>((event, emit) async {
      emit(ProfilLoading());
      try {
        await repository.ubahPassword(
          currentPassword: event.currentPassword,
          newPassword: event.newPassword,
          newPasswordConfirmation: event.newPasswordConfirmation,
        );

        emit(const UbahPasswordSuccess(message: 'Password berhasil dirubah!'));
        add(LoadProfilRequested());
      } on AppException catch (e) {
        emit(ProfilError(e.message));
      } catch (e) {
        emit(ProfilError('Terjadi kesalahan tidak terduga: $e'));
      }
    });
  }
}