import 'package:flutter/material.dart';

import '../models/smoothie_model.dart';
import '../services/smoothie_service.dart';

class SmoothieProvider extends ChangeNotifier {
  final SmoothieService _smoothieService = SmoothieService();

  List<SmoothieModel> _smoothies = [];
  List<SmoothieModel> _featuredSmoothies = [];
  bool _isLoading = false;

  List<SmoothieModel> get smoothies => _smoothies;
  List<SmoothieModel> get featuredSmoothies => _featuredSmoothies;
  bool get isLoading => _isLoading;

  Future<void> fetchSmoothies() async {
    _isLoading = true;
    notifyListeners();

    _smoothies = await _smoothieService.getAllSmoothies();
    _featuredSmoothies = await _smoothieService.getFeaturedSmoothies();

    _isLoading = false;
    notifyListeners();
  }
}