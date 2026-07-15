import 'package:flutter/material.dart';

import '../db/expense_dao.dart';
import '../models/expense.dart';
import '../utils/app_session.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  late Future<List<Expense>> _expensesFuture;

  bool get _isOwner => AppSession.instance.isOwner;

  @override
  void initState() {
    super.initState();
    _expensesFuture = ExpenseDAO.getAll();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() => _expensesFuture = ExpenseDAO.getAll());
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _addExpense() async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null) {
      _showMessage('❌ المبلغ غير صالح');
      return;
    }

    await ExpenseDAO.insert(
      employeeId: AppSession.instance.currentEmployeeId,
      amount: amount,
      note: _noteController.text.trim(),
    );

    _amountController.clear();
    _noteController.clear();
    _refresh();
  }

  Future<void> _confirmDelete(Expense expense) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('حذف مصروف #${expense.id} بقيمة ${expense.amount.toStringAsFixed(2)}؟'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('إلغاء')),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ExpenseDAO.delete(expense.id);
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('💸 إدارة المصروفات')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'المبلغ', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _noteController,
                        decoration: const InputDecoration(labelText: 'ملاحظة', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6D4C41),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _addExpense,
                    icon: const Icon(Icons.add),
                    label: const Text('إضافة'),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: FutureBuilder<List<Expense>>(
              future: _expensesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final expenses = snapshot.data ?? [];
                if (expenses.isEmpty) {
                  return const Center(child: Text('لا توجد مصروفات بعد'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text('${expense.amount.toStringAsFixed(2)} — ${expense.note}'),
                        subtitle: Text('${expense.employeeName}  •  ${expense.createdAt}'),
                        trailing: _isOwner
                            ? IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _confirmDelete(expense),
                              )
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
          ),
          FutureBuilder<List<Expense>>(
            future: _expensesFuture,
            builder: (context, snapshot) {
              final total = (snapshot.data ?? []).fold<double>(0, (sum, e) => sum + e.amount);
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                color: const Color(0xFFFFE0B2),
                child: Text(
                  '📊 إجمالي المصروفات: ${total.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
