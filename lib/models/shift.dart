class Shift {
  final int id;
  final int employeeId;
  final String employeeName;
  final DateTime clockIn;
  final DateTime? clockOut;

  const Shift({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.clockIn,
    this.clockOut,
  });

  bool get isActive => clockOut == null;

  Duration get duration => (clockOut ?? DateTime.now()).difference(clockIn);

  factory Shift.fromMap(Map<String, Object?> map) {
    return Shift(
      id: map['id'] as int,
      employeeId: map['employee_id'] as int,
      employeeName: map['employee_name'] as String? ?? '',
      clockIn: DateTime.parse(map['clock_in'] as String),
      clockOut: map['clock_out'] != null ? DateTime.parse(map['clock_out'] as String) : null,
    );
  }
}

class EmployeeShiftSummary {
  final String employeeName;
  final int shiftCount;
  final double totalHours;
  final bool isActive;

  const EmployeeShiftSummary({
    required this.employeeName,
    required this.shiftCount,
    required this.totalHours,
    required this.isActive,
  });
}
