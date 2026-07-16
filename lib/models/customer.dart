class Customer {
  final String phone;
  final String name;
  final int visitCount;
  final double totalSpent;
  final String lastVisit;

  const Customer({
    required this.phone,
    required this.name,
    required this.visitCount,
    required this.totalSpent,
    required this.lastVisit,
  });

  factory Customer.fromMap(Map<String, Object?> map) {
    return Customer(
      phone: map['customer_phone'] as String? ?? '',
      name: map['customer_name'] as String? ?? '',
      visitCount: map['visit_count'] as int? ?? 0,
      totalSpent: (map['total_spent'] as num?)?.toDouble() ?? 0,
      lastVisit: map['last_visit'] as String? ?? '',
    );
  }

  bool matches(String query) {
    final q = query.toLowerCase();
    return name.toLowerCase().contains(q) || phone.toLowerCase().contains(q);
  }
}
