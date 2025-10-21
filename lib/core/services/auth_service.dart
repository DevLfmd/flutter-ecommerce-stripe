import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/domain/models/user.dart' as app_user;
import 'storage_service.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  app_user.User? _currentUser;
  bool _isLoggedIn = false;
  
  app_user.User? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  
  AuthService() {
    _initializeAuth();
  }
  
  void _initializeAuth() {
    // Listen to auth state changes
    _supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        _currentUser = app_user.User.fromSupabaseUser(session.user);
        _isLoggedIn = true;
      } else {
        _currentUser = null;
        _isLoggedIn = false;
      }
    });
    
    // Check if user is already logged in
    final session = _supabase.auth.currentSession;
    if (session != null) {
      _currentUser = app_user.User.fromSupabaseUser(session.user!);
      _isLoggedIn = true;
    }
  }
  
  Future<app_user.User> login(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user == null) {
        throw Exception('Login failed');
      }
      
      _currentUser = app_user.User.fromSupabaseUser(response.user!);
      _isLoggedIn = true;
      
      // Store user data locally
      await StorageService.storeUser(_currentUser!);
      
      return _currentUser!;
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }
  
  Future<app_user.User> register(String email, String password, String name) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );
      
      if (response.user == null) {
        throw Exception('Registration failed');
      }
      
      _currentUser = app_user.User.fromSupabaseUser(response.user!);
      _isLoggedIn = true;
      
      // Store user data locally
      await StorageService.storeUser(_currentUser!);
      
      return _currentUser!;
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }
  
  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
      _currentUser = null;
      _isLoggedIn = false;
      
      // Clear stored user data
      await StorageService.clearUser();
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }
  
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }
  
  Future<void> updateProfile({
    String? name,
    String? phone,
    String? address,
  }) async {
    try {
      if (_currentUser == null) {
        throw Exception('User not logged in');
      }
      
      // Update user metadata
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (phone != null) updates['phone'] = phone;
      if (address != null) updates['address'] = address;
      
      await _supabase.auth.updateUser(
        UserAttributes(data: updates),
      );
      
      // Update local user data
      _currentUser = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
        phone: phone ?? _currentUser!.phone,
        address: address ?? _currentUser!.address,
      );
      
      await StorageService.storeUser(_currentUser!);
    } catch (e) {
      throw Exception('Profile update failed: ${e.toString()}');
    }
  }
  
  Future<void> changePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      throw Exception('Password change failed: ${e.toString()}');
    }
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

