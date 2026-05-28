import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/dio_client.dart';
import '../core/storage/secure_storage.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(dioProvider));
});

final authProvider = AsyncNotifierProvider<AuthNotifier, UserModel?>(() {
  return AuthNotifier();
});

class AuthNotifier extends AsyncNotifier<UserModel?> {
  late AuthService _authService;
  late SecureStorage _storage;

  @override
  Future<UserModel?> build() async {
    _authService = ref.watch(authServiceProvider);
    _storage = SecureStorage();

    debugPrint('AuthNotifier.build: Checking for token...');
    final token = await _storage.getToken();
    
    if (token != null) {
      debugPrint('AuthNotifier.build: Token found. Fetching user...');
      try {
        final user = await _authService.getMe();
        debugPrint('AuthNotifier.build: User fetched: ${user.name}');
        return user;
      } catch (e) {
        debugPrint('AuthNotifier.build: Failed to fetch user: $e');
        // If API fails, maybe keep the user or handle specifically?
        // For now, return null as per original intent but logged
        return null;
      }
    }
    debugPrint('AuthNotifier.build: No token found.');
    return null;
  }

  // Explicit method to reset state for retries
  void resetState() {
    state = const AsyncValue.data(null);
  }

  Future<void> login(String email, String password) async {
    // Reset state before starting a new login attempt
    state = const AsyncValue.loading();
    
    try {
      final response = await _authService.login(email, password);
      final token = response['token'];
      final user = UserModel.fromJson(response['user']);
      await _storage.saveToken(token);
      state = AsyncValue.data(user);
    } on DioException catch (e) {
      // Extract readable message from Laravel API
      final String errorMessage = e.response?.data['message'] ?? 
                                  "Incorrect email or password. Please try again.";
      state = AsyncValue.error(errorMessage, StackTrace.current);
    } catch (e, stack) {
      state = AsyncValue.error("An unexpected error occurred.", stack);
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      try {
        await _authService.logout();
      } finally {
        await _storage.deleteToken();
      }
      return null;
    });
  }
}
