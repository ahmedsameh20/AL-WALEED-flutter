import 'package:flutter/material.dart';

import '../db/invoice_dao.dart';
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
        title: const Text('تعديل الملاحظة'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'اكتب الملاحظة'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('إلغاء')),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: const Text('حفظ'),
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
        title: const Text('تأكيد الحذف'),
        content: Text('تأكيد حذف الفاتورة #${invoice.id}؟'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('لا')),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('نعم', style: TextStyle(color: Colors.red)),
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
                  const Text('مطحن الوليد للبن', style: TextStyle(fontFamily: 'monospace', fontSize: 15)),
                  const Text('-------------------------------', style: TextStyle(fontFamily: 'monospace')),
                  Text('رقم الفاتورة: ${invoice.id}', style: const TextStyle(fontFamily: 'monospace')),
                  Text('التاريخ: ${invoice.date}   الساعة: ${invoice.time}', style: const TextStyle(fontFamily: 'monospace')),
                  Text('اسم العميل: ${invoice.customerName}', style: const TextStyle(fontFamily: 'monospace')),
                  Text('الهاتف: ${invoice.phone}', style: const TextStyle(fontFamily: 'monospace')),
                  Text('الموظف: ${invoice.employeeName}', style: const TextStyle(fontFamily: 'monospace')),
                  const SizedBox(height: 8),
                  const Text('المنتجات:', style: TextStyle(fontFamily: 'monospace')),
                  for (final item in items)
                    Text(
                      '- ${item['name']} × ${item['quantity']} × ${item['unit_price']} = ${(item['quantity'] as num) * (item['unit_price'] as num)}',
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  const SizedBox(height: 8),
                  const Text('-------------------------------', style: TextStyle(fontFamily: 'monospace')),
                  Text('الإجمالي: ${invoice.total} جنيه', style: const TextStyle(fontFamily: 'monospace')),
                  Text('ملاحظات: ${invoice.note}', style: const TextStyle(fontFamily: 'monospace')),
                  const SizedBox(height: 20),
                  const Text(
                    'لا تتوفر طباعة مباشرة على الجوال — استخدم لقطة شاشة أو المشاركة.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
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
      appBar: AppBar(title: const Text('📄 فواتير الطلبات')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: '🔍 بحث برقم الفاتورة أو اسم العميل أو الهاتف',
                border: OutlineInputBorder(),
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
                  return const Center(child: Text('لا توجد فواتير'));
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
                                    'فاتورة #${invoice.id}',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Text('${invoice.total.toStringAsFixed(2)} جنيه'),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('${invoice.date} ${invoice.time}', style: const TextStyle(color: Colors.grey)),
                            const SizedBox(height: 6),
                            Text(invoice.itemsSummary),
                            const SizedBox(height: 6),
                            Text('العميل: ${invoice.customerName}  الهاتف: ${invoice.phone}'),
                            Text('الموظف: ${invoice.employeeName}'),
                            if (invoice.note.isNotEmpty) Text('ملاحظة: ${invoice.note}'),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: () => _editNote(invoice),
                                  icon: const Icon(Icons.edit_note, size: 18),
                                  label: const Text('ملاحظة'),
                                ),
                                TextButton.icon(
                                  onPressed: () => _showPrintPreview(invoice),
                                  icon: const Icon(Icons.print, size: 18),
                                  label: const Text('طباعة'),
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
