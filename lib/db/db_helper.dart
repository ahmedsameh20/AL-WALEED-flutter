import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../utils/password_hasher.dart';

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
      version: 5,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE employees (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            salary REAL NOT NULL DEFAULT 0,
            username TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL,
            salt TEXT NOT NULL,
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
            subtotal REAL DEFAULT 0,
            discount_code TEXT,
            discount_amount REAL DEFAULT 0,
            tax_rate REAL DEFAULT 0,
            tax_amount REAL DEFAULT 0,
            total_price REAL,
            payment_method TEXT DEFAULT 'cash',
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

        await db.execute('''
          CREATE TABLE promo_codes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            code TEXT UNIQUE NOT NULL,
            type TEXT NOT NULL,
            value REAL NOT NULL,
            active INTEGER DEFAULT 1,
            created_at TEXT DEFAULT (datetime('now'))
          );
        ''');

        await db.execute(
          'CREATE INDEX idx_orders_created_at ON orders(created_at);',
        );

        // Seed default owner accounts (matches setup.sql). Passwords are
        // salted + hashed, never stored in plain text.
        for (final seed in [
          {'name': 'Ahmed', 'username': 'ahmed'},
          {'name': 'Sameh', 'username': 'sameh'},
        ]) {
          final salt = PasswordHasher.generateSalt();
          await db.insert('employees', {
            'name': seed['name'],
            'salary': 10000,
            'username': seed['username'],
            'password': PasswordHasher.hash('1234', salt),
            'salt': salt,
            'active': 1,
            'role': 'owner',
          });
        }
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 5) {
          await db.execute("ALTER TABLE orders ADD COLUMN payment_method TEXT DEFAULT 'cash'");
        }
        if (oldVersion < 4) {
          await db.execute('ALTER TABLE orders ADD COLUMN discount_code TEXT');
          await db.execute('ALTER TABLE orders ADD COLUMN discount_amount REAL DEFAULT 0');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS promo_codes (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              code TEXT UNIQUE NOT NULL,
              type TEXT NOT NULL,
              value REAL NOT NULL,
              active INTEGER DEFAULT 1,
              created_at TEXT DEFAULT (datetime('now'))
            );
          ''');
        }
        if (oldVersion < 3) {
          await db.execute('ALTER TABLE orders ADD COLUMN subtotal REAL DEFAULT 0');
          await db.execute('ALTER TABLE orders ADD COLUMN tax_rate REAL DEFAULT 0');
          await db.execute('ALTER TABLE orders ADD COLUMN tax_amount REAL DEFAULT 0');
          // Pre-VAT orders had no tax: treat their existing total as the subtotal.
          await db.execute('UPDATE orders SET subtotal = total_price WHERE subtotal = 0');
        }
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE employees ADD COLUMN salt TEXT NOT NULL DEFAULT \'\'');
          // Migrate any existing plain-text passwords to salted hashes.
          final rows = await db.query('employees', columns: ['id', 'password']);
          for (final row in rows) {
            final salt = PasswordHasher.generateSalt();
            final hashed = PasswordHasher.hash(row['password'] as String, salt);
            await db.update(
              'employees',
              {'password': hashed, 'salt': salt},
              where: 'id = ?',
              whereArgs: [row['id']],
            );
          }
        }
      },
    );
  }

  Future<void> logAction(int employeeId, String action) async {
    final db = await database;
    await db.insert('logs', {'employee_id': employeeId, 'action': action});
  }
}
