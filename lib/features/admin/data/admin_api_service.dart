import 'dart:convert';
import 'package:frontend/core/api_config.dart';
import 'package:frontend/features/admin/models/admin_smoothie_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/admin_order_model.dart';


class AdminApiService {
  static const _tokenKey = 'token';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<Map<String, String>> _headers() async {
    final token = await _getToken();

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> getDashboard() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/admin/dashboard');

    final response = await http.get(
      uri,
      headers: await _headers(),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body as Map<String, dynamic>;
    } else {
      throw Exception(body['message'] ?? 'Failed to load dashboard');
    }
  }

  Future<List<AdminOrderModel>> getAllOrders() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/admin/orders');

    final response = await http.get(
      uri,
      headers: await _headers(),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = body['data'];
      if (data is List) {
        return data
            .map((e) => AdminOrderModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } else {
      throw Exception(body['message'] ?? 'Failed to load orders');
    }
  }

  Future<AdminOrderModel> updateOrderStatus({
    required int orderId,
    required String status,
  }) async {
    final uri =
        Uri.parse('${ApiConfig.baseUrl}/api/admin/orders/$orderId/status');

    final response = await http.patch(
      uri,
      headers: await _headers(),
      body: jsonEncode({
        'status': status,
      }),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return AdminOrderModel.fromJson(body['data'] as Map<String, dynamic>);
    } else {
      throw Exception(body['message'] ?? 'Failed to update order status');
    }
  }

  Future<List<AdminSmoothieModel>> getAllSmoothies() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/admin/smoothies');

    final response = await http.get(
      uri,
      headers: await _headers(),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = body['data'];
      if (data is List) {
        return data
            .map((e) => AdminSmoothieModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } else {
      throw Exception(body['message'] ?? 'Failed to load smoothies');
    }
  }

  Future<AdminSmoothieModel> createSmoothie({
    required String name,
    required String description,
    required double price,
    required String imageUrl,
    required bool isAvailable,
    required String category,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/admin/smoothies');

    final response = await http.post(
      uri,
      headers: await _headers(),
      body: jsonEncode({
        'name': name,
        'description': description,
        'price': price,
        'image_url': imageUrl,
        'is_available': isAvailable,
        'category': category,
      }),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return AdminSmoothieModel.fromJson(body['data'] as Map<String, dynamic>);
    } else {
      throw Exception(body['message'] ?? 'Failed to create smoothie');
    }
  }

  Future<AdminSmoothieModel> updateSmoothie({
    required int smoothieId,
    required String name,
    required String description,
    required double price,
    required String imageUrl,
    required bool isAvailable,
    required String category,
  }) async {
    final uri =
        Uri.parse('${ApiConfig.baseUrl}/api/admin/smoothies/$smoothieId');

    final response = await http.put(
      uri,
      headers: await _headers(),
      body: jsonEncode({
        'name': name,
        'description': description,
        'price': price,
        'image_url': imageUrl,
        'is_available': isAvailable,
        'category': category,
      }),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return AdminSmoothieModel.fromJson(body['data'] as Map<String, dynamic>);
    } else {
      throw Exception(body['message'] ?? 'Failed to update smoothie');
    }
  }

  Future<void> deleteSmoothie(int smoothieId) async {
    final uri =
        Uri.parse('${ApiConfig.baseUrl}/api/admin/smoothies/$smoothieId');

    final response = await http.delete(
      uri,
      headers: await _headers(),
    );

    final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        body is Map<String, dynamic>
            ? body['message'] ?? 'Failed to delete smoothie'
            : 'Failed to delete smoothie',
      );
    }
  }
}