import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:kantin_app/features/auth/data/datasources/auth_datasource.dart';
import 'package:kantin_app/features/auth/data/repositories/auth_repository.dart';
import 'package:kantin_app/features/auth/domain/usecases/google_signin_usecase.dart';

import '../../features/auth/domain/repositories/i_auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/watch_auth_state_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../network/connectivity_service.dart';

final sl = GetIt.instance;

/// Initialize all dependencies
Future<void> initializeDependencies() async {
  // ========== External Dependencies ==========

  // Firebase
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn());

  // Connectivity
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton(() => InternetConnectionChecker());

  // ========== Core ==========

  // Connectivity Service
  sl.registerLazySingleton<ConnectivityService>(
    () => ConnectivityServiceImpl(connectivity: sl(), connectionChecker: sl()),
  );

  // ========== Features - Auth ==========

  // Data Source
  sl.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasourceImpl(
      firebaseAuth: sl(),
      firestore: sl(),
      googleSignIn: sl(),
    ),
  );

  // Repository
  sl.registerLazySingleton<IAuthRepository>(
    () => AuthRepository(datasource: sl(), firebaseAuth: sl(), firestore: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => WatchAuthStateUseCase(sl()));
  sl.registerLazySingleton(() => GoogleSignInUseCase(sl()));

  // BLoC
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      getCurrentUserUseCase: sl(),
      watchAuthStateUseCase: sl(),
      googleSignInUseCase: sl(),
    ),
  );

  // ========== Features - More to be added ==========
  // We'll add more feature dependencies as we build them
}
