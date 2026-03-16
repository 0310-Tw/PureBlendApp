import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../models/cart_item_model.dart';
import 'token_storage_service.dart';

class CartService {
  final TokenStorageService _tokenStorageService = TokenStorageService();

  Future<Map<String, dynamic>> getCart() async {
    final token = await _tokenStorageService.getToken();

    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/cart'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      final items = (data['data'] as List<dynamic>)
          .map((e) => CartItemModel.fromJson(e))
          .toList();

      final summary = data['summary'] as Map<String, dynamic>;

      return {
        'items': items,
        'item_count': summary['item_count'] ?? 0,
        'subtotal': double.tryParse(summary['subtotal'].toString()) ?? 0,
      };
    }

    throw Exception(data['message'] ?? 'Failed to fetch cart');
  }

  Future<CartItemModel> addToCart({
    required int smoothieId,
    required String sizeName,
    required int quantity,
    String? notes,
  }) async {
    final token = await _tokenStorageService.getToken();

    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/cart'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'smoothie_id': smoothieId,
        'size_name': sizeName,
        'quantity': quantity,
        'notes': notes,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201 && data['success'] == true) {
      return CartItemModel.fromJson(data['data']);
    }

    throw Exception(data['message'] ?? 'Failed to add item to cart');
  }

  Future<CartItemModel> updateCartItem({
    required int cartItemId,
    required String sizeName,
    required int quantity,
    String? notes,
  }) async {
    final token = await _tokenStorageService.getToken();

    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/cart/$cartItemId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'size_name': sizeName,
        'quantity': quantity,
        'notes': notes,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return CartItemModel.fromJson(data['data']);
    }

    throw Exception(data['message'] ?? 'Failed to update cart item');
  }

  Future<void> deleteCartItem(int cartItemId) async {
    final token = await _tokenStorageService.getToken();

    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/cart/$cartItemId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (!(response.statusCode == 200 && data['success'] == true)) {
      throw Exception(data['message'] ?? 'Failed to delete cart item');
    }
  }

  Future<void> clearCart() async {
    final token = await _tokenStorageService.getToken();

    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/cart'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (!(response.statusCode == 200 && data['success'] == true)) {
      throw Exception(data['message'] ?? 'Failed to clear cart');
    }
  }
}