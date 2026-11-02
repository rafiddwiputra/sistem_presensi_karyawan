import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_presensi_karyawan/core/errors/app_exception.dart';
import '../../repositories/profil_repository.dart';
import 'profil_event.dart';
import 'profil_state.dart';

class ProfilBloc extends Bloc<ProfilEvent, ProfilState> {
  final ProfilRepository repository;

  ProfilBloc({required this.repository}) : super(ProfilInitial()) {
    on<LoadProfilRequested>((event, emit) async {
      // 1. Cek dulu apakah ada data di Cache Lokal HP
      final localUser = await repository.getProfilLocal();
      if (localUser != null) {
        // Tampilkan data lokal secara INSTAN (0 detik delay)
        emit(ProfilLoaded(localUser));
      } else {
        // Jika benar-benar pengguna baru / belum ada cache, tampilkan loading
        emit(ProfilLoading());
      }

      // 2. Tetap panggil server Laravel di latar belakang (Background Sync)
      try {
        final remoteUser = await repository.getProfil();
        // Berikan data paling segar dari server ke UI
        emit(ProfilLoaded(remoteUser));
      } on AppException catch (e) {
        // Jika server gagal dijangkau tetapi data lokal sudah tampil, jangan timpa dengan error screen
        if (localUser == null) {
          emit(ProfilError(e.message));
        }
      } catch (e) {
        if (localUser == null) {
          emit(ProfilError('Terjadi kesalahan tidak terduga.'));
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
        // Ambil data terbaru untuk menyegarkan BLoC setelah update
        add(LoadProfilRequested());
      } on AppException catch (e) {
        emit(ProfilError(e.message));
      } catch (e) {
        emit(ProfilError('Gagal memperbarui profil.'));
      }
    });
  }
}