import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists app-wide financial/operational settings (VAT rate, low-stock
/// threshold) via shared_preferences, so they can change without a DB
/// migration.
class AppSettings extends ChangeNotifier {
  AppSettings._();
  static final AppSettings instance = AppSettings._();

  static const _vatRateKey = 'vat_rate';
  static const defaultVatRate = 14.0;

  static const _lowStockThresholdKey = 'low_stock_threshold';
  static const defaultLowStockThreshold = 5.0;

  double _vatRate = defaultVatRate;
  double get vatRate => _vatRate;

  double _lowStockThreshold = defaultLowStockThreshold;
  double get lowStockThreshold => _lowStockThreshold;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _vatRate = prefs.getDouble(_vatRateKey) ?? defaultVatRate;
    _lowStockThreshold = prefs.getDouble(_lowStockThresholdKey) ?? defaultLowStockThreshold;
    notifyListeners();
  }

  Future<void> setVatRate(double rate) async {
    _vatRate = rate;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_vatRateKey, rate);
  }

  Future<void> setLowStockThreshold(double threshold) async {
    _lowStockThreshold = threshold;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_lowStockThresholdKey, threshold);
  }
}
