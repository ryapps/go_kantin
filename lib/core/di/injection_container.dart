import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:kantin_app/features/auth/data/datasources/auth_datasource.dart';
import 'package:kantin_app/features/auth/data/repositories/auth_repository.dart';
import 'package:kantin_app/features/auth/domain/usecases/google_signin_usecase.dart';
import 'package:kantin_app/features/cart/data/services/cart_service.dart';
import 'package:kantin_app/features/checkout/presentation/bloc/checkout_bloc.dart';
import 'package:kantin_app/features/diskon/data/datasources/diskon_datasource.dart';
import 'package:kantin_app/features/diskon/data/repositories/diskon_repository.dart';
import 'package:kantin_app/features/diskon/domain/repositories/i_diskon_repository.dart';
import 'package:kantin_app/features/diskon/domain/usecases/get_active_discounts_for_menu_usecase.dart';
import 'package:kantin_app/features/diskon/domain/usecases/get_diskon_for_menu_usecase.dart';
import 'package:kantin_app/features/home/presentation/bloc/siswa_home_bloc.dart';
import 'package:kantin_app/features/menu/data/datasources/menu_datasource.dart';
import 'package:kantin_app/features/menu/data/repositories/menu_repository.dart';
import 'package:kantin_app/features/menu/domain/repositories/i_menu_repository.dart';
import 'package:kantin_app/features/menu/domain/usecases/get_menu_by_stan_id_usecase.dart';
import 'package:kantin_app/features/stan/data/datasources/stan_datasource.dart';
import 'package:kantin_app/features/stan/data/repositories/stan_repository.dart';
import 'package:kantin_app/features/stan/domain/repositories/i_stan_repository.dart';
import 'package:kantin_app/features/stan/domain/usecases/get_all_stans_usecase.dart';
import 'package:kantin_app/features/stan/presentation/bloc/canteen_detail_bloc.dart';
import 'package:kantin_app/features/transaksi/data/datasources/transaksi_datasource.dart';
import 'package:kantin_app/features/transaksi/data/repositories/transaksi_repository.dart';
import 'package:kantin_app/features/transaksi/domain/repositories/i_transaksi_repository.dart';
import 'package:kantin_app/features/transaksi/presentation/bloc/order_tracking_bloc.dart';
import 'package:kantin_app/features/transaksi/presentation/bloc/transaksi_history_bloc.dart';

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
  sl.registerLazySingleton(() => CartService());
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

  // ========== Features - Diskon ==========

  // Data Source
  sl.registerLazySingleton<DiskonRemoteDatasource>(
    () => DiskonRemoteDatasourceImpl(firestore: sl()),
  );

  // Repository
  sl.registerLazySingleton<IDiskonRepository>(
    () => DiskonRepository(datasource: sl(), firestore: sl()),
  );

  // ========== Features - Stan ==========

  sl.registerLazySingleton<StanRemoteDatasource>(
    () => StanRemoteDatasourceImpl(firestore: sl()),
  );

  sl.registerLazySingleton<IStanRepository>(
    () => StanRepository(datasource: sl(), firestore: sl()),
  );

  // ========== Features - Menu ==========

  sl.registerLazySingleton<MenuRemoteDatasource>(
    () => MenuRemoteDatasourceImpl(firestore: sl()),
  );

  sl.registerLazySingleton<IMenuRepository>(
    () => MenuRepository(datasource: sl(), firestore: sl()),
  );

  // ========== Features - Transaksi ==========

  // Data Source
  sl.registerLazySingleton<TransaksiRemoteDatasource>(
    () => TransaksiRemoteDatasourceImpl(firestore: sl()),
  );

  // Repository
  sl.registerLazySingleton<ITransaksiRepository>(
    () => TransaksiRepository(datasource: sl(), firestore: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => WatchAuthStateUseCase(sl()));
  sl.registerLazySingleton(() => GoogleSignInUseCase(sl()));
  sl.registerLazySingleton(() => GetAllStansUseCase(sl()));
  sl.registerLazySingleton(() => GetMenuByStanIdUseCase(sl()));
  sl.registerLazySingleton(() => GetActiveDiscountsForMenuUseCase(sl()));
  sl.registerLazySingleton(() => GetDiskonForMenuUseCase(sl()));

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

  sl.registerFactory(() => SiswaHomeBloc(getAllStansUseCase: sl()));
  sl.registerFactory(
    () => CheckoutBloc(
      cartService: sl(),
      getDiskonForMenuUseCase: sl(),
      transaksiRepository: sl(),
      firebaseAuth: sl(),
    ),
  );
  sl.registerFactory(
    () => CanteenDetailBloc(cartService: sl(), getMenuByStanIdUseCase: sl()),
  );
  sl.registerFactory(() => OrderTrackingBloc(transaksiRepository: sl()));
  sl.registerFactory(
    () => TransaksiHistoryBloc(transaksiRepository: sl(), firebaseAuth: sl()),
  );

  // ========== Features - More to be added ==========
  // We'll add more feature dependencies as we build them
}
