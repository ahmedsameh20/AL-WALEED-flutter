import '../models/product.dart';
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
    return db.insert('products', {
      'name': name,
      'type': type,
      'buy_price': buyPrice,
      'sell_price': sellPrice,
      'quantity': quantity,
      'initial_quantity': quantity,
      'barcode': barcode,
    });
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
  }

  static Future<void> delete(int id) async {
    final db = await DBHelper.instance.database;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }
}
