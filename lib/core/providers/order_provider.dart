import 'package:flutter/material.dart';

import '../models/order_model.dart';
import '../services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _orderService = OrderService();

  List<OrderModel> _orders = [];
  OrderModel? _selectedOrder;
  bool _isLoading = false;

  List<OrderModel> get orders => _orders;
  OrderModel? get selectedOrder => _selectedOrder;
  bool get isLoading => _isLoading;

  Future<OrderModel> createOrder({
    required String fulfillmentType,
    required String paymentMethod,
    int? addressId,
    String? orderNotes,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final order = await _orderService.createOrder(
        fulfillmentType: fulfillmentType,
        paymentMethod: paymentMethod,
        addressId: addressId,
        orderNotes: orderNotes,
      );

      _selectedOrder = order;
      return order;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      _orders = await _orderService.getOrders();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchOrderById(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      _selectedOrder = await _orderService.getOrderById(id);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSelectedOrder() {
    _selectedOrder = null;
    notifyListeners();
  }
}