import 'package:flutter/material.dart';

import '../models/address_model.dart';
import '../services/address_service.dart';

class AddressProvider extends ChangeNotifier {
  final AddressService _addressService = AddressService();

  List<AddressModel> _addresses = [];
  bool _isLoading = false;

  List<AddressModel> get addresses => _addresses;
  bool get isLoading => _isLoading;

  AddressModel? get defaultAddress {
    try {
      return _addresses.firstWhere((e) => e.isDefault);
    } catch (_) {
      return _addresses.isNotEmpty ? _addresses.first : null;
    }
  }

  Future<void> fetchAddresses() async {
    _isLoading = true;
    notifyListeners();

    try {
      _addresses = await _addressService.getAddresses();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createAddress({
    required String label,
    String? recipientName,
    String? recipientPhone,
    required String streetAddress,
    required String town,
    required String parish,
    String? deliveryNotes,
    required bool isDefault,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _addressService.createAddress(
        label: label,
        recipientName: recipientName,
        recipientPhone: recipientPhone,
        streetAddress: streetAddress,
        town: town,
        parish: parish,
        deliveryNotes: deliveryNotes,
        isDefault: isDefault,
      );

      _addresses = await _addressService.getAddresses();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateAddress({
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
    _isLoading = true;
    notifyListeners();

    try {
      await _addressService.updateAddress(
        id: id,
        label: label,
        recipientName: recipientName,
        recipientPhone: recipientPhone,
        streetAddress: streetAddress,
        town: town,
        parish: parish,
        deliveryNotes: deliveryNotes,
        isDefault: isDefault,
      );

      _addresses = await _addressService.getAddresses();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAddress(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _addressService.deleteAddress(id);
      _addresses = await _addressService.getAddresses();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setDefaultAddress(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _addressService.setDefaultAddress(id);
      _addresses = await _addressService.getAddresses();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}