import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class AuthService {
  final SupabaseClient _supabase = SupabaseService.client;

  // Sign Up
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
      data: name != null && name.trim().isNotEmpty
          ? {'full_name': name.trim()}
          : null,
    );
  }

  // Login
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Logout
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Delete account (best-effort, local fallback)
  Future<bool> deleteAccount() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;
      try {
        await _supabase.rpc('delete_user', params: {'uid': user.id});
      } catch (_) {
        // ignore: server-side RPC is optional; still log out locally
      }
      await signOut();
      return true;
    } catch (e) {
      // Always sign out even if server-side delete fails
      try {
        await signOut();
      } catch (_) {}
      return false;
    }
  }

  // Current User
  User? get currentUser => _supabase.auth.currentUser;

  // Check Login Status
  bool get isLoggedIn => currentUser != null;
}