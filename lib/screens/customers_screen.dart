import 'package:flutter/material.dart';

import '../db/customer_dao.dart';
import '../l10n/app_strings.dart';
import '../models/customer.dart';
import 'customer_history_screen.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final _searchController = TextEditingController();
  late final Future<List<Customer>> _customersFuture = CustomerDAO.getAll();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.t('customers_title'))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: S.t('search_customers_hint'),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Customer>>(
              future: _customersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final customers = (snapshot.data ?? [])
                    .where((c) => _query.isEmpty || c.matches(_query))
                    .toList();

                if (customers.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(S.t('no_customers_yet'), textAlign: TextAlign.center),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: customers.length,
                  itemBuilder: (context, index) {
                    final customer = customers[index];
                    final displayName = customer.name.isEmpty ? S.t('unnamed_customer') : customer.name;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => CustomerHistoryScreen(customer: customer)),
                        ),
                        title: Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          '${customer.phone}\n${S.t('visit_count_label')}: ${customer.visitCount}  ·  '
                          '${S.t('total_spent_label')}: ${customer.totalSpent.toStringAsFixed(2)} ${S.t('currency')}',
                        ),
                        isThreeLine: true,
                        trailing: const Icon(Icons.chevron_right),
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
