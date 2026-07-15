class Product {
  final int id;
  final String name;
  final String type;
  final double buyPrice;
  final double sellPrice;
  final double quantity;
  final double initialQuantity;

  const Product({
    required this.id,
    required this.name,
    required this.type,
    required this.buyPrice,
    required this.sellPrice,
    required this.quantity,
    required this.initialQuantity,
  });

  bool get isCups => type == 'أكواب';

  double get costValue => initialQuantity * buyPrice;
  double get remainingValue => quantity * buyPrice;
  double get soldValue => (initialQuantity - quantity) * buyPrice;

  factory Product.fromMap(Map<String, Object?> map) {
    return Product(
      id: map['id'] as int,
      name: map['name'] as String,
      type: map['type'] as String? ?? '',
      buyPrice: (map['buy_price'] as num).toDouble(),
      sellPrice: (map['sell_price'] as num).toDouble(),
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0,
      initialQuantity: (map['initial_quantity'] as num?)?.toDouble() ?? 0,
    );
  }
}
