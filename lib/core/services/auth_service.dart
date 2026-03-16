import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../models/user_model.dart';
import 'token_storage_service.dart';

class AuthService {
  final TokenStorageService _tokenStorageService = TokenStorageService();

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      final token = data['data']['token'];
      final user = UserModel.fromJson(data['data']['user']);

      await _tokenStorageService.saveToken(token);

      return {
        'token': token,
        'user': user,
      };
    }

    throw Exception(data['message'] ?? 'Login failed');
  }

  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201 && data['success'] == true) {
      final token = data['data']['token'];
      final user = UserModel.fromJson(data['data']['user']);

      await _tokenStorageService.saveToken(token);

      return {
        'token': token,
        'user': user,
      };
    }

    throw Exception(data['message'] ?? 'Registration failed');
  }

  Future<UserModel?> getCurrentUser() async {
    final token = await _tokenStorageService.getToken();

    if (token == null) return null;

    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/auth/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return UserModel.fromJson(data['data']);
    }

    return null;
  }

  Future<void> logout() async {
    await _tokenStorageService.clearToken();
  }
}