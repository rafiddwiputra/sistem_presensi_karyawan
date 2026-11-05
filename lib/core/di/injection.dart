import 'package:get_it/get_it.dart';
import '../network/api_client.dart';
import '../services/secure_storage_service.dart';
import '../../features/auth/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/profil/repositories/profil_repository.dart';
import '../../features/profil/presentation/bloc/profil_bloc.dart';
import '../../features/presensi/repositories/riwayat_repository.dart';
import '../../features/presensi/presentation/bloc/riwayat_bloc.dart';

final sl = GetIt.instance;

Future<void> setupInjection() async {
  sl.registerLazySingleton<SecureStorageService>(
        () => SecureStorageService(),
  );

  sl.registerLazySingleton<ApiClient>(
        () => ApiClient(sl<SecureStorageService>()),
  );

  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepository(sl<ApiClient>(), sl<SecureStorageService>()),
  );

  sl.registerLazySingleton<ProfilRepository>(
        () => ProfilRepository(sl<ApiClient>(), sl<SecureStorageService>()),
  );

  sl.registerLazySingleton(() => AuthBloc(
    authRepository: sl(),
    profilBloc: sl(),
  ));

  sl.registerLazySingleton<ProfilBloc>(
        () => ProfilBloc(repository: sl<ProfilRepository>()),
  );

  // --- Riwayat Presensi ---
  sl.registerLazySingleton<RiwayatRepository>(
        () => RiwayatRepository(sl<ApiClient>()),
  );

  // registerFactory: setiap buka halaman Riwayat, buat instance BARU.
  // Beda dengan AuthBloc/ProfilBloc yang singleton (dipakai di seluruh app),
  // RiwayatBloc cukup hidup selama halaman ini dibuka (sesuai BlocProvider(create:...)
  // di RiwayatPresensiPage, yang memang benar untuk Bloc berumur-pendek).
  sl.registerFactory<RiwayatBloc>(
        () => RiwayatBloc(repository: sl<RiwayatRepository>()),
  );
}