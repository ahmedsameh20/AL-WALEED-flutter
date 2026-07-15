import 'package:fl_chart/fl_chart.dart';
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

  Widget _buildProfitChart(List<ProfitRow> rows) {
    final topRows = rows.take(6).toList();
    final maxAbs = topRows.fold<double>(1, (m, r) => r.profit.abs() > m ? r.profit.abs() : m);
    final chartMax = maxAbs * 1.2;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(S.t('profit_by_product_chart_title'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                minY: -chartMax,
                maxY: chartMax,
                gridData: const FlGridData(show: true, drawVerticalLine: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 44, getTitlesWidget: (value, meta) {
                      return Text(value.toStringAsFixed(0), style: const TextStyle(fontSize: 10));
                    }),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= topRows.length) return const SizedBox.shrink();
                        final name = topRows[index].productName;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            name.length > 8 ? '${name.substring(0, 8)}…' : name,
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < topRows.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: topRows[i].profit,
                          color: topRows[i].profit >= 0 ? Colors.green.shade600 : Colors.red.shade400,
                          width: 22,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
              if (rows.isNotEmpty) _buildProfitChart(rows),
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
