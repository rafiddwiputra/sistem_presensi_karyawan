import 'package:get_it/get_it.dart';
import '../network/api_client.dart';
import '../services/secure_storage_service.dart';
import '../../features/auth/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/profil/repositories/profil_repository.dart';
import '../../features/profil/presentation/bloc/profil_bloc.dart';

final sl = GetIt.instance;

Future<void> setupInjection() async {
  // Service
  sl.registerLazySingleton<SecureStorageService>(
        () => SecureStorageService(),
  );

  // Network
  sl.registerLazySingleton<ApiClient>(
        () => ApiClient(sl<SecureStorageService>()),
  );

  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepository(sl<ApiClient>(), sl<SecureStorageService>()),
  );

  sl.registerLazySingleton<ProfilRepository>(
        () => ProfilRepository(sl<ApiClient>(), sl<SecureStorageService>()),
  );

  // Di dalam main.dart atau injection.dart
  sl.registerLazySingleton(() => AuthBloc(
    authRepository: sl(),
    profilBloc: sl(), // Suntikkan ProfilBloc ke dalam AuthBloc
  ));

  sl.registerLazySingleton<ProfilBloc>(
        () => ProfilBloc(repository: sl<ProfilRepository>()),
  );
}