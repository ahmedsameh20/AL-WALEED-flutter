import 'package:flutter/material.dart';

import '../utils/app_session.dart';
import '../widgets/dashboard_button.dart';
import 'blends_screen.dart';
import 'employees_screen.dart';
import 'expenses_screen.dart';
import 'invoices_screen.dart';
import 'login_screen.dart';
import 'logs_screen.dart';
import 'notes_screen.dart';
import 'orders_screen.dart';
import 'products_screen.dart';
import 'profit_report_screen.dart';
import 'sales_report_screen.dart';
import 'settings_screen.dart';

class OwnerDashboard extends StatelessWidget {
  const OwnerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة المدير'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              AppSession.instance.logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'أهلاً ${AppSession.instance.currentEmployeeName} (مدير)',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 24),
            DashboardButton(
              icon: Icons.receipt_long,
              label: '🧾 تسجيل الطلب',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const OrdersScreen()),
                );
              },
            ),
            DashboardButton(
              icon: Icons.inventory_2,
              label: '📦 المنتجات',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProductsScreen()),
                );
              },
            ),
            DashboardButton(
              icon: Icons.groups,
              label: '👷‍♂️ الموظفين',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EmployeesScreen()),
                );
              },
            ),
            DashboardButton(
              icon: Icons.description,
              label: '📄 الفواتير',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const InvoicesScreen()),
                );
              },
            ),
            DashboardButton(
              icon: Icons.coffee,
              label: '🫘 توليفات البن',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const BlendsScreen()),
                );
              },
            ),
            DashboardButton(
              icon: Icons.money_off,
              label: '💸 المصروفات',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ExpensesScreen()),
                );
              },
            ),
            DashboardButton(
              icon: Icons.trending_up,
              label: '📈 المبيعات',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SalesReportScreen()),
                );
              },
            ),
            DashboardButton(
              icon: Icons.attach_money,
              label: '💰 الأرباح',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfitReportScreen()),
                );
              },
            ),
            DashboardButton(
              icon: Icons.history,
              label: '📜 السجل',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LogsScreen()),
                );
              },
            ),
            DashboardButton(
              icon: Icons.chat_bubble_outline,
              label: '📌 المحادثة',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NotesScreen()),
                );
              },
            ),
            DashboardButton(
              icon: Icons.settings,
              label: '⚙️ الإعدادات',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
