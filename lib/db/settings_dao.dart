import 'db_helper.dart';

class SettingsDAO {
  static Future<void> resetSection(String section) async {
    final db = await DBHelper.instance.database;
    switch (section) {
      case 'invoices':
        await db.delete('orders');
        await db.delete('order_items');
        break;
      case 'orders':
        await db.delete('order_items');
        break;
      case 'products':
        await db.delete('products');
        break;
      case 'expenses':
        await db.delete('expenses');
        break;
    }
  }
}
