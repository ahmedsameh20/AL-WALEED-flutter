import 'package:flutter/material.dart';

import '../utils/app_session.dart';
import '../widgets/dashboard_button.dart';
import 'blends_screen.dart';
import 'expenses_screen.dart';
import 'invoices_screen.dart';
import 'login_screen.dart';
import 'notes_screen.dart';
import 'orders_screen.dart';

class SellerDashboard extends StatelessWidget {
  const SellerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة العامل'),
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
              'أهلاً ${AppSession.instance.currentEmployeeName} (عامل)',
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
              icon: Icons.chat_bubble_outline,
              label: '📌 المحادثة',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NotesScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
