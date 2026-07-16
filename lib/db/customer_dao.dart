import '../models/customer.dart';
import '../models/invoice_summary.dart';
import 'db_helper.dart';

class CustomerDAO {
  /// Customers are derived from orders grouped by phone number, since a
  /// phone is the only reliable identifier a walk-in customer provides.
  /// Orders with no phone can't be attributed to a returning customer.
  static Future<List<Customer>> getAll() async {
    final db = await DBHelper.instance.database;
    final rows = await db.rawQuery('''
      SELECT
        customer_phone,
        (SELECT o2.customer_name FROM orders o2
         WHERE o2.customer_phone = orders.customer_phone AND o2.customer_name != ''
         ORDER BY o2.date DESC LIMIT 1) AS customer_name,
        COUNT(*) AS visit_count,
        SUM(total_price) AS total_spent,
        MAX(date) AS last_visit
      FROM orders
      WHERE customer_phone IS NOT NULL AND customer_phone != ''
      GROUP BY customer_phone
      ORDER BY last_visit DESC
    ''');
    return rows.map(Customer.fromMap).toList();
  }

  static Future<String?> findNameByPhone(String phone) async {
    final db = await DBHelper.instance.database;
    final rows = await db.query(
      'orders',
      columns: ['customer_name'],
      where: 'customer_phone = ? AND customer_name != \'\'',
      whereArgs: [phone],
      orderBy: 'date DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['customer_name'] as String?;
  }

  static Future<List<InvoiceSummary>> getHistory(String phone) async {
    final db = await DBHelper.instance.database;
    final rows = await db.rawQuery('''
      SELECT
        o.id AS id,
        GROUP_CONCAT(p.name || ' × ' || oi.quantity || ' × ' || oi.unit_price || ' = ' || (oi.quantity * oi.unit_price), ' - ') AS items_summary,
        o.subtotal AS subtotal,
        o.discount_code AS discount_code,
        o.discount_amount AS discount_amount,
        o.tax_rate AS tax_rate,
        o.tax_amount AS tax_amount,
        o.total_price AS total_price,
        o.payment_method AS payment_method,
        o.customer_name AS customer_name,
        o.customer_phone AS customer_phone,
        o.employee_name AS employee_name,
        COALESCE(o.note, '') AS note,
        strftime('%Y-%m-%d', o.date) AS order_date,
        strftime('%H:%M', o.date) AS order_time
      FROM orders o
      LEFT JOIN order_items oi ON o.id = oi.order_id
      LEFT JOIN products p ON oi.product_id = p.id
      WHERE o.customer_phone = ?
      GROUP BY o.id
      ORDER BY o.date DESC
    ''', [phone]);
    return rows.map(InvoiceSummary.fromMap).toList();
  }
}
