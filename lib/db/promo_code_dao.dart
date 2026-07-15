import '../models/promo_code.dart';
import 'db_helper.dart';

class PromoCodeDAO {
  static Future<List<PromoCode>> getAll() async {
    final db = await DBHelper.instance.database;
    final rows = await db.query('promo_codes', orderBy: 'id DESC');
    return rows.map(PromoCode.fromMap).toList();
  }

  /// Returns the active promo code matching [code] (case-insensitive), or null.
  static Future<PromoCode?> findActive(String code) async {
    final db = await DBHelper.instance.database;
    final rows = await db.query(
      'promo_codes',
      where: 'UPPER(code) = ? AND active = 1',
      whereArgs: [code.trim().toUpperCase()],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return PromoCode.fromMap(rows.first);
  }

  static Future<bool> insert({
    required String code,
    required String type,
    required double value,
  }) async {
    final db = await DBHelper.instance.database;
    try {
      await db.insert('promo_codes', {
        'code': code.trim().toUpperCase(),
        'type': type,
        'value': value,
        'active': 1,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> setActive(int id, bool active) async {
    final db = await DBHelper.instance.database;
    await db.update('promo_codes', {'active': active ? 1 : 0}, where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> delete(int id) async {
    final db = await DBHelper.instance.database;
    await db.delete('promo_codes', where: 'id = ?', whereArgs: [id]);
  }
}
