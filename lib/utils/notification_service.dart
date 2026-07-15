import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Thin wrapper around flutter_local_notifications, used for low-stock
/// alerts fired right after an order depletes a product's quantity.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // Guarded: in a test environment (or a platform without notification
    // support) the plugin's platform channel isn't available.
    try {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const settings = InitializationSettings(android: androidSettings);
      await _plugin.initialize(settings);

      await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } catch (_) {
      // Notifications are a non-critical enhancement; ignore setup failures.
    }
  }

  Future<void> showLowStock(int productId, String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'low_stock_channel',
      'Low Stock Alerts',
      channelDescription: 'Notifies when a product quantity drops to or below its threshold',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);
    try {
      await _plugin.show(1000 + productId, title, body, details);
    } catch (_) {
      // Non-critical: don't let a notification failure break order flow.
    }
  }
}
