import '../models/shift.dart';
import 'db_helper.dart';

class ShiftDAO {
  static Future<Shift?> getActiveShift(int employeeId) async {
    final db = await DBHelper.instance.database;
    final rows = await db.query(
      'shifts',
      where: 'employee_id = ? AND clock_out IS NULL',
      whereArgs: [employeeId],
      orderBy: 'clock_in DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Shift.fromMap(rows.first);
  }

  static Future<void> clockIn(int employeeId, String employeeName) async {
    final db = await DBHelper.instance.database;
    await db.insert('shifts', {
      'employee_id': employeeId,
      'employee_name': employeeName,
      'clock_in': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> clockOut(int shiftId) async {
    final db = await DBHelper.instance.database;
    await db.update(
      'shifts',
      {'clock_out': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [shiftId],
    );
  }

  static Future<List<Shift>> getHistory(int employeeId) async {
    final db = await DBHelper.instance.database;
    final rows = await db.query(
      'shifts',
      where: 'employee_id = ?',
      whereArgs: [employeeId],
      orderBy: 'clock_in DESC',
      limit: 30,
    );
    return rows.map(Shift.fromMap).toList();
  }

  /// All-time per-employee totals, for the owner's overview.
  static Future<List<EmployeeShiftSummary>> getAllSummaries() async {
    final db = await DBHelper.instance.database;
    final rows = await db.query('shifts', orderBy: 'clock_in DESC');
    final shifts = rows.map(Shift.fromMap).toList();

    final byEmployee = <String, List<Shift>>{};
    for (final shift in shifts) {
      byEmployee.putIfAbsent(shift.employeeName, () => []).add(shift);
    }

    return byEmployee.entries.map((entry) {
      final employeeShifts = entry.value;
      final totalHours = employeeShifts.fold<double>(
        0,
        (sum, s) => sum + (s.isActive ? 0 : s.duration.inMinutes / 60),
      );
      return EmployeeShiftSummary(
        employeeName: entry.key,
        shiftCount: employeeShifts.length,
        totalHours: totalHours,
        isActive: employeeShifts.any((s) => s.isActive),
      );
    }).toList()
      ..sort((a, b) => b.totalHours.compareTo(a.totalHours));
  }
}
