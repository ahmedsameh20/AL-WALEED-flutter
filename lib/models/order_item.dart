class OrderItem {
  final int productId;
  final String productName;
  final double unitPrice;
  double quantity;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
  });

  double get totalPrice => unitPrice * quantity;
}
