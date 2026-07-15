import 'package:flutter/material.dart';

import '../db/report_dao.dart';
import '../l10n/app_strings.dart';
import '../models/report_rows.dart';

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  static const _periodKeys = ['hour', 'today', 'week', 'month', 'year'];

  String _period = 'today';
  late Future<List<EmployeeSales>> _salesFuture;

  @override
  void initState() {
    super.initState();
    _salesFuture = _load();
  }

  String _periodLabel(String key) => S.t('period_$key');

  DateTime _since() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (_period) {
      case 'hour':
        return now.subtract(const Duration(hours: 1));
      case 'week':
        return today.subtract(const Duration(days: 7));
      case 'month':
        return today.subtract(const Duration(days: 30));
      case 'year':
        return DateTime(now.year - 1, now.month, now.day);
      case 'today':
      default:
        return today;
    }
  }

  Future<List<EmployeeSales>> _load() => ReportDAO.getSalesByEmployee(_since());

  void _refresh() {
    setState(() => _salesFuture = _load());
  }

  Future<void> _showProductQuantities() async {
    final quantities = await ReportDAO.getProductQuantities();
    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(S.t('quantities_by_product'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: quantities.isEmpty
                      ? Center(child: Text(S.t('no_data')))
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: quantities.length,
                          itemBuilder: (context, index) {
                            final row = quantities[index];
                            return ListTile(
                              title: Text(row.productName),
                              trailing: Text(row.quantity.toStringAsFixed(2)),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.t('sales_report_title'))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              value: _period,
              decoration: InputDecoration(labelText: S.t('period'), border: const OutlineInputBorder()),
              items: _periodKeys.map((k) => DropdownMenuItem(value: k, child: Text(_periodLabel(k)))).toList(),
              onChanged: (value) {
                setState(() => _period = value ?? _period);
                _refresh();
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<EmployeeSales>>(
              future: _salesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final sales = snapshot.data ?? [];
                if (sales.isEmpty) {
                  return Center(child: Text(S.t('no_sales_in_period')));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: sales.length,
                  itemBuilder: (context, index) {
                    final row = sales[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(row.employeeName),
                        subtitle: Text('${S.t('invoice_count_label')}: ${row.invoiceCount}'),
                        trailing: Text(
                          row.totalSales.toStringAsFixed(2),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _showProductQuantities,
                icon: const Icon(Icons.bar_chart),
                label: Text(S.t('show_quantities_sold')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
