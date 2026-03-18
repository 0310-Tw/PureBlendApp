import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../models/order_model.dart';
import 'token_storage_service.dart';

class OrderService {
  final TokenStorageService _tokenStorageService = TokenStorageService();

  Future<OrderModel> createOrder({
    required String fulfillmentType,
    required String paymentMethod,
    int? addressId,
    String? orderNotes,
  }) async {
    final token = await _tokenStorageService.getToken();

    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final body = <String, dynamic>{
      'fulfillment_type': fulfillmentType,
      'payment_method': paymentMethod,
      'order_notes': orderNotes,
    };

    if (addressId != null) {
      body['address_id'] = addressId;
    }

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/orders'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201 && data['success'] == true) {
      return OrderModel.fromJson(data['data']);
    }

    throw Exception(data['message'] ?? 'Failed to create order');
  }

  Future<List<OrderModel>> getOrders() async {
    final token = await _tokenStorageService.getToken();

    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/orders'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      final items = data['data'] as List<dynamic>;
      return items.map((e) => OrderModel.fromJson(e)).toList();
    }

    throw Exception(data['message'] ?? 'Failed to fetch orders');
  }

  Future<OrderModel> getOrderById(int id) async {
    final token = await _tokenStorageService.getToken();

    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/orders/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return OrderModel.fromJson(data['data']);
    }

    throw Exception(data['message'] ?? 'Failed to fetch order details');
  }
}