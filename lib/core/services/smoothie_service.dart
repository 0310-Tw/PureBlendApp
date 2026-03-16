import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../models/smoothie_model.dart';

class SmoothieService {
  Future<List<SmoothieModel>> getAllSmoothies() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/smoothies'),
      headers: {'Content-Type': 'application/json'},
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      final items = data['data'] as List<dynamic>;
      return items.map((e) => SmoothieModel.fromJson(e)).toList();
    }

    throw Exception(data['message'] ?? 'Failed to fetch smoothies');
  }

  Future<List<SmoothieModel>> getFeaturedSmoothies() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/smoothies/featured/list'),
      headers: {'Content-Type': 'application/json'},
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      final items = data['data'] as List<dynamic>;
      return items.map((e) => SmoothieModel.fromJson(e)).toList();
    }

    throw Exception(data['message'] ?? 'Failed to fetch featured smoothies');
  }

  Future<SmoothieModel> getSmoothieById(int id) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/smoothies/$id'),
      headers: {'Content-Type': 'application/json'},
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return SmoothieModel.fromJson(data['data']);
    }

    throw Exception(data['message'] ?? 'Failed to fetch smoothie details');
  }
}