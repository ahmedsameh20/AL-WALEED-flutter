import 'package:flutter/material.dart';

import '../db/product_dao.dart';
import '../l10n/app_strings.dart';
import '../utils/app_session.dart';
import '../utils/app_settings.dart';
import '../widgets/dashboard_tile.dart';
import 'blends_screen.dart';
import 'customers_screen.dart';
import 'employees_screen.dart';
import 'expenses_screen.dart';
import 'invoices_screen.dart';
import 'login_screen.dart';
import 'logs_screen.dart';
import 'notes_screen.dart';
import 'orders_screen.dart';
import 'products_screen.dart';
import 'profit_report_screen.dart';
import 'promo_codes_screen.dart';
import 'sales_report_screen.dart';
import 'settings_screen.dart';

class OwnerDashboard extends StatelessWidget {
  const OwnerDashboard({super.key});

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
                          S.t('dashboard_title_owner'),
                          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${S.t('welcome')} ${AppSession.instance.currentEmployeeName} (${S.t('role_owner')})',
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
              const SizedBox(height: 16),
              FutureBuilder(
                future: ProductDAO.getAll(),
                builder: (context, snapshot) {
                  final products = snapshot.data ?? [];
                  final threshold = AppSettings.instance.lowStockThreshold;
                  final lowStockCount =
                      products.where((p) => !p.isCups && p.quantity <= threshold).length;
                  if (lowStockCount == 0) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _open(context, const ProductsScreen()),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '${S.t('low_stock_banner_prefix')} $lowStockCount ${S.t('low_stock_banner_suffix')}',
                                  style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w600),
                                ),
                              ),
                              Icon(Icons.chevron_left, color: Colors.red.shade700),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
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
                title: S.t('section_management'),
                tiles: [
                  DashboardTile(
                    icon: Icons.inventory_2,
                    label: S.t('nav_products'),
                    onPressed: () => _open(context, const ProductsScreen()),
                  ),
                  DashboardTile(
                    icon: Icons.groups,
                    label: S.t('nav_employees'),
                    onPressed: () => _open(context, const EmployeesScreen()),
                  ),
                  DashboardTile(
                    icon: Icons.local_offer,
                    label: S.t('nav_promo_codes'),
                    onPressed: () => _open(context, const PromoCodesScreen()),
                  ),
                  DashboardTile(
                    icon: Icons.people_outline,
                    label: S.t('nav_customers'),
                    onPressed: () => _open(context, const CustomersScreen()),
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
                  DashboardTile(
                    icon: Icons.trending_up,
                    label: S.t('nav_sales'),
                    onPressed: () => _open(context, const SalesReportScreen()),
                  ),
                  DashboardTile(
                    icon: Icons.attach_money,
                    label: S.t('nav_profits'),
                    onPressed: () => _open(context, const ProfitReportScreen()),
                  ),
                ],
              ),
              DashboardSection(
                title: S.t('section_more'),
                tiles: [
                  DashboardTile(
                    icon: Icons.history,
                    label: S.t('nav_logs'),
                    onPressed: () => _open(context, const LogsScreen()),
                  ),
                  DashboardTile(
                    icon: Icons.chat_bubble_outline,
                    label: S.t('nav_notes'),
                    onPressed: () => _open(context, const NotesScreen()),
                  ),
                  DashboardTile(
                    icon: Icons.settings,
                    label: S.t('nav_settings'),
                    onPressed: () => _open(context, const SettingsScreen()),
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
