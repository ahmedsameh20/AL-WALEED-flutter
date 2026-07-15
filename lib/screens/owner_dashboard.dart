import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
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
        title: Text(S.t('dashboard_title_owner')),
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
              '${S.t('welcome')} ${AppSession.instance.currentEmployeeName} (${S.t('role_owner')})',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 24),
            DashboardButton(
              icon: Icons.receipt_long,
              label: S.t('nav_orders'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const OrdersScreen()),
                );
              },
            ),
            DashboardButton(
              icon: Icons.inventory_2,
              label: S.t('nav_products'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProductsScreen()),
                );
              },
            ),
            DashboardButton(
              icon: Icons.groups,
              label: S.t('nav_employees'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EmployeesScreen()),
                );
              },
            ),
            DashboardButton(
              icon: Icons.description,
              label: S.t('nav_invoices'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const InvoicesScreen()),
                );
              },
            ),
            DashboardButton(
              icon: Icons.coffee,
              label: S.t('nav_blends'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const BlendsScreen()),
                );
              },
            ),
            DashboardButton(
              icon: Icons.money_off,
              label: S.t('nav_expenses'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ExpensesScreen()),
                );
              },
            ),
            DashboardButton(
              icon: Icons.trending_up,
              label: S.t('nav_sales'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SalesReportScreen()),
                );
              },
            ),
            DashboardButton(
              icon: Icons.attach_money,
              label: S.t('nav_profits'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfitReportScreen()),
                );
              },
            ),
            DashboardButton(
              icon: Icons.history,
              label: S.t('nav_logs'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LogsScreen()),
                );
              },
            ),
            DashboardButton(
              icon: Icons.chat_bubble_outline,
              label: S.t('nav_notes'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NotesScreen()),
                );
              },
            ),
            DashboardButton(
              icon: Icons.settings,
              label: S.t('nav_settings'),
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
