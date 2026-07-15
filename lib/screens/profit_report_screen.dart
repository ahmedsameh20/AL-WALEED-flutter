import 'package:flutter/material.dart';

import '../db/report_dao.dart';
import '../l10n/app_strings.dart';
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
      appBar: AppBar(title: Text(S.t('profit_report_title'))),
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
                    ? Center(child: Text(S.t('no_profit_data_yet')))
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
                                      Text('${S.t('quantity_label')}: ${row.totalQty.toStringAsFixed(2)}'),
                                      Text('${S.t('sell_total_label')}: ${row.totalSales.toStringAsFixed(2)}'),
                                      Text('${S.t('cost_total_label')}: ${row.totalCost.toStringAsFixed(2)}'),
                                      Text(
                                        '${S.t('profit_label')}: ${row.profit.toStringAsFixed(2)}',
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
                    Text(S.t('total_colon'), style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('${S.t('quantity_label')}: ${totalQty.toStringAsFixed(2)}'),
                    Text('${S.t('sell_total_label')}: ${totalSales.toStringAsFixed(2)}'),
                    Text('${S.t('cost_total_label')}: ${totalCost.toStringAsFixed(2)}'),
                    Text('${S.t('profit_label')}: ${totalProfit.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
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
