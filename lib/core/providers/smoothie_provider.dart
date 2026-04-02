import 'package:flutter/material.dart';

import '../models/smoothie_model.dart';
import '../services/smoothie_service.dart';

class SmoothieProvider extends ChangeNotifier {
  final SmoothieService _smoothieService = SmoothieService();

  List<SmoothieModel> _smoothies = [];
  List<SmoothieModel> _featuredSmoothies = [];
  bool _isLoading = false;
  String? _error;

  List<SmoothieModel> get smoothies => _smoothies;
  List<SmoothieModel> get featuredSmoothies => _featuredSmoothies;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchSmoothies() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _smoothies = await _smoothieService.getAllSmoothies();

      try {
        _featuredSmoothies = await _smoothieService.getFeaturedSmoothies();
      } catch (_) {
        _featuredSmoothies =
            _smoothies.where((smoothie) => smoothie.isFeatured).toList();
      }
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _smoothies = [];
      _featuredSmoothies = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}