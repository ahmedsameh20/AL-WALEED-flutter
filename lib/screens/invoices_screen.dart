import 'package:flutter/material.dart';

import '../db/invoice_dao.dart';
import '../l10n/app_strings.dart';
import '../models/invoice_summary.dart';
import '../utils/app_session.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  final _searchController = TextEditingController();
  late Future<List<InvoiceSummary>> _invoicesFuture;
  String _query = '';

  bool get _isOwner => AppSession.instance.isOwner;

  @override
  void initState() {
    super.initState();
    _invoicesFuture = _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<InvoiceSummary>> _load() {
    return InvoiceDAO.getAll(
      isOwner: _isOwner,
      employeeId: AppSession.instance.currentEmployeeId,
    );
  }

  void _refresh() {
    setState(() => _invoicesFuture = _load());
  }

  Future<void> _editNote(InvoiceSummary invoice) async {
    final controller = TextEditingController(text: invoice.note);
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(S.t('edit_note')),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: S.t('write_note_hint')),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: Text(S.t('cancel'))),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: Text(S.t('save')),
          ),
        ],
      ),
    );

    if (result != null) {
      await InvoiceDAO.updateNote(invoice.id, result);
      _refresh();
    }
  }

  Future<void> _confirmDelete(InvoiceSummary invoice) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(S.t('confirm_delete')),
        content: Text('${S.t('confirm_delete_invoice_prefix')}${invoice.id}?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(S.t('no'))),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(S.t('yes'), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await InvoiceDAO.delete(invoice.id);
      _refresh();
    }
  }

  Future<void> _showPrintPreview(InvoiceSummary invoice) async {
    final items = await InvoiceDAO.getItemLines(invoice.id);

    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(S.t('print_preview_shop'), style: const TextStyle(fontFamily: 'monospace', fontSize: 15)),
                  const Text('-------------------------------', style: TextStyle(fontFamily: 'monospace')),
                  Text('${S.t('invoice_number_label')}: ${invoice.id}', style: const TextStyle(fontFamily: 'monospace')),
                  Text(
                    '${S.t('date_label')}: ${invoice.date}   ${S.t('time_label')}: ${invoice.time}',
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                  Text('${S.t('customer_name')}: ${invoice.customerName}', style: const TextStyle(fontFamily: 'monospace')),
                  Text('${S.t('phone_label')}: ${invoice.phone}', style: const TextStyle(fontFamily: 'monospace')),
                  Text('${S.t('employee_label')}: ${invoice.employeeName}', style: const TextStyle(fontFamily: 'monospace')),
                  const SizedBox(height: 8),
                  Text('${S.t('products_label')}:', style: const TextStyle(fontFamily: 'monospace')),
                  for (final item in items)
                    Text(
                      '- ${item['name']} × ${item['quantity']} × ${item['unit_price']} = ${(item['quantity'] as num) * (item['unit_price'] as num)}',
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  const SizedBox(height: 8),
                  const Text('-------------------------------', style: TextStyle(fontFamily: 'monospace')),
                  Text('${S.t('subtotal')}: ${invoice.subtotal.toStringAsFixed(2)} ${S.t('currency')}', style: const TextStyle(fontFamily: 'monospace')),
                  Text(
                    '${S.t('vat_label')} (${invoice.taxRate.toStringAsFixed(0)}%): ${invoice.taxAmount.toStringAsFixed(2)} ${S.t('currency')}',
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                  Text('${S.t('total')}: ${invoice.total.toStringAsFixed(2)} ${S.t('currency')}', style: const TextStyle(fontFamily: 'monospace')),
                  Text('${S.t('notes_label')}: ${invoice.note}', style: const TextStyle(fontFamily: 'monospace')),
                  const SizedBox(height: 20),
                  Text(
                    S.t('no_mobile_print'),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.t('invoices_title'))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: S.t('search_invoices_hint'),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<InvoiceSummary>>(
              future: _invoicesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final invoices = (snapshot.data ?? [])
                    .where((invoice) => _query.isEmpty || invoice.matches(_query))
                    .toList();

                if (invoices.isEmpty) {
                  return Center(child: Text(S.t('no_invoices')));
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
                            Text('${invoice.date} ${invoice.time}', style: const TextStyle(color: Colors.grey)),
                            const SizedBox(height: 6),
                            Text(invoice.itemsSummary),
                            if (invoice.taxAmount > 0) ...[
                              const SizedBox(height: 4),
                              Text(
                                '${S.t('subtotal')}: ${invoice.subtotal.toStringAsFixed(2)}   '
                                '${S.t('vat_label')} (${invoice.taxRate.toStringAsFixed(0)}%): ${invoice.taxAmount.toStringAsFixed(2)}',
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                            const SizedBox(height: 6),
                            Text('${S.t('customer_label')}: ${invoice.customerName}  ${S.t('phone_label')}: ${invoice.phone}'),
                            Text('${S.t('employee_label')}: ${invoice.employeeName}'),
                            if (invoice.note.isNotEmpty) Text('${S.t('note_label')}: ${invoice.note}'),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: () => _editNote(invoice),
                                  icon: const Icon(Icons.edit_note, size: 18),
                                  label: Text(S.t('note_button')),
                                ),
                                TextButton.icon(
                                  onPressed: () => _showPrintPreview(invoice),
                                  icon: const Icon(Icons.print, size: 18),
                                  label: Text(S.t('print_button')),
                                ),
                                if (_isOwner)
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _confirmDelete(invoice),
                                  ),
                              ],
                            ),
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
