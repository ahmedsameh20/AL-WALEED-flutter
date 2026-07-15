class InvoiceSummary {
  final int id;
  final String itemsSummary;
  final double subtotal;
  final double taxRate;
  final double taxAmount;
  final double total;
  final String customerName;
  final String phone;
  final String employeeName;
  final String note;
  final String date;
  final String time;

  const InvoiceSummary({
    required this.id,
    required this.itemsSummary,
    required this.subtotal,
    required this.taxRate,
    required this.taxAmount,
    required this.total,
    required this.customerName,
    required this.phone,
    required this.employeeName,
    required this.note,
    required this.date,
    required this.time,
  });

  factory InvoiceSummary.fromMap(Map<String, Object?> map) {
    return InvoiceSummary(
      id: map['id'] as int,
      itemsSummary: map['items_summary'] as String? ?? '',
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0,
      taxRate: (map['tax_rate'] as num?)?.toDouble() ?? 0,
      taxAmount: (map['tax_amount'] as num?)?.toDouble() ?? 0,
      total: (map['total_price'] as num?)?.toDouble() ?? 0,
      customerName: map['customer_name'] as String? ?? '',
      phone: map['customer_phone'] as String? ?? '',
      employeeName: map['employee_name'] as String? ?? '',
      note: map['note'] as String? ?? '',
      date: map['order_date'] as String? ?? '',
      time: map['order_time'] as String? ?? '',
    );
  }

  bool matches(String query) {
    final q = query.toLowerCase();
    return id.toString().contains(q) ||
        itemsSummary.toLowerCase().contains(q) ||
        customerName.toLowerCase().contains(q) ||
        phone.toLowerCase().contains(q) ||
        employeeName.toLowerCase().contains(q) ||
        note.toLowerCase().contains(q);
  }
}
