import '../l10n/app_strings.dart';
import '../models/expense.dart';
import '../utils/app_session.dart';
import 'db_helper.dart';

class ExpenseDAO {
  static Future<List<Expense>> getAll() async {
    final db = await DBHelper.instance.database;
    final rows = await db.rawQuery('''
      SELECT e.id, e.amount, e.note, e.created_at, emp.name AS employee_name
      FROM expenses e
      LEFT JOIN employees emp ON e.employee_id = emp.id
      ORDER BY e.created_at DESC
    ''');
    return rows.map(Expense.fromMap).toList();
  }

  static Future<int> insert({required int employeeId, required double amount, required String note}) async {
    final db = await DBHelper.instance.database;
    final id = await db.insert('expenses', {
      'employee_id': employeeId,
      'note': note.isEmpty ? 'بدون ملاحظة' : note,
      'amount': amount,
    });
    await DBHelper.instance.logAction(
      employeeId,
      '${S.t('log_added_expense')} (${amount.toStringAsFixed(2)})',
    );
    return id;
  }

  static Future<void> delete(int id) async {
    final db = await DBHelper.instance.database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
    await DBHelper.instance.logAction(
      AppSession.instance.currentEmployeeId,
      S.t('log_deleted_expense'),
    );
  }
}
