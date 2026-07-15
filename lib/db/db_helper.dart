import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  DBHelper._();
  static final DBHelper instance = DBHelper._();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'coffee.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE employees (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            salary REAL NOT NULL DEFAULT 0,
            username TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL,
            active INTEGER DEFAULT 1,
            invoices_count INTEGER DEFAULT 0,
            expenses_total REAL DEFAULT 0.0,
            role TEXT DEFAULT 'seller'
          );
        ''');

        await db.execute('''
          CREATE TABLE products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            sell_price REAL NOT NULL,
            buy_price REAL NOT NULL,
            quantity REAL,
            sold_quantity REAL DEFAULT 0,
            initial_quantity REAL DEFAULT 0,
            type TEXT
          );
        ''');

        await db.execute('''
          CREATE TABLE orders (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            employee_id INTEGER,
            employee_name TEXT NOT NULL,
            customer_name TEXT,
            customer_phone TEXT,
            total_price REAL,
            note TEXT,
            date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            created_at TEXT DEFAULT (datetime('now'))
          );
        ''');

        await db.execute('''
          CREATE TABLE order_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            employee_id INTEGER,
            order_id INTEGER NOT NULL,
            product_id INTEGER NOT NULL,
            quantity REAL NOT NULL,
            unit_price REAL NOT NULL,
            FOREIGN KEY (order_id) REFERENCES orders(id),
            FOREIGN KEY (product_id) REFERENCES products(id)
          );
        ''');

        await db.execute('''
          CREATE TABLE expenses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            employee_id INTEGER,
            note TEXT NOT NULL,
            amount REAL NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (employee_id) REFERENCES employees(id)
          );
        ''');

        await db.execute('''
          CREATE TABLE notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            sender_id INTEGER,
            receiver_id INTEGER,
            message TEXT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (sender_id) REFERENCES employees(id),
            FOREIGN KEY (receiver_id) REFERENCES employees(id)
          );
        ''');

        await db.execute('''
          CREATE TABLE logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            employee_id INTEGER,
            action TEXT NOT NULL,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (employee_id) REFERENCES employees(id)
          );
        ''');

        await db.execute(
          'CREATE INDEX idx_orders_created_at ON orders(created_at);',
        );

        // Seed default owner accounts (matches setup.sql)
        await db.insert('employees', {
          'name': 'Ahmed',
          'salary': 10000,
          'username': 'ahmed',
          'password': '1234',
          'active': 1,
          'role': 'owner',
        });
        await db.insert('employees', {
          'name': 'Sameh',
          'salary': 10000,
          'username': 'sameh',
          'password': '1234',
          'active': 1,
          'role': 'owner',
        });
      },
    );
  }

  Future<void> logAction(int employeeId, String action) async {
    final db = await database;
    await db.insert('logs', {'employee_id': employeeId, 'action': action});
  }
}
