import '../l10n/app_strings.dart';
import '../models/promo_code.dart';
import '../utils/app_session.dart';
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
      final normalized = code.trim().toUpperCase();
      await db.insert('promo_codes', {
        'code': normalized,
        'type': type,
        'value': value,
        'active': 1,
      });
      await DBHelper.instance.logAction(
        AppSession.instance.currentEmployeeId,
        '${S.t('log_added_promo')} $normalized',
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> setActive(int id, bool active) async {
    final db = await DBHelper.instance.database;
    final rows = await db.query('promo_codes', columns: ['code'], where: 'id = ?', whereArgs: [id]);
    final code = rows.isNotEmpty ? rows.first['code'] as String : '#$id';
    await db.update('promo_codes', {'active': active ? 1 : 0}, where: 'id = ?', whereArgs: [id]);
    await DBHelper.instance.logAction(
      AppSession.instance.currentEmployeeId,
      '${active ? S.t('log_activated_promo') : S.t('log_deactivated_promo')} $code',
    );
  }

  static Future<void> delete(int id) async {
    final db = await DBHelper.instance.database;
    final rows = await db.query('promo_codes', columns: ['code'], where: 'id = ?', whereArgs: [id]);
    final code = rows.isNotEmpty ? rows.first['code'] as String : '#$id';
    await db.delete('promo_codes', where: 'id = ?', whereArgs: [id]);
    await DBHelper.instance.logAction(
      AppSession.instance.currentEmployeeId,
      '${S.t('log_deleted_promo')} $code',
    );
  }
}
