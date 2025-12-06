import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magic_slide_ppt/features/auth/data/repo/auth_repository.dart';
import 'package:magic_slide_ppt/features/auth/presentation/bloc/auth_state.dart';

import 'auth_event.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;

  AuthBloc(this.repository) : super(AuthInitial()) {
    on<AuthCheck>(_onAuthCheck);
    on<AuthSignup>(_onAuthSignup);
    on<AuthLogin>(_onAuthLogin);
    on<AuthLogout>(_onAuthLogout);
  }

  void _onAuthCheck(AuthCheck event, Emitter<AuthState> emit) {
    final email = repository.checkAuth();
    if (email != null) {
      emit(AuthAuthenticated(email));
    }
  }

  String _extractErrorMessage(dynamic error) {
    if (error is Exception) {
      final errorString = error.toString();
      // Remove "Exception: " prefix if present
      if (errorString.startsWith('Exception: ')) {
        return errorString.substring(11);
      }
      return errorString;
    }
    return error.toString();
  }

  Future<void> _onAuthSignup(AuthSignup event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final email = await repository.signUp(event.email, event.password);
      emit(AuthAuthenticated(email));
    } catch (e) {
      emit(AuthError(_extractErrorMessage(e)));
    }
  }

  Future<void> _onAuthLogin(AuthLogin event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final email = await repository.signIn(event.email, event.password);
      emit(AuthAuthenticated(email));
    } catch (e) {
      emit(AuthError(_extractErrorMessage(e)));
    }
  }

  Future<void> _onAuthLogout(AuthLogout event, Emitter<AuthState> emit) async {
    await repository.signOut();
    emit(AuthInitial());
  }
}
