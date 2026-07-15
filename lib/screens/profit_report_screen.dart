import 'package:flutter/material.dart';

import '../db/report_dao.dart';
import '../models/report_rows.dart';

class ProfitReportScreen extends StatefulWidget {
  const ProfitReportScreen({super.key});

  @override
  State<ProfitReportScreen> createState() => _ProfitReportScreenState();
}

class _ProfitReportScreenState extends State<ProfitReportScreen> {
  late Future<List<ProfitRow>> _profitFuture;

  @override
  void initState() {
    super.initState();
    _profitFuture = ReportDAO.getProfitByProduct();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('💰 تقرير الأرباح حسب المنتج')),
      body: FutureBuilder<List<ProfitRow>>(
        future: _profitFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final rows = snapshot.data ?? [];

          double totalQty = 0, totalSales = 0, totalCost = 0, totalProfit = 0;
          for (final row in rows) {
            totalQty += row.totalQty;
            totalSales += row.totalSales;
            totalCost += row.totalCost;
            totalProfit += row.profit;
          }

          return Column(
            children: [
              Expanded(
                child: rows.isEmpty
                    ? const Center(child: Text('لا توجد بيانات أرباح بعد'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: rows.length,
                        itemBuilder: (context, index) {
                          final row = rows[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(row.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 16,
                                    runSpacing: 4,
                                    children: [
                                      Text('الكمية: ${row.totalQty.toStringAsFixed(2)}'),
                                      Text('البيع: ${row.totalSales.toStringAsFixed(2)}'),
                                      Text('التكلفة: ${row.totalCost.toStringAsFixed(2)}'),
                                      Text(
                                        'الربح: ${row.profit.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: row.profit >= 0 ? Colors.green.shade700 : Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                color: const Color(0xFFBBDEFB),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  children: [
                    const Text('📊 الإجمالي:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('الكمية: ${totalQty.toStringAsFixed(2)}'),
                    Text('البيع: ${totalSales.toStringAsFixed(2)}'),
                    Text('التكلفة: ${totalCost.toStringAsFixed(2)}'),
                    Text('الربح: ${totalProfit.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
