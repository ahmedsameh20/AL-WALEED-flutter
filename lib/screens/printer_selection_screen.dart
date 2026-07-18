import 'package:flutter/material.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../l10n/app_strings.dart';
import '../utils/app_settings.dart';
import '../utils/printer_service.dart';

class PrinterSelectionScreen extends StatefulWidget {
  const PrinterSelectionScreen({super.key});

  @override
  State<PrinterSelectionScreen> createState() => _PrinterSelectionScreenState();
}

class _PrinterSelectionScreenState extends State<PrinterSelectionScreen> {
  late Future<List<BluetoothInfo>> _devicesFuture;
  bool _connecting = false;

  @override
  void initState() {
    super.initState();
    _devicesFuture = _load();
  }

  /// Devices without Bluetooth hardware (e.g. most emulators) can leave the
  /// native permission/pairing calls hanging indefinitely, so each step is
  /// bounded rather than leaving the user staring at a spinner forever.
  Future<List<BluetoothInfo>> _load() async {
    await PrinterService.instance.permissionGranted.timeout(
      const Duration(seconds: 5),
      onTimeout: () => false,
    );
    return PrinterService.instance.getPairedPrinters().timeout(
      const Duration(seconds: 5),
      onTimeout: () => <BluetoothInfo>[],
    );
  }

  void _refresh() {
    setState(() => _devicesFuture = _load());
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _select(BluetoothInfo device) async {
    setState(() => _connecting = true);
    final connected = await PrinterService.instance.connect(device.macAdress).timeout(
      const Duration(seconds: 8),
      onTimeout: () => false,
    );
    if (!mounted) return;
    setState(() => _connecting = false);

    if (connected) {
      await AppSettings.instance.setPrinter(device.macAdress, device.name);
      if (!mounted) return;
      _showMessage(S.t('print_success'));
      Navigator.of(context).pop();
    } else {
      _showMessage(S.t('print_failed'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.t('select_printer_title')),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh)],
      ),
      body: Stack(
        children: [
          FutureBuilder<List<BluetoothInfo>>(
            future: _devicesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              final devices = snapshot.data ?? [];
              if (devices.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(S.t('no_paired_printers'), textAlign: TextAlign.center),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final device = devices[index];
                  final isSelected = device.macAdress == AppSettings.instance.printerMac;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(Icons.print, color: isSelected ? const Color(0xFF6D4C41) : null),
                      title: Text(device.name),
                      subtitle: Text(device.macAdress),
                      trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.green) : null,
                      onTap: _connecting ? null : () => _select(device),
                    ),
                  );
                },
              );
            },
          ),
          if (_connecting) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
