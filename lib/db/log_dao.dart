import '../models/log_entry.dart';
import 'db_helper.dart';

class LogDAO {
  static Future<List<LogEntry>> getAll() async {
    final db = await DBHelper.instance.database;
    final rows = await db.rawQuery('''
      SELECT logs.action, logs.timestamp, employees.name
      FROM logs
      JOIN employees ON logs.employee_id = employees.id
      ORDER BY logs.timestamp DESC
    ''');
    return rows.map(LogEntry.fromMap).toList();
  }
}
