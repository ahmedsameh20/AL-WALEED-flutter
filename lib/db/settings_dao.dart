import 'db_helper.dart';

class SettingsDAO {
  static Future<void> resetSection(String section) async {
    final db = await DBHelper.instance.database;
    switch (section) {
      case 'الفواتير':
        await db.delete('orders');
        await db.delete('order_items');
        break;
      case 'الطلبات':
        await db.delete('order_items');
        break;
      case 'المنتجات':
        await db.delete('products');
        break;
      case 'المصروفات':
        await db.delete('expenses');
        break;
    }
  }
}
