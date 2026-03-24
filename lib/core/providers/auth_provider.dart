import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;

  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _authService.getCurrentUser();
    } catch (e) {
      debugPrint('loadUser error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.login(
        email: email,
        password: password,
      );

      _user = result['user'] as UserModel?;
    } catch (e) {
      debugPrint('login error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.register(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
      );

      _user = result['user'] as UserModel?;
    } catch (e) {
      debugPrint('register error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setUser(UserModel? user) {
    _user = user;
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
      _user = null;
      notifyListeners();
    } catch (e) {
      debugPrint('logout error: $e');
      rethrow;
    }
  }
}