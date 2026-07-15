import '../models/employee.dart';
import 'db_helper.dart';

class EmployeeDAO {
  static Future<int> insert({
    required String name,
    required double salary,
    required String username,
    required String password,
  }) async {
    final db = await DBHelper.instance.database;
    return db.insert('employees', {
      'name': name,
      'salary': salary,
      'username': username,
      'password': password,
      'active': 1,
    });
  }

  static Future<List<Employee>> getAll() async {
    final db = await DBHelper.instance.database;
    final rows = await db.query(
      'employees',
      columns: ['id', 'name', 'salary', 'username', 'password', 'active'],
      orderBy: 'id DESC',
    );
    return rows.map(Employee.fromMap).toList();
  }

  static Future<void> update({
    required int id,
    required String name,
    required double salary,
    required String username,
    required String password,
  }) async {
    final db = await DBHelper.instance.database;
    await db.update(
      'employees',
      {'name': name, 'salary': salary, 'username': username, 'password': password},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> setActive(int id, bool active) async {
    final db = await DBHelper.instance.database;
    await db.update(
      'employees',
      {'active': active ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> delete(int id) async {
    final db = await DBHelper.instance.database;
    await db.delete('employees', where: 'id = ?', whereArgs: [id]);
  }
}
