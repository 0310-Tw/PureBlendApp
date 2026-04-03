class AdminSmoothieModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final bool isAvailable;
  final String category;

  AdminSmoothieModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.isAvailable,
    required this.category,
  });

  factory AdminSmoothieModel.fromJson(Map<String, dynamic> json) {
    return AdminSmoothieModel(
      id: _parseInt(json['id']),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      price: _parseDouble(json['price']),
      imageUrl: (json['image_url'] ?? json['imageUrl'] ?? '').toString(),
      isAvailable: _parseBool(
        json['is_available'] ?? json['isAvailable'] ?? true,
      ),
      category: (json['category'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, // ✅ added
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'is_available': isAvailable,
      'category': category,
    };
  }

  AdminSmoothieModel copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    bool? isAvailable,
    String? category,
  }) {
    return AdminSmoothieModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      category: category ?? this.category,
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;

    final str = value.toString().toLowerCase();
    return str == 'true' || str == '1' || str == 'yes';
  }
}