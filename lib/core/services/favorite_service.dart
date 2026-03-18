import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../models/smoothie_model.dart';
import 'token_storage_service.dart';

class FavoriteService {
  final TokenStorageService _tokenStorageService = TokenStorageService();

  Future<List<SmoothieModel>> getFavorites() async {
    final token = await _tokenStorageService.getToken();

    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/favorites'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      final items = data['data'] as List<dynamic>;
      return items.map((e) => SmoothieModel.fromJson(e)).toList();
    }

    throw Exception(data['message'] ?? 'Failed to fetch favorites');
  }

  Future<void> addFavorite(int smoothieId) async {
    final token = await _tokenStorageService.getToken();

    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/favorites'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'smoothie_id': smoothieId,
      }),
    );

    final data = jsonDecode(response.body);

    if (!(response.statusCode == 201 && data['success'] == true)) {
      throw Exception(data['message'] ?? 'Failed to add favorite');
    }
  }

  Future<void> removeFavorite(int smoothieId) async {
    final token = await _tokenStorageService.getToken();

    if (token == null) {
      throw Exception('User is not authenticated');
    }

    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/favorites/$smoothieId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (!(response.statusCode == 200 && data['success'] == true)) {
      throw Exception(data['message'] ?? 'Failed to remove favorite');
    }
  }
}