import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kantin_app/core/routes/app_routes.dart';
import 'package:kantin_app/features/checkout/presentation/bloc/checkout_bloc.dart';
import 'package:kantin_app/features/home/presentation/bloc/siswa_home_bloc.dart';
import 'package:kantin_app/features/stan/presentation/bloc/canteen_detail_bloc.dart';
import 'package:kantin_app/firebase_options.dart';
 
import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize dependencies
  await initializeDependencies();

  runApp(const KantinApp());
}

class KantinApp extends StatelessWidget {
  const KantinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Auth BLoC - available throughout the app
        BlocProvider(
          create: (context) => sl<AuthBloc>()
            ..add(const AuthStatusChecked())
            ..add(const AuthStateChangeSubscribed()),
        ),
        BlocProvider(
          create: (context) => sl<SiswaHomeBloc>(),
        ),
        BlocProvider(
          create: (context) => sl<CanteenDetailBloc>(),
        ),
        BlocProvider(
          create: (context) => sl<CheckoutBloc>(),
        ),
        // More BLoCs will be added here as we build other features
      ],
      child: MaterialApp.router(
        title: 'Kantin App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
