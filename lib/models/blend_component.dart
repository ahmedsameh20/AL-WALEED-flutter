class BlendComponent {
  final int id;
  final String name;
  final double availableQty;
  final double buyPrice;
  final double sellPrice;

  const BlendComponent({
    required this.id,
    required this.name,
    required this.availableQty,
    required this.buyPrice,
    required this.sellPrice,
  });

  factory BlendComponent.fromMap(Map<String, Object?> map) {
    return BlendComponent(
      id: map['id'] as int,
      name: map['name'] as String,
      availableQty: (map['quantity'] as num?)?.toDouble() ?? 0,
      buyPrice: (map['buy_price'] as num).toDouble(),
      sellPrice: (map['sell_price'] as num).toDouble(),
    );
  }
}
