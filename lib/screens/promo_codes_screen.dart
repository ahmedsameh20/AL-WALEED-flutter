import 'package:flutter/material.dart';

import '../db/promo_code_dao.dart';
import '../l10n/app_strings.dart';
import '../models/promo_code.dart';

class PromoCodesScreen extends StatefulWidget {
  const PromoCodesScreen({super.key});

  @override
  State<PromoCodesScreen> createState() => _PromoCodesScreenState();
}

class _PromoCodesScreenState extends State<PromoCodesScreen> {
  final _codeController = TextEditingController();
  final _valueController = TextEditingController();
  String _type = 'percentage';

  late Future<List<PromoCode>> _codesFuture;

  @override
  void initState() {
    super.initState();
    _codesFuture = PromoCodeDAO.getAll();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() => _codesFuture = PromoCodeDAO.getAll());
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _addCode() async {
    final code = _codeController.text.trim();
    final value = double.tryParse(_valueController.text.trim());

    if (code.isEmpty) {
      _showMessage(S.t('err_code_required'));
      return;
    }
    if (value == null || value <= 0) {
      _showMessage(S.t('err_value_positive'));
      return;
    }
    if (_type == 'percentage' && value > 100) {
      _showMessage(S.t('err_invalid_vat_rate'));
      return;
    }

    final added = await PromoCodeDAO.insert(code: code, type: _type, value: value);
    if (!added) {
      _showMessage(S.t('err_code_exists'));
      return;
    }

    _codeController.clear();
    _valueController.clear();
    _showMessage(S.t('code_added'));
    _refresh();
  }

  Future<void> _confirmDelete(PromoCode code) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(S.t('confirm_delete')),
        content: Text('${S.t('confirm_delete_code_prefix')} "${code.code}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(S.t('cancel'))),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(S.t('delete'), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await PromoCodeDAO.delete(code.id);
      _refresh();
    }
  }

  String _valueLabel(PromoCode code) =>
      code.isPercentage ? '${code.value.toStringAsFixed(0)}%' : '${code.value.toStringAsFixed(2)} ${S.t('currency')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.t('promo_codes_title'))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _codeController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(labelText: S.t('code_label'), border: const OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _type,
                        decoration: InputDecoration(labelText: S.t('type_label'), border: const OutlineInputBorder()),
                        items: [
                          DropdownMenuItem(value: 'percentage', child: Text(S.t('type_percentage'))),
                          DropdownMenuItem(value: 'fixed', child: Text(S.t('type_fixed'))),
                        ],
                        onChanged: (value) => setState(() => _type = value ?? _type),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _valueController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(labelText: S.t('value_label'), border: const OutlineInputBorder()),
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
                    onPressed: _addCode,
                    icon: const Icon(Icons.add),
                    label: Text(S.t('add_promo_code')),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: FutureBuilder<List<PromoCode>>(
              future: _codesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final codes = snapshot.data ?? [];
                if (codes.isEmpty) {
                  return Center(child: Text(S.t('no_promo_codes')));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: codes.length,
                  itemBuilder: (context, index) {
                    final code = codes[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        title: Text(code.code, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          '${code.isPercentage ? S.t('type_percentage') : S.t('type_fixed')} · ${_valueLabel(code)}',
                        ),
                        leading: Switch(
                          value: code.active,
                          activeColor: const Color(0xFF6D4C41),
                          onChanged: (value) async {
                            await PromoCodeDAO.setActive(code.id, value);
                            _refresh();
                          },
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(code),
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
