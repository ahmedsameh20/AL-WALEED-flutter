import '../l10n/app_strings.dart';
import '../models/product.dart';
import '../utils/app_session.dart';
import 'db_helper.dart';

class ProductDAO {
  static Future<int> insert({
    required String name,
    required String type,
    required double buyPrice,
    required double sellPrice,
    required double quantity,
    String barcode = '',
  }) async {
    final db = await DBHelper.instance.database;
    final id = await db.insert('products', {
      'name': name,
      'type': type,
      'buy_price': buyPrice,
      'sell_price': sellPrice,
      'quantity': quantity,
      'initial_quantity': quantity,
      'barcode': barcode,
    });
    await DBHelper.instance.logAction(
      AppSession.instance.currentEmployeeId,
      '${S.t('log_added_product')} $name',
    );
    return id;
  }

  static Future<List<Product>> getAll() async {
    final db = await DBHelper.instance.database;
    final rows = await db.query('products', orderBy: 'id DESC');
    return rows.map(Product.fromMap).toList();
  }

  static Future<Product?> findByBarcode(String barcode) async {
    final db = await DBHelper.instance.database;
    final rows = await db.query(
      'products',
      where: 'barcode = ? AND barcode != \'\'',
      whereArgs: [barcode],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Product.fromMap(rows.first);
  }

  static Future<void> update({
    required int id,
    required String name,
    required String type,
    required double buyPrice,
    required double sellPrice,
    required double initialQuantity,
    required double quantity,
    String barcode = '',
  }) async {
    final db = await DBHelper.instance.database;
    await db.update(
      'products',
      {
        'name': name,
        'type': type,
        'buy_price': buyPrice,
        'sell_price': sellPrice,
        'initial_quantity': initialQuantity,
        'quantity': quantity,
        'barcode': barcode,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    await DBHelper.instance.logAction(
      AppSession.instance.currentEmployeeId,
      '${S.t('log_updated_product')} $name',
    );
  }

  static Future<void> delete(int id) async {
    final db = await DBHelper.instance.database;
    final rows = await db.query('products', columns: ['name'], where: 'id = ?', whereArgs: [id]);
    final name = rows.isNotEmpty ? rows.first['name'] as String : '#$id';
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
    await DBHelper.instance.logAction(
      AppSession.instance.currentEmployeeId,
      '${S.t('log_deleted_product')} $name',
    );
  }
}
