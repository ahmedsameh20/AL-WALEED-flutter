import '../l10n/app_strings.dart';
import '../models/employee.dart';
import '../utils/app_session.dart';
import '../utils/password_hasher.dart';
import 'db_helper.dart';

class EmployeeDAO {
  static Future<int> insert({
    required String name,
    required double salary,
    required String username,
    required String password,
  }) async {
    final db = await DBHelper.instance.database;
    final salt = PasswordHasher.generateSalt();
    final id = await db.insert('employees', {
      'name': name,
      'salary': salary,
      'username': username,
      'password': PasswordHasher.hash(password, salt),
      'salt': salt,
      'active': 1,
    });
    await DBHelper.instance.logAction(
      AppSession.instance.currentEmployeeId,
      '${S.t('log_added_employee')} $name',
    );
    return id;
  }

  static Future<List<Employee>> getAll() async {
    final db = await DBHelper.instance.database;
    final rows = await db.query(
      'employees',
      columns: ['id', 'name', 'salary', 'username', 'active'],
      orderBy: 'id DESC',
    );
    return rows.map(Employee.fromMap).toList();
  }

  /// [password] is optional — pass null or empty to leave the employee's
  /// existing password unchanged.
  static Future<void> update({
    required int id,
    required String name,
    required double salary,
    required String username,
    String? password,
  }) async {
    final db = await DBHelper.instance.database;
    final values = <String, Object?>{
      'name': name,
      'salary': salary,
      'username': username,
    };

    if (password != null && password.isNotEmpty) {
      final salt = PasswordHasher.generateSalt();
      values['password'] = PasswordHasher.hash(password, salt);
      values['salt'] = salt;
    }

    await db.update('employees', values, where: 'id = ?', whereArgs: [id]);
    await DBHelper.instance.logAction(
      AppSession.instance.currentEmployeeId,
      '${S.t('log_updated_employee')} $name',
    );
  }

  static Future<void> setActive(int id, bool active) async {
    final db = await DBHelper.instance.database;
    final rows = await db.query('employees', columns: ['name'], where: 'id = ?', whereArgs: [id]);
    final name = rows.isNotEmpty ? rows.first['name'] as String : '#$id';
    await db.update(
      'employees',
      {'active': active ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
    await DBHelper.instance.logAction(
      AppSession.instance.currentEmployeeId,
      '${active ? S.t('log_activated_employee') : S.t('log_deactivated_employee')} $name',
    );
  }

  static Future<void> delete(int id) async {
    final db = await DBHelper.instance.database;
    final rows = await db.query('employees', columns: ['name'], where: 'id = ?', whereArgs: [id]);
    final name = rows.isNotEmpty ? rows.first['name'] as String : '#$id';
    await db.delete('employees', where: 'id = ?', whereArgs: [id]);
    await DBHelper.instance.logAction(
      AppSession.instance.currentEmployeeId,
      '${S.t('log_deleted_employee')} $name',
    );
  }
}
