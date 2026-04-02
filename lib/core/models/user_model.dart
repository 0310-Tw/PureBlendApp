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
      id: json['id'],
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      preferredFulfillment: json['preferred_fulfillment'] ?? 'delivery',
      profileImageUrl: json['profile_image_url'],
      isAdmin: json['is_admin'] == 1 || json['is_admin'] == true,
    );
  }
}