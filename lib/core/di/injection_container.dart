import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:kantin_app/core/bloc/get_user_stan_bloc.dart';
import 'package:kantin_app/core/services/cloudinary_service.dart';
import 'package:kantin_app/core/services/stan_service.dart';
import 'package:kantin_app/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:kantin_app/features/admin/data/datasources/dashboard_remote_datasource.dart';
import 'package:kantin_app/features/admin/data/repositories/admin_repository.dart';
import 'package:kantin_app/features/admin/data/repositories/dashboard_repository.dart';
import 'package:kantin_app/features/admin/domain/repositories/i_admin_repository.dart';
import 'package:kantin_app/features/admin/domain/repositories/i_dashboard_repository.dart';
import 'package:kantin_app/features/admin/domain/usecases/get_all_customers.dart';
import 'package:kantin_app/features/admin/domain/usecases/get_dashboard_summary.dart';
import 'package:kantin_app/features/admin/presentation/bloc/customer_management_bloc.dart';
import 'package:kantin_app/features/admin/presentation/bloc/dashboard_bloc.dart';
import 'package:kantin_app/features/admin/presentation/bloc/menu_management_bloc.dart';
import 'package:kantin_app/features/admin/presentation/bloc/order_management_bloc.dart';
import 'package:kantin_app/features/admin/presentation/bloc/order_report_bloc.dart';
import 'package:kantin_app/features/admin/presentation/bloc/stan_profile_bloc.dart';
import 'package:kantin_app/features/auth/data/datasources/auth_datasource.dart';
import 'package:kantin_app/features/auth/data/repositories/auth_repository.dart';
import 'package:kantin_app/features/auth/domain/usecases/google_signin_usecase.dart';
import 'package:kantin_app/features/cart/data/services/cart_service.dart';
import 'package:kantin_app/features/category/data/datasources/category_datasource.dart';
import 'package:kantin_app/features/category/data/repositories/category_repository.dart';
import 'package:kantin_app/features/category/domain/repositories/i_category_repository.dart';
import 'package:kantin_app/features/category/domain/usecases/create_category_usecase.dart';
import 'package:kantin_app/features/category/domain/usecases/get_all_categories_usecase.dart';
import 'package:kantin_app/features/category/domain/usecases/update_category_usecase.dart';
import 'package:kantin_app/features/category/presentation/bloc/category_management_bloc.dart';
import 'package:kantin_app/features/checkout/presentation/bloc/checkout_bloc.dart';
import 'package:kantin_app/features/diskon/data/datasources/diskon_datasource.dart';
import 'package:kantin_app/features/diskon/data/repositories/diskon_repository.dart';
import 'package:kantin_app/features/diskon/domain/repositories/i_diskon_repository_new.dart';
import 'package:kantin_app/features/diskon/domain/usecases/create_diskon_usecase.dart';
import 'package:kantin_app/features/diskon/domain/usecases/delete_diskon_usecase.dart';
import 'package:kantin_app/features/diskon/domain/usecases/get_active_discounts_for_menu_usecase.dart';
import 'package:kantin_app/features/diskon/domain/usecases/get_diskon_for_menu_usecase.dart';
import 'package:kantin_app/features/diskon/domain/usecases/get_diskons_by_stan_usecase.dart';
import 'package:kantin_app/features/diskon/domain/usecases/update_diskon_usecase.dart';
import 'package:kantin_app/features/diskon/presentation/bloc/diskon_management_bloc.dart';
import 'package:kantin_app/features/favorite/data/services/favorite_service.dart';
import 'package:kantin_app/features/favorite/presentation/bloc/favorite_bloc.dart';
import 'package:kantin_app/features/home/presentation/bloc/siswa_home_bloc.dart';
import 'package:kantin_app/features/menu/data/datasources/menu_datasource.dart';
import 'package:kantin_app/features/menu/data/repositories/menu_repository.dart';
import 'package:kantin_app/features/menu/domain/repositories/i_menu_repository.dart';
import 'package:kantin_app/features/menu/domain/usecases/get_menu_by_stan_id_usecase.dart';
import 'package:kantin_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:kantin_app/features/siswa/data/datasources/siswa_datasource.dart';
import 'package:kantin_app/features/siswa/data/repositories/siswa_repository.dart';
import 'package:kantin_app/features/siswa/domain/repositories/i_student_repository.dart';
import 'package:kantin_app/features/siswa/domain/usecases/get_siswa_profile_usecase.dart';
import 'package:kantin_app/features/siswa/domain/usecases/update_siswa_profile_usecase.dart';
import 'package:kantin_app/features/stan/data/datasources/stan_datasource.dart';
import 'package:kantin_app/features/stan/data/repositories/stan_repository.dart';
import 'package:kantin_app/features/stan/domain/repositories/i_stan_repository.dart';
import 'package:kantin_app/features/stan/domain/usecases/get_all_stans_usecase.dart';
import 'package:kantin_app/features/stan/presentation/bloc/all_canteens_bloc.dart';
import 'package:kantin_app/features/stan/presentation/bloc/canteen_detail_bloc.dart';
import 'package:kantin_app/features/stan/presentation/bloc/stan_profile_completion_bloc.dart';
import 'package:kantin_app/features/transaksi/data/datasources/transaksi_datasource.dart';
import 'package:kantin_app/features/transaksi/data/repositories/customer_repository.dart';
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
import '../services/location_service.dart';

final sl = GetIt.instance;

