class ServiceModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String icon;

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.icon,
  });

  factory ServiceModel.fromMap(String id, Map<String, dynamic> map) {
    return ServiceModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      icon: map['icon'] ?? 'build',
    );
  }
}
