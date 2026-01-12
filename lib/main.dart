import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kantin_app/core/routes/app_routes.dart';
import 'package:kantin_app/firebase_options.dart';
import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  
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