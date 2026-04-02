import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../models/user_model.dart';

class AuthService {
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
      };

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/auth/register'),
      headers: _headers,
      body: jsonEncode({
        'name': name.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201 && data['success'] == true) {
      return {
        'user': UserModel.fromJson(data['data']),
        'token': data['token'],
      };
    }

    throw Exception(data['message'] ?? 'Registration failed');
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/auth/login'),
      headers: _headers,
      body: jsonEncode({
        'email': email.trim(),
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return {
        'user': UserModel.fromJson(data['data']),
        'token': data['token'],
      };
    }

    throw Exception(data['message'] ?? 'Login failed');
  }

  Future<UserModel> getProfile(String token) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/auth/profile'),
      headers: {
        ..._headers,
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return UserModel.fromJson(data['data']);
    }

    throw Exception(data['message'] ?? 'Failed to load profile');
  }

  Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/auth/forgot-password'),
      headers: _headers,
      body: jsonEncode({
        'email': email.trim(),
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return {
        'message': data['message'] ?? 'Reset token generated successfully.',
        'resetToken': data['resetToken'],
        'expiresAt': data['expiresAt'],
      };
    }

    throw Exception(data['message'] ?? 'Forgot password failed');
  }

  Future<String> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/auth/reset-password'),
      headers: _headers,
      body: jsonEncode({
        'token': token.trim(),
        'newPassword': newPassword,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return data['message'] ?? 'Password reset successful.';
    }

    throw Exception(data['message'] ?? 'Reset password failed');
  }
}