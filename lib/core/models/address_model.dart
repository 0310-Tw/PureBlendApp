class AddressModel {
  final int id;
  final String label;
  final String? recipientName;
  final String? recipientPhone;
  final String streetAddress;
  final String town;
  final String parish;
  final String? deliveryNotes;
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.label,
    this.recipientName,
    this.recipientPhone,
    required this.streetAddress,
    required this.town,
    required this.parish,
    this.deliveryNotes,
    required this.isDefault,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'],
      label: json['label'] ?? '',
      recipientName: json['recipient_name'],
      recipientPhone: json['recipient_phone'],
      streetAddress: json['street_address'] ?? '',
      town: json['town'] ?? '',
      parish: json['parish'] ?? '',
      deliveryNotes: json['delivery_notes'],
      isDefault: json['is_default'] == 1 || json['is_default'] == true,
    );
  }
}