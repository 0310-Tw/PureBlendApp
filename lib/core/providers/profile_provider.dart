import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();

  UserModel? _profile;
  bool _isLoading = false;

  UserModel? get profile => _profile;
  bool get isLoading => _isLoading;

  Future<void> fetchProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      _profile = await _profileService.getProfile();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<UserModel> updateProfile({
    required String fullName,
    required String email,
    required String phone,
    String? profileImageUrl,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updated = await _profileService.updateProfile(
        fullName: fullName,
        email: email,
        phone: phone,
        profileImageUrl: profileImageUrl,
      );

      _profile = updated;
      return updated;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<UserModel> updatePreferences({
    required String preferredFulfillment,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updated = await _profileService.updatePreferences(
        preferredFulfillment: preferredFulfillment,
      );

      _profile = updated;
      return updated;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setProfile(UserModel user) {
    _profile = user;
    notifyListeners();
  }

  void clearProfile() {
    _profile = null;
    notifyListeners();
  }
}