import 'package:flutter/material.dart';

import '../db/settings_dao.dart';
import '../l10n/app_strings.dart';
import '../utils/app_session.dart';
import 'owner_dashboard.dart';
import 'seller_dashboard.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _sectionKeys = ['invoices', 'orders', 'products', 'expenses'];

  String _selectedSection = 'invoices';
  String? _status;

  String _sectionLabel(String key) => S.t('section_$key');

  /// Language changes only trigger a rebuild of screens that are actively
  /// listening (like this one). Screens already sitting lower in the
  /// navigation stack (e.g. the dashboard behind this route) won't pick up
  /// the new language until they're rebuilt, so we replace the whole stack
  /// with a freshly-built dashboard whenever the language changes.
  Future<void> _changeLanguage(String lang) async {
    await LocaleController.instance.setLanguage(lang);
    if (!mounted) return;
    final isOwner = AppSession.instance.isOwner;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => isOwner ? const OwnerDashboard() : const SellerDashboard(),
      ),
      (route) => false,
    );
  }

  Future<void> _handleReset() async {
    final sectionLabel = _sectionLabel(_selectedSection);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(S.t('confirm_delete')),
        content: Text(
          '${S.t('confirm_delete_section_prefix')} "$sectionLabel" ${S.t('confirm_delete_section_suffix')}',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(S.t('cancel'))),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(S.t('delete'), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await SettingsDAO.resetSection(_selectedSection);
    setState(() => _status = '${S.t('section_deleted_prefix')} $sectionLabel ${S.t('section_deleted_suffix')}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.t('settings_title'))),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(S.t('language'), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            AnimatedBuilder(
              animation: LocaleController.instance,
              builder: (context, _) {
                return SegmentedButton<String>(
                  segments: [
                    ButtonSegment(value: 'ar', label: Text(S.t('arabic'))),
                    ButtonSegment(value: 'en', label: Text(S.t('english'))),
                  ],
                  selected: {LocaleController.instance.language},
                  onSelectionChanged: (selection) => _changeLanguage(selection.first),
                );
              },
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Text(S.t('choose_section')),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedSection,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: _sectionKeys
                  .map((key) => DropdownMenuItem(value: key, child: Text(_sectionLabel(key))))
                  .toList(),
              onChanged: (value) => setState(() => _selectedSection = value ?? _selectedSection),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _handleReset,
              icon: const Icon(Icons.cleaning_services),
              label: Text(S.t('reset')),
            ),
            if (_status != null) ...[
              const SizedBox(height: 16),
              Text(_status!, textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}
