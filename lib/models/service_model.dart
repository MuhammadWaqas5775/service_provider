class ServiceModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String icon;
  final String phone;
  final String category;
  final String duration;

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.icon,
    this.phone = '',
    this.category = 'Other',
    this.duration = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'icon': icon,
      'phone': phone,
      'category': category,
      'duration': duration,
    };
  }

  factory ServiceModel.fromMap(String id, Map<String, dynamic> map) {
    return ServiceModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      icon: map['icon'] ?? 'build',
      phone: map['phone'] ?? '',
      category: map['category'] ?? 'Other',
      duration: map['duration'] ?? '',
    );
  }
}
