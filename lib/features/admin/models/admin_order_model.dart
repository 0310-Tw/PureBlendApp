class AdminOrderModel {
  final int id;
  final String status;
  final double totalAmount;
  final String customerName;
  final String customerEmail;
  final String createdAt;
  final String deliveryAddress;
  final List<dynamic> items;

  AdminOrderModel({
    required this.id,
    required this.status,
    required this.totalAmount,
    required this.customerName,
    required this.customerEmail,
    required this.createdAt,
    required this.deliveryAddress,
    required this.items,
  });

  factory AdminOrderModel.fromJson(Map<String, dynamic> json) {
    return AdminOrderModel(
      id: _parseInt(json['id']),
      status: (json['status'] ?? '').toString(),
      totalAmount: _parseDouble(
        json['total_amount'] ?? json['totalAmount'] ?? json['total'] ?? 0,
      ),
      customerName: (json['customer_name'] ??
              json['customerName'] ??
              json['name'] ??
              'Unknown Customer')
          .toString(),
      customerEmail:
          (json['customer_email'] ?? json['customerEmail'] ?? '').toString(),
      createdAt: (json['created_at'] ?? json['createdAt'] ?? '').toString(),
      deliveryAddress: (json['delivery_address'] ??
              json['deliveryAddress'] ??
              json['address'] ??
              '')
          .toString(),
      items: json['items'] is List ? json['items'] as List<dynamic> : [],
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}