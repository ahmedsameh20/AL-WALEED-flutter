import 'package:fl_chart/fl_chart.dart';
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

  static const _trendDays = 7;

  String _period = 'today';
  late Future<List<EmployeeSales>> _salesFuture;
  late final Future<List<DailySales>> _trendFuture = ReportDAO.getDailySalesTrend(_trendDays);

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

  Widget _buildTrendChart(List<DailySales> data) {
    final maxY = data.fold<double>(0, (m, d) => d.totalSales > m ? d.totalSales : m);
    final safeMaxY = maxY <= 0 ? 1.0 : maxY * 1.2;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${S.t('sales_trend_title')} ($_trendDays ${S.t('days_label')})',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: safeMaxY,
                gridData: const FlGridData(show: true, drawVerticalLine: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (value, meta) {
                      return Text(value.toStringAsFixed(0), style: const TextStyle(fontSize: 10));
                    }),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= data.length) return const SizedBox.shrink();
                        final parts = data[index].date.split('-');
                        final label = parts.length == 3 ? '${parts[1]}/${parts[2]}' : '';
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(label, style: const TextStyle(fontSize: 10)),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      for (var i = 0; i < data.length; i++) FlSpot(i.toDouble(), data[i].totalSales),
                    ],
                    isCurved: true,
                    color: const Color(0xFF6D4C41),
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(show: true, color: const Color(0x336D4C41)),
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
      appBar: AppBar(title: Text(S.t('sales_report_title'))),
      body: Column(
        children: [
          FutureBuilder<List<DailySales>>(
            future: _trendFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done || !snapshot.hasData) {
                return const SizedBox(height: 180);
              }
              return _buildTrendChart(snapshot.data!);
            },
          ),
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
