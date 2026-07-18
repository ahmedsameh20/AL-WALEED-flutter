import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../l10n/app_strings.dart';
import '../models/invoice_summary.dart';
import 'app_settings.dart';

/// Wraps print_bluetooth_thermal + esc_pos_utils_plus to connect to a
/// paired Bluetooth thermal printer and print a formatted receipt.
class PrinterService {
  PrinterService._();
  static final PrinterService instance = PrinterService._();

  Future<bool> get permissionGranted => PrintBluetoothThermal.isPermissionBluetoothGranted;

  Future<List<BluetoothInfo>> getPairedPrinters() => PrintBluetoothThermal.pairedBluetooths;

  Future<bool> get isConnected => PrintBluetoothThermal.connectionStatus;

  Future<bool> connect(String macAddress) =>
      PrintBluetoothThermal.connect(macPrinterAddress: macAddress);

  Future<void> disconnect() => PrintBluetoothThermal.disconnect;

  Future<bool> _ensureConnected() async {
    // Bounded: on hardware without Bluetooth these native calls can hang
    // indefinitely rather than returning false.
    final alreadyConnected = await isConnected.timeout(
      const Duration(seconds: 5),
      onTimeout: () => false,
    );
    if (alreadyConnected) return true;
    final mac = AppSettings.instance.printerMac;
    if (mac == null || mac.isEmpty) return false;
    return connect(mac).timeout(const Duration(seconds: 8), onTimeout: () => false);
  }

  Future<bool> printInvoice({
    required InvoiceSummary invoice,
    required List<Map<String, Object?>> items,
  }) async {
    if (!await _ensureConnected()) return false;

    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    final bytes = <int>[];

    bytes.addAll(generator.text(
      S.t('print_preview_shop'),
      styles: const PosStyles(align: PosAlign.center, bold: true, height: PosTextSize.size2, width: PosTextSize.size2),
    ));
    bytes.addAll(generator.hr());
    bytes.addAll(generator.text('${S.t('invoice_number_label')}: ${invoice.id}'));
    bytes.addAll(generator.text('${S.t('date_label')}: ${invoice.date}  ${S.t('time_label')}: ${invoice.time}'));
    if (invoice.customerName.isNotEmpty) {
      bytes.addAll(generator.text('${S.t('customer_name')}: ${invoice.customerName}'));
    }
    if (invoice.phone.isNotEmpty) {
      bytes.addAll(generator.text('${S.t('phone_label')}: ${invoice.phone}'));
    }
    bytes.addAll(generator.text('${S.t('employee_label')}: ${invoice.employeeName}'));
    bytes.addAll(generator.hr());

    for (final item in items) {
      final name = item['name'] as String? ?? '';
      final qty = (item['quantity'] as num?)?.toDouble() ?? 0;
      final unitPrice = (item['unit_price'] as num?)?.toDouble() ?? 0;
      final lineTotal = qty * unitPrice;
      bytes.addAll(generator.row([
        PosColumn(text: name, width: 6),
        PosColumn(text: '${qty.toStringAsFixed(0)} x ${unitPrice.toStringAsFixed(2)}', width: 3),
        PosColumn(text: lineTotal.toStringAsFixed(2), width: 3, styles: const PosStyles(align: PosAlign.right)),
      ]));
    }

    bytes.addAll(generator.hr());
    bytes.addAll(generator.text('${S.t('subtotal')}: ${invoice.subtotal.toStringAsFixed(2)} ${S.t('currency')}'));
    if (invoice.discountAmount > 0) {
      bytes.addAll(generator.text(
        '${S.t('discount_label')} (${invoice.discountCode}): -${invoice.discountAmount.toStringAsFixed(2)} ${S.t('currency')}',
      ));
    }
    bytes.addAll(generator.text(
      '${S.t('vat_label')} (${invoice.taxRate.toStringAsFixed(0)}%): ${invoice.taxAmount.toStringAsFixed(2)} ${S.t('currency')}',
    ));
    bytes.addAll(generator.text(
      '${S.t('total')}: ${invoice.total.toStringAsFixed(2)} ${S.t('currency')}',
      styles: const PosStyles(bold: true, height: PosTextSize.size2, width: PosTextSize.size2),
    ));
    bytes.addAll(generator.text('${S.t('payment_method_label')}: ${S.paymentMethod(invoice.paymentMethod)}'));
    if (invoice.note.isNotEmpty) {
      bytes.addAll(generator.text('${S.t('notes_label')}: ${invoice.note}'));
    }
    bytes.addAll(generator.feed(2));
    bytes.addAll(generator.cut());

    return PrintBluetoothThermal.writeBytes(bytes);
  }
}
