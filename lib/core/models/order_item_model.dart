class OrderItemModel {
  final int id;
  final int smoothieId;
  final String smoothieName;
  final String sizeName;
  final int quantity;
  final double unitPrice;
  final double lineTotal;
  final String? notes;

  OrderItemModel({
    required this.id,
    required this.smoothieId,
    required this.smoothieName,
    required this.sizeName,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
    this.notes,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'],
      smoothieId: json['smoothie_id'],
      smoothieName: json['smoothie_name'] ?? '',
      sizeName: json['size_name'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: double.tryParse(json['unit_price'].toString()) ?? 0,
      lineTotal: double.tryParse(json['line_total'].toString()) ?? 0,
      notes: json['notes'],
    );
  }
}