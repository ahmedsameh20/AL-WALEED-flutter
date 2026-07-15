class Expense {
  final int id;
  final String employeeName;
  final double amount;
  final String note;
  final String createdAt;

  const Expense({
    required this.id,
    required this.employeeName,
    required this.amount,
    required this.note,
    required this.createdAt,
  });

  factory Expense.fromMap(Map<String, Object?> map) {
    return Expense(
      id: map['id'] as int,
      employeeName: map['employee_name'] as String? ?? '',
      amount: (map['amount'] as num).toDouble(),
      note: map['note'] as String? ?? '',
      createdAt: map['created_at'] as String? ?? '',
    );
  }
}
