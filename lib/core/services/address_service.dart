import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../models/address_model.dart';
import 'token_storage_service.dart';

class AddressService {
  final TokenStorageService _tokenStorageService = TokenStorageService();

  Future<List<AddressModel>> getAddresses() async {
    final token = await _tokenStorageService.getToken();

    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/addresses'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      final items = data['data'] as List<dynamic>;
      return items.map((e) => AddressModel.fromJson(e)).toList();
    }

    throw Exception(data['message'] ?? 'Failed to fetch addresses');
  }

  Future<AddressModel> createAddress({
    required String label,
    String? recipientName,
    String? recipientPhone,
    required String streetAddress,
    required String town,
    required String parish,
    String? deliveryNotes,
    required bool isDefault,
  }) async {
    final token = await _tokenStorageService.getToken();

    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/addresses'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'label': label,
        'recipient_name': recipientName,
        'recipient_phone': recipientPhone,
        'street_address': streetAddress,
        'town': town,
        'parish': parish,
        'delivery_notes': deliveryNotes,
        'is_default': isDefault,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201 && data['success'] == true) {
      return AddressModel.fromJson(data['data']);
    }

    throw Exception(data['message'] ?? 'Failed to create address');
  }

  Future<AddressModel> updateAddress({
    required int id,
    required String label,
    String? recipientName,
    String? recipientPhone,
    required String streetAddress,
    required String town,
    required String parish,
    String? deliveryNotes,
    required bool isDefault,
  }) async {
    final token = await _tokenStorageService.getToken();

    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/addresses/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'label': label,
        'recipient_name': recipientName,
        'recipient_phone': recipientPhone,
        'street_address': streetAddress,
        'town': town,
        'parish': parish,
        'delivery_notes': deliveryNotes,
        'is_default': isDefault,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return AddressModel.fromJson(data['data']);
    }

    throw Exception(data['message'] ?? 'Failed to update address');
  }

  Future<void> deleteAddress(int id) async {
    final token = await _tokenStorageService.getToken();

    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/addresses/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (!(response.statusCode == 200 && data['success'] == true)) {
      throw Exception(data['message'] ?? 'Failed to delete address');
    }
  }

  Future<AddressModel> setDefaultAddress(int id) async {
    final token = await _tokenStorageService.getToken();

    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await http.patch(
      Uri.parse('${ApiConstants.baseUrl}/addresses/$id/default'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return AddressModel.fromJson(data['data']);
    }

    throw Exception(data['message'] ?? 'Failed to set default address');
  }
}