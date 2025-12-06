abstract class AuthRepository {
  /// Check if user is currently authenticated
  String? checkAuth();

  /// Sign up a new user
  Future<String> signUp(String email, String password);

  /// Sign in an existing user
  Future<String> signIn(String email, String password);

  /// Sign out the current user
  Future<void> signOut();
}
