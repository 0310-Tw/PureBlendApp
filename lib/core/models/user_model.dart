class UserModel {
  final int id;
  final String fullName;
  final String email;
  final String? phone;
  final String preferredFulfillment;
  final String? profileImageUrl;
  final bool isAdmin;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    required this.preferredFulfillment,
    this.profileImageUrl,
    required this.isAdmin,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: _parseInt(json['id']),
      fullName: (json['fullName'] ?? json['name'] ?? json['full_name'] ?? '')
          .toString(),
      email: (json['email'] ?? '').toString(),
      phone: json['phone']?.toString(),
      preferredFulfillment:
          (json['preferredFulfillment'] ??
                  json['preferred_fulfillment'] ??
                  'delivery')
              .toString(),
      profileImageUrl:
          (json['profileImageUrl'] ?? json['profile_image_url'])?.toString(),
      isAdmin: _parseBool(json['isAdmin'] ?? json['is_admin'] ?? false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'preferredFulfillment': preferredFulfillment,
      'profileImageUrl': profileImageUrl,
      'isAdmin': isAdmin,
    };
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;

    final str = value.toString().toLowerCase().trim();
    return str == 'true' || str == '1';
  }
}