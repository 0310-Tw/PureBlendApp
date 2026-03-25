import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import 'token_storage_service.dart';

class DeviceService {
  final TokenStorageService _tokenStorageService = TokenStorageService();

  Future<void> registerDeviceToken({
    required String fcmToken,
    required String platform,
  }) async {
    final token = await _tokenStorageService.getToken();

    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/devices/register-token'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'fcm_token': fcmToken,
        'platform': platform,
      }),
    );

    final data = jsonDecode(response.body);

    if (!(response.statusCode == 200 && data['success'] == true)) {
      throw Exception(data['message'] ?? 'Failed to register device token');
    }
  }

  Future<void> unregisterDeviceToken({
    required String fcmToken,
  }) async {
    final token = await _tokenStorageService.getToken();

    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final request = http.Request(
      'DELETE',
      Uri.parse('${ApiConstants.baseUrl}/devices/unregister-token'),
    );

    request.headers.addAll({
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });

    request.body = jsonEncode({
      'fcm_token': fcmToken,
    });

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final data = jsonDecode(response.body);

    if (!(response.statusCode == 200 && data['success'] == true)) {
      throw Exception(data['message'] ?? 'Failed to unregister device token');
    }
  }
}