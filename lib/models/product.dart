class Product {
  final int? id;
  final String name;
  final String category;
  final List<WeightPrice> weightPrices;
  final ProductType type; // New field for product type

  Product({
    this.id,
    required this.name,
    required this.category,
    required this.weightPrices,
    required this.type,
  });

// Factory method to create a Product from Firebase JSON data
  factory Product.fromJson(Map<dynamic, dynamic> json) {
    return Product(
      id: null,
      name: json['name'] ?? 'Unknown',
      category: json['category'] ?? 'Uncategorized',
      type: _parseProductType(json['type']),
      weightPrices: (json['weightPrices'] as List<dynamic>?)
              ?.map((wp) => WeightPrice.fromJson(wp))
              .toList() ??
          [],
    );
  }
  // Helper method to parse ProductType
  static ProductType _parseProductType(String? type) {
    return ProductType.values.firstWhere(
      (e) => e.toString().split('.').last == type,
      orElse: () => ProductType.weight,
    );
  }

  // Example for converting ProductType to/from string (if needed for Firebase)
  String get typeAsString => type.toString().split('.').last;
  static ProductType parseType(String type) => ProductType.values
      .firstWhere((e) => e.toString().split('.').last == type);
}

final List<String> categories = [
  'All',
  'Fruits',
  'Vegetables',
  'Dairy',
  'Grains'
];

enum ProductType {
  weight,
  pocket,
  single,
}

class WeightPrice {
  final double weight;
  final double price;

  WeightPrice({required this.weight, required this.price});
  // Factory method to create a WeightPrice from Firebase JSON data
  factory WeightPrice.fromJson(Map<dynamic, dynamic> json) {
    return WeightPrice(
      weight: (json['weight'] ?? 0).toDouble(),
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}
