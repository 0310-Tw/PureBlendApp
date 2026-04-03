class SmoothieSizeModel {
  final int? id;
  final String sizeName;
  final double price;

  SmoothieSizeModel({
    this.id,
    required this.sizeName,
    required this.price,
  });

  factory SmoothieSizeModel.fromJson(Map<String, dynamic> json) {
    return SmoothieSizeModel(
      id: _asInt(json['id']),
      sizeName: json['size_name']?.toString() ?? '',
      price: _asDouble(json['price']),
    );
  }
}

class SmoothieModel {
  final int id;
  final String name;
  final String? description;
  final String category;
  final String? imageUrl;
  final bool isFeatured;
  final double startingPrice;
  final double? smallPrice;
  final double? largePrice;
  final List<SmoothieSizeModel> sizes;

  SmoothieModel({
    required this.id,
    required this.name,
    this.description,
    required this.category,
    this.imageUrl,
    required this.isFeatured,
    required this.startingPrice,
    this.smallPrice,
    this.largePrice,
    this.sizes = const [],
  });

  factory SmoothieModel.fromJson(Map<String, dynamic> json) {
    final rawSizes = json['sizes'] as List<dynamic>? ?? [];

    final parsedId = _asInt(json['id']) ?? _asInt(json['smoothie_id']);

    if (parsedId == null) {
      throw Exception('Smoothie is missing a valid id. JSON: $json');
    }

    return SmoothieModel(
      id: parsedId,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      category: json['category']?.toString() ?? '',
      imageUrl: json['image_url']?.toString(),
      isFeatured: json['is_featured'] == 1 || json['is_featured'] == true,
      startingPrice: _asDouble(json['starting_price']),
      smallPrice: json['small_price'] == null ? null : _asDouble(json['small_price']),
      largePrice: json['large_price'] == null ? null : _asDouble(json['large_price']),
      sizes: rawSizes
          .whereType<Map<String, dynamic>>()
          .map((e) => SmoothieSizeModel.fromJson(e))
          .toList(),
    );
  }
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}

double _asDouble(dynamic value) {
  if (value == null) return 0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0;
}