/// Initialize all dependencies
Future<void> initializeDependencies() async {
  // ========== External Dependencies ==========

  // Firebase
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<GoogleSignIn>(
    () => GoogleSignIn(
      clientId:
          '904687523024-0eebbsq93nojdadd88uk4e8mq4rulnr5.apps.googleusercontent.com',
    ),
  );
  sl.registerLazySingleton(() => CartService());
  sl.registerLazySingleton(() => CloudinaryService());
  sl.registerLazySingleton(() => StanService(sl()));
  sl.registerLazySingleton(() => FavoriteService());
  sl.registerLazySingleton(() => LocationService());
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

  // ========== Features - Category ==========

  sl.registerLazySingleton<CategoryRemoteDatasource>(
    () => CategoryRemoteDatasourceImpl(firestore: sl()),
  );

  sl.registerLazySingleton<ICategoryRepository>(
    () => CategoryRepository(datasource: sl(), firestore: sl()),
  );

  // ========== Features - Siswa ==========

  sl.registerLazySingleton<SiswaRemoteDatasource>(
    () => SiswaRemoteDatasourceImpl(firestore: sl()),
  );

  sl.registerLazySingleton<ISiswaRepository>(
    () => SiswaRepository(datasource: sl(), firestore: sl()),
  );

  // ========== Features - Transaksi ==========

  // Data Source
  sl.registerLazySingleton<TransaksiRemoteDatasource>(
    () => TransaksiRemoteDatasourceImpl(firestore: sl()),
  );

  // Repository
  sl.registerLazySingleton<ITransaksiRepository>(
    () => TransaksiRepository(
      datasource: sl(),
      firestore: sl(),
      dashboardDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<TransaksiRepository>(
    () => sl<ITransaksiRepository>() as TransaksiRepository,
  );

  // Customer Repository
  sl.registerLazySingleton<CustomerRepository>(
    () => CustomerRepository(firestore: sl()),
  );

  // ========== Features - Admin ==========

  sl.registerLazySingleton<AdminRemoteDatasource>(
    () => AdminRemoteDatasource(firestore: sl()),
  );

  // Dashboard Remote Data Source
  sl.registerLazySingleton<IDashboardRemoteDataSource>(
    () => DashboardRemoteDataSource(firestore: sl()),
  );

  // Dashboard Repository
  sl.registerLazySingleton<IDashboardRepository>(
    () => DashboardRepository(remoteDataSource: sl()),
  );

  // Repository
  sl.registerLazySingleton<IAdminRepository>(
    () => AdminRepository(
      authRepository: sl(),
      stanRepository: sl(),
      remoteDatasource: sl(),
    ),
  );

  sl.registerLazySingleton<AdminRepository>(
    () => sl<IAdminRepository>() as AdminRepository,
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
  sl.registerLazySingleton(() => GetActiveDiskonsByStanUseCase(sl()));
  sl.registerLazySingleton(() => GetDiskonForMenuUseCase(sl()));
  sl.registerLazySingleton(() => GetDashboardSummary(sl()));
  sl.registerLazySingleton(() => GetAllCustomers(sl()));
  sl.registerLazySingleton(() => GetSiswaProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateSiswaProfileUseCase(sl()));
  sl.registerLazySingleton(() => GetAllCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => CreateCategoryUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCategoryUseCase(sl()));

  // Diskon Use Cases
  sl.registerLazySingleton(() => CreateDiskonUseCase(sl()));
  sl.registerLazySingleton(() => GetDiskonsByStanUseCase(sl()));
  sl.registerLazySingleton(() => UpdateDiskonUseCase(sl()));
  sl.registerLazySingleton(() => DeleteDiskonUseCase(sl()));

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

  sl.registerFactory(
    () => SiswaHomeBloc(
      getAllStansUseCase: sl(),
      getAllCategoriesUseCase: sl(),
      locationService: sl(),
    ),
  );
  sl.registerFactory(
    () => ProfileBloc(
      getSiswaProfileUseCase: sl(),
      updateSiswaProfileUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => CheckoutBloc(
      cartService: sl(),
      getDiskonsByStanUseCase: sl(),
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

  sl.registerFactory(() => DashboardBloc(getDashboardSummary: sl()));
  sl.registerFactory(() => StanProfileBloc(adminRepository: sl()));
  sl.registerFactory(() => StanProfileCompletionBloc(sl()));

  sl.registerFactory(() => MenuManagementBloc(menuRepository: sl()));

  sl.registerFactory(() => OrderManagementBloc(transaksiRepository: sl()));

  sl.registerFactory(
    () => CustomerManagementBloc(
      getAllCustomers: sl(),
      transaksiRepository: sl(),
      customerRepository: sl(),
    ),
  );

  sl.registerFactory(() => OrderReportBloc(transaksiRepository: sl()));

  sl.registerFactory(() => GetUserStanBloc(stanService: sl()));

  sl.registerFactory(() => FavoriteBloc(favoriteService: sl()));

  sl.registerFactory(() => AllCanteensBloc(getAllStansUseCase: sl()));

  sl.registerFactory(
    () => CategoryManagementBloc(
      getAllCategoriesUseCase: sl(),
      createCategoryUseCase: sl(),
      updateCategoryUseCase: sl(),
    ),
  );

  // Diskon Management
  sl.registerFactory(
    () => DiskonManagementBloc(
      createDiskonUseCase: sl(),
      updateDiskonUseCase: sl(),
      deleteDiskonUseCase: sl(),
      getDiskonsByStanUseCase: sl(),
    ),
  );

  // ========== Features - More to be added ==========
  // We'll add more feature dependencies as we build them
}
