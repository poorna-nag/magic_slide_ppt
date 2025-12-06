import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magic_slide_ppt/core/constants/app_constants.dart';
import 'package:magic_slide_ppt/features/auth/data/repo/auth_repository_impl.dart';
import 'package:magic_slide_ppt/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:magic_slide_ppt/features/auth/presentation/bloc/auth_event.dart';
import 'package:magic_slide_ppt/features/auth/presentation/bloc/auth_state.dart';
import 'package:magic_slide_ppt/features/auth/presentation/login_screen.dart';
import 'package:magic_slide_ppt/features/ppt/data/repo/presentation_repository_impl.dart';
import 'package:magic_slide_ppt/features/ppt/presentation/bloc/presentation_bloc.dart';
import 'package:magic_slide_ppt/features/ppt/presentation/home_screen.dart';

import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(AuthRepositoryImpl())..add(AuthCheck()),
        ),
        BlocProvider(
          create: (_) => PresentationBloc(PresentationRepositoryImpl()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MagicSlides',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return HomeScreen(email: state.userEmail);
        }
        return const LoginScreen();
      },
    );
  }
}
