import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../models/user_model.dart';
import 'token_storage_service.dart';

class ProfileService {
  final TokenStorageService _tokenStorageService = TokenStorageService();

  Future<UserModel> getProfile() async {
    final token = await _tokenStorageService.getToken();

    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return UserModel.fromJson(data['data']);
    }

    throw Exception(data['message'] ?? 'Failed to fetch profile');
  }

  Future<UserModel> updateProfile({
    required String fullName,
    required String email,
    required String phone,
    String? profileImageUrl,
  }) async {
    final token = await _tokenStorageService.getToken();

    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'profile_image_url': profileImageUrl,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return UserModel.fromJson(data['data']);
    }

    throw Exception(data['message'] ?? 'Failed to update profile');
  }

  Future<UserModel> updatePreferences({
    required String preferredFulfillment,
  }) async {
    final token = await _tokenStorageService.getToken();

    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await http.patch(
      Uri.parse('${ApiConstants.baseUrl}/profile/preferences'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'preferred_fulfillment': preferredFulfillment,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return UserModel.fromJson(data['data']);
    }

    throw Exception(data['message'] ?? 'Failed to update preferences');
  }
}