import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/token_storage_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  bool _isAdmin = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _isAdmin;
  String? get error => _error;

  final AuthService _authService = AuthService();
  final TokenStorageService _tokenStorage = TokenStorageService();

  Future<void> setSession(UserModel user, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _tokenStorage.saveToken(token);
      _user = user;
      _isAdmin = user.isAdmin;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _user = null;
      _isAdmin = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );

      await setSession(result['user'], result['token']);
      return result;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> loadUser() async {
    return await checkAuthStatus();
  }

  Future<bool> checkAuthStatus() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _tokenStorage.getToken();

      if (token == null) {
        _user = null;
        _isAdmin = false;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final profile = await _authService.getProfile(token);

      _user = profile;
      _isAdmin = profile.isAdmin;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      await logout();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _tokenStorage.clearToken();
    _user = null;
    _error = null;
    _isAdmin = false;
    notifyListeners();
  }
}