import 'dart:io';
import 'package:magic_slide_ppt/features/auth/data/repo/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient supabase;

  AuthRepositoryImpl({SupabaseClient? supabaseClient})
    : supabase = supabaseClient ?? Supabase.instance.client;

  @override
  String? checkAuth() {
    final session = supabase.auth.currentSession;
    return session?.user.email;
  }

  /// Parses exceptions and returns user-friendly error messages
  String _parseError(dynamic error) {
    // Check for AuthRetryableFetchException (network errors)
    if (error is AuthRetryableFetchException) {
      final message = error.message.toLowerCase();

      // Check for DNS/host lookup failures
      if (message.contains('failed host lookup') ||
          message.contains('no address associated with hostname') ||
          message.contains('socketexception')) {
        return 'Unable to connect. Please check your internet connection.';
      }

      // Check for connection timeouts
      if (message.contains('timeout') || message.contains('timed out')) {
        return 'Connection timeout. Please check your internet connection and try again.';
      }

      // Check for general connection errors
      if (message.contains('connection') || message.contains('network')) {
        return 'Network error. Please check your internet connection.';
      }

      // Generic network error
      return 'Unable to connect to the server. Please check your internet connection.';
    }

    // Check for AuthException (authentication errors)
    if (error is AuthException) {
      final message = error.message.toLowerCase();

      // Invalid credentials
      if (message.contains('invalid login') ||
          message.contains('invalid credentials') ||
          message.contains('email not confirmed') ||
          message.contains('wrong password') ||
          message.contains('user not found')) {
        return 'Invalid email or password.';
      }

      // Email already exists (for signup)
      if (message.contains('already registered') ||
          message.contains('user already exists')) {
        return 'An account with this email already exists.';
      }

      // Return the auth error message if it's user-friendly enough
      return error.message;
    }

    // Check for SocketException directly
    if (error is SocketException) {
      return 'Unable to connect. Please check your internet connection.';
    }

    // Check for other network-related exceptions
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('failed host lookup') ||
        errorString.contains('socketexception') ||
        errorString.contains('network') ||
        errorString.contains('connection')) {
      return 'Unable to connect. Please check your internet connection.';
    }

    // Generic error fallback
    return 'An error occurred. Please try again.';
  }

  @override
  Future<String> signUp(String email, String password) async {
    try {
      await supabase.auth.signUp(email: email, password: password);
      return email;
    } catch (e) {
      throw Exception(_parseError(e));
    }
  }

  @override
  Future<String> signIn(String email, String password) async {
    try {
      await supabase.auth.signInWithPassword(email: email, password: password);
      return email;
    } catch (e) {
      throw Exception(_parseError(e));
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
    } catch (e) {
      // Sign out errors are usually not critical, but we'll handle them
      throw Exception(_parseError(e));
    }
  }
}
