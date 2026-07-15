import '../models/blend_component.dart';
import 'db_helper.dart';

class UsedComponent {
  final BlendComponent component;
  final double usedQty;

  const UsedComponent({required this.component, required this.usedQty});
}

class BlendService {
  static Future<List<BlendComponent>> getBeanProducts() async {
    final db = await DBHelper.instance.database;
    final rows = await db.query(
      'products',
      columns: ['id', 'name', 'quantity', 'buy_price', 'sell_price'],
      where: "type = ?",
      whereArgs: ['بن'],
    );
    return rows.map(BlendComponent.fromMap).toList();
  }

  /// Returns the internal order id on success, or -1 on failure
  /// (insufficient stock in any component).
  static Future<int> createBlend({
    required String name,
    required double multiplier,
    required List<UsedComponent> components,
    double? manualSellPrice,
    required int employeeId,
    required String employeeName,
  }) async {
    final db = await DBHelper.instance.database;

    double totalBuy = 0;
    double totalSell = 0;
    for (final c in components) {
      totalBuy += c.usedQty * c.component.buyPrice;
      totalSell += c.usedQty * c.component.sellPrice;
    }
    final avgBuy = totalBuy / multiplier;
    final avgSell = manualSellPrice ?? (totalSell / multiplier);

    try {
      return await db.transaction<int>((txn) async {
        for (final c in components) {
          final required = c.usedQty * multiplier;
          if (required > c.component.availableQty) {
            throw StateError('insufficient stock: ${c.component.name}');
          }
        }

        for (final c in components) {
          final required = c.usedQty * multiplier;
          if (required > 0) {
            await txn.rawUpdate(
              'UPDATE products SET quantity = quantity - ? WHERE id = ?',
              [required, c.component.id],
            );
          }
        }

        await txn.insert('products', {
          'name': name,
          'sell_price': avgSell,
          'buy_price': avgBuy,
          'quantity': multiplier,
          'sold_quantity': 0,
          'initial_quantity': multiplier,
          'type': 'توليفة',
        });

        final orderId = await txn.insert('orders', {
          'employee_id': employeeId,
          'employee_name': employeeName,
          'customer_name': 'توليفة داخلية',
          'customer_phone': '',
          'total_price': 0,
          'note': "تم إنشاء توليفة '$name' بكمية $multiplier كجم",
        });

        for (final c in components) {
          final used = c.usedQty * multiplier;
          if (used > 0) {
            await txn.insert('order_items', {
              'order_id': orderId,
              'product_id': c.component.id,
              'employee_id': employeeId,
              'quantity': used,
              'unit_price': c.component.buyPrice,
            });
          }
        }

        return orderId;
      });
    } catch (_) {
      return -1;
    }
  }
}
