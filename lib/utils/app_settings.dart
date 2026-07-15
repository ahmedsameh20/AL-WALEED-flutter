import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists app-wide financial settings (currently just the VAT rate)
/// via shared_preferences, so it can change without a DB migration.
class AppSettings extends ChangeNotifier {
  AppSettings._();
  static final AppSettings instance = AppSettings._();

  static const _vatRateKey = 'vat_rate';
  static const defaultVatRate = 14.0;

  double _vatRate = defaultVatRate;
  double get vatRate => _vatRate;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _vatRate = prefs.getDouble(_vatRateKey) ?? defaultVatRate;
    notifyListeners();
  }

  Future<void> setVatRate(double rate) async {
    _vatRate = rate;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_vatRateKey, rate);
  }
}
