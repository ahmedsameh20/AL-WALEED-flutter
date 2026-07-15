import 'db_helper.dart';

class Employee {
  final int id;
  final String name;
  final String role;

  Employee({required this.id, required this.name, required this.role});
}

class UserDAO {
  static Future<Employee?> login(String username, String password) async {
    final db = await DBHelper.instance.database;
    final rows = await db.query(
      'employees',
      columns: ['id', 'name', 'role'],
      where: 'username = ? AND password = ? AND active = 1',
      whereArgs: [username.trim(), password.trim()],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    final row = rows.first;
    return Employee(
      id: row['id'] as int,
      name: row['name'] as String,
      role: row['role'] as String,
    );
  }
}
