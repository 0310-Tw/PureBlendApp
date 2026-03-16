import 'order_item_model.dart';

class OrderModel {
  final int id;
  final String orderNumber;
  final String fulfillmentType;
  final String paymentMethod;
  final String? orderNotes;
  final double subtotal;
  final double deliveryFee;
  final double totalAmount;
  final String status;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.fulfillmentType,
    required this.paymentMethod,
    this.orderNotes,
    required this.subtotal,
    required this.deliveryFee,
    required this.totalAmount,
    required this.status,
    this.items = const [],
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];

    return OrderModel(
      id: json['id'],
      orderNumber: json['order_number'] ?? '',
      fulfillmentType: json['fulfillment_type'] ?? '',
      paymentMethod: json['payment_method'] ?? '',
      orderNotes: json['order_notes'],
      subtotal: double.tryParse(json['subtotal'].toString()) ?? 0,
      deliveryFee: double.tryParse(json['delivery_fee'].toString()) ?? 0,
      totalAmount: double.tryParse(json['total_amount'].toString()) ?? 0,
      status: json['status'] ?? '',
      items: rawItems.map((e) => OrderItemModel.fromJson(e)).toList(),
    );
  }
}