import 'package:flutter/material.dart';

import '../models/cart_item_model.dart';
import '../services/cart_service.dart';

class CartProvider extends ChangeNotifier {
  final CartService _cartService = CartService();

  List<CartItemModel> _items = [];
  bool _isLoading = false;
  int _itemCount = 0;
  double _subtotal = 0;

  List<CartItemModel> get items => _items;
  bool get isLoading => _isLoading;
  int get itemCount => _itemCount;
  double get subtotal => _subtotal;
  bool get isEmpty => _items.isEmpty;

  Future<void> fetchCart() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _cartService.getCart();
      _items = result['items'] as List<CartItemModel>;
      _itemCount = result['item_count'] as int;
      _subtotal = result['subtotal'] as double;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart({
    required int smoothieId,
    required String sizeName,
    required int quantity,
    String? notes,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _cartService.addToCart(
        smoothieId: smoothieId,
        sizeName: sizeName,
        quantity: quantity,
        notes: notes,
      );

      await fetchCart();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCartItem({
    required int cartItemId,
    required String sizeName,
    required int quantity,
    String? notes,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _cartService.updateCartItem(
        cartItemId: cartItemId,
        sizeName: sizeName,
        quantity: quantity,
        notes: notes,
      );

      await fetchCart();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCartItem(int cartItemId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _cartService.deleteCartItem(cartItemId);
      await fetchCart();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _cartService.clearCart();
      _items = [];
      _itemCount = 0;
      _subtotal = 0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}