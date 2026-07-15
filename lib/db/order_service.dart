import '../models/order_item.dart';
import '../utils/app_settings.dart';
import 'db_helper.dart';

class OrderService {
  /// Returns the new order id, or -1 if stock was insufficient / the save failed.
  static Future<int> createOrder({
    required String customerName,
    required String phone,
    required int employeeId,
    required String employeeName,
    required List<OrderItem> items,
    String note = '',
    String? discountCode,
    double discountAmount = 0,
    String paymentMethod = 'cash',
  }) async {
    final db = await DBHelper.instance.database;
    final subtotal = items.fold<double>(0, (sum, item) => sum + item.totalPrice);
    final taxableAmount = subtotal - discountAmount;
    final taxRate = AppSettings.instance.vatRate;
    final taxAmount = taxableAmount * taxRate / 100;
    final total = taxableAmount + taxAmount;

    try {
      return await db.transaction<int>((txn) async {
        for (final item in items) {
          final rows = await txn.query(
            'products',
            columns: ['quantity'],
            where: 'id = ?',
            whereArgs: [item.productId],
          );
          if (rows.isNotEmpty) {
            final available = (rows.first['quantity'] as num?)?.toDouble() ?? 0;
            if (available < item.quantity) {
              throw StateError('insufficient stock: ${item.productName}');
            }
          }
        }

        final orderId = await txn.insert('orders', {
          'employee_id': employeeId,
          'employee_name': employeeName,
          'customer_name': customerName,
          'customer_phone': phone,
          'subtotal': subtotal,
          'discount_code': discountCode,
          'discount_amount': discountAmount,
          'tax_rate': taxRate,
          'tax_amount': taxAmount,
          'total_price': total,
          'payment_method': paymentMethod,
          'note': note,
        });

        for (final item in items) {
          await txn.insert('order_items', {
            'order_id': orderId,
            'product_id': item.productId,
            'employee_id': employeeId,
            'quantity': item.quantity,
            'unit_price': item.unitPrice,
          });

          await txn.rawUpdate(
            'UPDATE products SET quantity = quantity - ?, sold_quantity = sold_quantity + ? WHERE id = ?',
            [item.quantity, item.quantity, item.productId],
          );
        }

        return orderId;
      });
    } catch (_) {
      return -1;
    }
  }
}
