class PromoCode {
  final int id;
  final String code;
  final String type; // 'percentage' or 'fixed'
  final double value;
  final bool active;

  const PromoCode({
    required this.id,
    required this.code,
    required this.type,
    required this.value,
    required this.active,
  });

  bool get isPercentage => type == 'percentage';

  double discountFor(double subtotal) {
    final raw = isPercentage ? subtotal * value / 100 : value;
    return raw.clamp(0, subtotal);
  }

  factory PromoCode.fromMap(Map<String, Object?> map) {
    return PromoCode(
      id: map['id'] as int,
      code: map['code'] as String,
      type: map['type'] as String,
      value: (map['value'] as num).toDouble(),
      active: (map['active'] as int? ?? 1) == 1,
    );
  }
}
