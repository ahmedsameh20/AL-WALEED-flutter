import '../models/invoice_summary.dart';
import 'db_helper.dart';

class InvoiceDAO {
  static Future<List<InvoiceSummary>> getAll({required bool isOwner, required int employeeId}) async {
    final db = await DBHelper.instance.database;

    final where = isOwner ? '' : 'WHERE o.employee_id = ?';
    final args = isOwner ? <Object?>[] : <Object?>[employeeId];

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
        o.customer_name AS customer_name,
        o.customer_phone AS customer_phone,
        o.employee_name AS employee_name,
        COALESCE(o.note, '') AS note,
        strftime('%Y-%m-%d', o.date) AS order_date,
        strftime('%H:%M', o.date) AS order_time
      FROM orders o
      LEFT JOIN order_items oi ON o.id = oi.order_id
      LEFT JOIN products p ON oi.product_id = p.id
      $where
      GROUP BY o.id
      ORDER BY o.date DESC
    ''', args);

    return rows.map(InvoiceSummary.fromMap).toList();
  }

  static Future<void> updateNote(int id, String note) async {
    final db = await DBHelper.instance.database;
    await db.update('orders', {'note': note}, where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> delete(int id) async {
    final db = await DBHelper.instance.database;
    await db.transaction((txn) async {
      await txn.delete('order_items', where: 'order_id = ?', whereArgs: [id]);
      await txn.delete('orders', where: 'id = ?', whereArgs: [id]);
    });
  }

  static Future<List<Map<String, Object?>>> getItemLines(int id) async {
    final db = await DBHelper.instance.database;
    return db.rawQuery('''
      SELECT p.name, oi.quantity, oi.unit_price
      FROM order_items oi
      JOIN products p ON oi.product_id = p.id
      WHERE oi.order_id = ?
    ''', [id]);
  }
}
