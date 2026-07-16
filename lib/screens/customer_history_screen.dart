import 'package:flutter/material.dart';

import '../db/customer_dao.dart';
import '../l10n/app_strings.dart';
import '../models/customer.dart';
import '../models/invoice_summary.dart';

class CustomerHistoryScreen extends StatefulWidget {
  final Customer customer;

  const CustomerHistoryScreen({super.key, required this.customer});

  @override
  State<CustomerHistoryScreen> createState() => _CustomerHistoryScreenState();
}

class _CustomerHistoryScreenState extends State<CustomerHistoryScreen> {
  late final Future<List<InvoiceSummary>> _historyFuture = CustomerDAO.getHistory(widget.customer.phone);

  @override
  Widget build(BuildContext context) {
    final customer = widget.customer;
    final displayName = customer.name.isEmpty ? S.t('unnamed_customer') : customer.name;

    return Scaffold(
      appBar: AppBar(title: Text(S.t('customer_history_title'))),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(displayName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(customer.phone, style: TextStyle(color: Colors.black.withValues(alpha: 0.6))),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 16,
                  runSpacing: 4,
                  children: [
                    Text('${S.t('visit_count_label')}: ${customer.visitCount}'),
                    Text('${S.t('total_spent_label')}: ${customer.totalSpent.toStringAsFixed(2)} ${S.t('currency')}'),
                    Text('${S.t('last_visit_label')}: ${customer.lastVisit.split(' ').first}'),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: FutureBuilder<List<InvoiceSummary>>(
              future: _historyFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final invoices = snapshot.data ?? [];
                if (invoices.isEmpty) {
                  return Center(child: Text(S.t('no_purchase_history')));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: invoices.length,
                  itemBuilder: (context, index) {
                    final invoice = invoices[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${S.t('invoice_hash')}${invoice.id}',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Text('${invoice.total.toStringAsFixed(2)} ${S.t('currency')}'),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text('${invoice.date} ${invoice.time}', style: const TextStyle(color: Colors.grey)),
                                const SizedBox(width: 8),
                                Chip(
                                  label: Text(S.paymentMethod(invoice.paymentMethod), style: const TextStyle(fontSize: 11)),
                                  visualDensity: VisualDensity.compact,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(invoice.itemsSummary),
                            Text('${S.t('employee_label')}: ${invoice.employeeName}'),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
