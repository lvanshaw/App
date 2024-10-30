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

  // Example for converting ProductType to/from string (if needed for Firebase)
  String get typeAsString => type.toString().split('.').last;
  static ProductType parseType(String type) => ProductType.values
      .firstWhere((e) => e.toString().split('.').last == type);
}

final List<String> categories = ['All','Fruits', 'Vegetables', 'Dairy', 'Grains'];

enum ProductType {
  weight,
  pocket,
  single,
}

class WeightPrice {
  final double weight;
  final double price;

  WeightPrice({required this.weight, required this.price});
}
