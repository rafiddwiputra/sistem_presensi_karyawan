import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_presensi_karyawan/core/errors/app_exception.dart';
import 'package:sistem_presensi_karyawan/features/auth/repositories/auth_repository.dart';

import 'auth_event.dart';
import 'auth_state.dart';

// 1. Import ProfilBloc dan ProfilEvent agar AuthBloc bisa memanggilnya
import 'package:sistem_presensi_karyawan/features/profil/presentation/bloc/profil_bloc.dart';
import 'package:sistem_presensi_karyawan/features/profil/presentation/bloc/profil_event.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  // 2. Tambahkan ProfilBloc di constructor melalui Dependency Injection (GetIt / sl)
  final ProfilBloc profilBloc;

  AuthBloc({required this.authRepository, required this.profilBloc})
    : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.login(event.email, event.password);

      // 3. Picu ProfilBloc untuk langsung mendownload data profil karyawan
      profilBloc.add(LoadProfilRequested());

      emit(AuthSuccess(user));
    } catch (e) {
      final errorMessage = e is AppException
          ? e.message
          : e.toString().replaceAll('Exception: ', '');
      emit(AuthError(errorMessage));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await authRepository.logout();
    } catch (e) {
      // Abaikan error API saat logout, paksa hapus sesi lokal
    } finally {
      emit(AuthUnauthenticated());
    }
  }
}
