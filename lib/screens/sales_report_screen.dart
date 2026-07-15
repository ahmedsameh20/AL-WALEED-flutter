import 'package:flutter/material.dart';

import '../db/report_dao.dart';
import '../models/report_rows.dart';

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  static const _periods = ['آخر ساعة', 'اليوم', 'آخر 7 أيام', 'آخر 30 يوم', 'آخر سنة'];

  String _period = 'اليوم';
  late Future<List<EmployeeSales>> _salesFuture;

  @override
  void initState() {
    super.initState();
    _salesFuture = _load();
  }

  DateTime _since() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (_period) {
      case 'آخر ساعة':
        return now.subtract(const Duration(hours: 1));
      case 'آخر 7 أيام':
        return today.subtract(const Duration(days: 7));
      case 'آخر 30 يوم':
        return today.subtract(const Duration(days: 30));
      case 'آخر سنة':
        return DateTime(now.year - 1, now.month, now.day);
      case 'اليوم':
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
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('📦 الكميات المباعة حسب المنتج', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: quantities.isEmpty
                      ? const Center(child: Text('لا توجد بيانات'))
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
      appBar: AppBar(title: const Text('📈 تقرير المبيعات حسب الموظف')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              value: _period,
              decoration: const InputDecoration(labelText: 'الفترة', border: OutlineInputBorder()),
              items: _periods.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
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
                  return const Center(child: Text('لا توجد مبيعات في هذه الفترة'));
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
                        subtitle: Text('عدد الفواتير: ${row.invoiceCount}'),
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
                label: const Text('📊 عرض الكميات المباعة'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
