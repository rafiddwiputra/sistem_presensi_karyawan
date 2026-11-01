import 'package:get_it/get_it.dart';
import '../network/api_client.dart';
import '../services/secure_storage_service.dart';
import '../../features/auth/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> setupInjection() async {
  // Services
  sl.registerLazySingleton<SecureStorageService>(
        () => SecureStorageService(),
  );

  // Network
  sl.registerLazySingleton<ApiClient>(
        () => ApiClient(sl<SecureStorageService>()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepository(sl<ApiClient>(), sl<SecureStorageService>()),
  );

  // Bloc
  sl.registerFactory<AuthBloc>(
        () => AuthBloc(authRepository: sl<AuthRepository>()),
  );
}