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
      id: json['id'],
      sizeName: json['size_name'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0,
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

    return SmoothieModel(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      category: json['category'] ?? '',
      imageUrl: json['image_url'],
      isFeatured: json['is_featured'] == 1 || json['is_featured'] == true,
      startingPrice: double.tryParse(json['starting_price'].toString()) ?? 0,
      smallPrice: json['small_price'] == null
          ? null
          : double.tryParse(json['small_price'].toString()),
      largePrice: json['large_price'] == null
          ? null
          : double.tryParse(json['large_price'].toString()),
      sizes: rawSizes.map((e) => SmoothieSizeModel.fromJson(e)).toList(),
    );
  }
}