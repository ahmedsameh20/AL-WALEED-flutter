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

  static const _printerMacKey = 'printer_mac';
  static const _printerNameKey = 'printer_name';

  double _vatRate = defaultVatRate;
  double get vatRate => _vatRate;

  double _lowStockThreshold = defaultLowStockThreshold;
  double get lowStockThreshold => _lowStockThreshold;

  String? _printerMac;
  String? get printerMac => _printerMac;

  String? _printerName;
  String? get printerName => _printerName;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _vatRate = prefs.getDouble(_vatRateKey) ?? defaultVatRate;
    _lowStockThreshold = prefs.getDouble(_lowStockThresholdKey) ?? defaultLowStockThreshold;
    _printerMac = prefs.getString(_printerMacKey);
    _printerName = prefs.getString(_printerNameKey);
    notifyListeners();
  }

  Future<void> setPrinter(String mac, String name) async {
    _printerMac = mac;
    _printerName = name;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_printerMacKey, mac);
    await prefs.setString(_printerNameKey, name);
  }

  Future<void> clearPrinter() async {
    _printerMac = null;
    _printerName = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_printerMacKey);
    await prefs.remove(_printerNameKey);
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
