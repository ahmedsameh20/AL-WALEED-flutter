import '../models/report_rows.dart';
import 'db_helper.dart';

class ReportDAO {
  static Future<List<EmployeeSales>> getSalesByEmployee(DateTime since) async {
    final db = await DBHelper.instance.database;
    final sinceStr = _format(since);
    final rows = await db.rawQuery('''
      SELECT employee_name,
             COUNT(DISTINCT orders.id) AS invoice_count,
             SUM(order_items.quantity * order_items.unit_price) AS total_sales
      FROM orders
      JOIN order_items ON orders.id = order_items.order_id
      WHERE orders.created_at >= ?
      GROUP BY employee_name
    ''', [sinceStr]);
    return rows.map(EmployeeSales.fromMap).toList();
  }

  static Future<List<ProductQuantity>> getProductQuantities() async {
    final db = await DBHelper.instance.database;
    final rows = await db.rawQuery('''
      SELECT p.name, SUM(oi.quantity) AS total_qty
      FROM order_items oi
      JOIN products p ON oi.product_id = p.id
      GROUP BY p.name
      ORDER BY total_qty DESC
    ''');
    return rows.map(ProductQuantity.fromMap).toList();
  }

  static Future<List<ProfitRow>> getProfitByProduct() async {
    final db = await DBHelper.instance.database;
    final rows = await db.rawQuery('''
      SELECT
        p.name AS product_name,
        SUM(oi.quantity) AS total_qty,
        SUM(oi.quantity * oi.unit_price) AS total_sales,
        SUM(oi.quantity * p.buy_price) AS total_cost,
        SUM(oi.quantity * oi.unit_price) - SUM(oi.quantity * p.buy_price) AS profit
      FROM order_items oi
      JOIN products p ON oi.product_id = p.id
      GROUP BY p.name
      ORDER BY profit DESC
    ''');
    return rows.map(ProfitRow.fromMap).toList();
  }

  static String _format(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}-${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}:${two(dt.second)}';
  }
}
