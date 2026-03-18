import 'package:flutter/material.dart';
import '../models/smoothie_model.dart';
import '../services/favorite_service.dart';

class FavoriteProvider extends ChangeNotifier {
  final FavoriteService _favoriteService = FavoriteService();

  List<SmoothieModel> _favorites = [];
  bool _isLoading = false;

  List<SmoothieModel> get favorites => _favorites;
  bool get isLoading => _isLoading;
  bool get isEmpty => _favorites.isEmpty;

  bool isFavorite(int smoothieId) {
    return _favorites.any((item) => item.id == smoothieId);
  }

  Future<void> fetchFavorites() async {
    _isLoading = true;
    notifyListeners();

    try {
      _favorites = await _favoriteService.getFavorites();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addFavorite(int smoothieId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _favoriteService.addFavorite(smoothieId);
      _favorites = await _favoriteService.getFavorites();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeFavorite(int smoothieId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _favoriteService.removeFavorite(smoothieId);
      _favorites = await _favoriteService.getFavorites();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(int smoothieId) async {
    if (isFavorite(smoothieId)) {
      await removeFavorite(smoothieId);
    } else {
      await addFavorite(smoothieId);
    }
  }

  void clearFavorites() {
    _favorites = [];
    notifyListeners();
  }
}