class CartItemModel {
  final int id;
  final int smoothieId;
  final String name;
  final String? imageUrl;
  final String sizeName;
  final int quantity;
  final double unitPrice;
  final double lineTotal;
  final String? notes;

  CartItemModel({
    required this.id,
    required this.smoothieId,
    required this.name,
    this.imageUrl,
    required this.sizeName,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
    this.notes,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'],
      smoothieId: json['smoothie_id'],
      name: json['name'] ?? '',
      imageUrl: json['image_url'],
      sizeName: json['size_name'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: double.tryParse(json['unit_price'].toString()) ?? 0,
      lineTotal: double.tryParse(json['line_total'].toString()) ?? 0,
      notes: json['notes'],
    );
  }
}