class Product {
  final int? id;
  final String name;
  final String category;
  final List<WeightPrice> weightPrices;

  Product({
    this.id,
    required this.name,
    required this.category,
    required this.weightPrices,
  });
}

class WeightPrice {
  final double weight;
  final double price;

  WeightPrice({required this.weight, required this.price});
}
