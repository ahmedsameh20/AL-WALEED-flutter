import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../utils/app_session.dart';
import '../widgets/dashboard_tile.dart';
import 'blends_screen.dart';
import 'expenses_screen.dart';
import 'invoices_screen.dart';
import 'login_screen.dart';
import 'notes_screen.dart';
import 'orders_screen.dart';
import 'shifts_screen.dart';

class SellerDashboard extends StatelessWidget {
  const SellerDashboard({super.key});

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  void _logout(BuildContext context) {
    AppSession.instance.logout();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0ED),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.t('dashboard_title_seller'),
                          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${S.t('welcome')} ${AppSession.instance.currentEmployeeName} (${S.t('role_seller')})',
                          style: TextStyle(fontSize: 15, color: Colors.black.withValues(alpha: 0.6)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    tooltip: S.t('log_out'),
                    onPressed: () => _logout(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              DashboardSection(
                title: S.t('section_operations'),
                tiles: [
                  DashboardTile(
                    icon: Icons.receipt_long,
                    label: S.t('nav_orders'),
                    onPressed: () => _open(context, const OrdersScreen()),
                  ),
                  DashboardTile(
                    icon: Icons.description,
                    label: S.t('nav_invoices'),
                    onPressed: () => _open(context, const InvoicesScreen()),
                  ),
                  DashboardTile(
                    icon: Icons.coffee,
                    label: S.t('nav_blends'),
                    onPressed: () => _open(context, const BlendsScreen()),
                  ),
                ],
              ),
              DashboardSection(
                title: S.t('section_finance'),
                tiles: [
                  DashboardTile(
                    icon: Icons.money_off,
                    label: S.t('nav_expenses'),
                    onPressed: () => _open(context, const ExpensesScreen()),
                  ),
                ],
              ),
              DashboardSection(
                title: S.t('section_more'),
                tiles: [
                  DashboardTile(
                    icon: Icons.chat_bubble_outline,
                    label: S.t('nav_notes'),
                    onPressed: () => _open(context, const NotesScreen()),
                  ),
                  DashboardTile(
                    icon: Icons.access_time,
                    label: S.t('nav_shifts'),
                    onPressed: () => _open(context, const ShiftsScreen()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
