import 'package:flutter/material.dart';

import '../db/blend_service.dart';
import '../l10n/app_strings.dart';
import '../models/blend_component.dart';
import '../utils/app_session.dart';

class BlendsScreen extends StatefulWidget {
  const BlendsScreen({super.key});

  @override
  State<BlendsScreen> createState() => _BlendsScreenState();
}

class _BlendsScreenState extends State<BlendsScreen> {
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _sellPriceController = TextEditingController();

  List<BlendComponent> _components = [];
  final Map<int, TextEditingController> _usedControllers = {};
  String? _status;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _sellPriceController.dispose();
    for (final c in _usedControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    final components = await BlendService.getBeanProducts();
    if (!mounted) return;
    setState(() {
      _components = components;
      for (final c in components) {
        _usedControllers.putIfAbsent(c.id, () => TextEditingController(text: '0'));
      }
    });
  }

  double _usedQty(int productId) {
    return double.tryParse(_usedControllers[productId]?.text.trim() ?? '') ?? 0;
  }

  Future<void> _createBlend() async {
    final name = _nameController.text.trim();
    final multiplier = double.tryParse(_quantityController.text.trim());

    if (multiplier == null || multiplier <= 0) {
      setState(() => _status = S.t('err_enter_valid_quantity_blend'));
      return;
    }
    if (name.isEmpty) {
      setState(() => _status = S.t('err_enter_blend_name'));
      return;
    }

    final totalUsed = _components.fold<double>(0, (sum, c) => sum + _usedQty(c.id));
    final expected = multiplier;
    if ((totalUsed - expected).abs() > 0.001) {
      setState(() => _status =
          '${S.t('err_quantity_sum_mismatch_prefix')} $expected ${S.t('err_quantity_sum_mismatch_kg_now')} $totalUsed)');
      return;
    }

    double? manualSellPrice;
    final sellText = _sellPriceController.text.trim();
    if (sellText.isNotEmpty) {
      manualSellPrice = double.tryParse(sellText);
      if (manualSellPrice == null) {
        setState(() => _status = S.t('err_invalid_sell_price'));
        return;
      }
    }

    setState(() {
      _submitting = true;
      _status = null;
    });

    final used = _components
        .map((c) => UsedComponent(component: c, usedQty: _usedQty(c.id)))
        .toList();

    final orderId = await BlendService.createBlend(
      name: name,
      multiplier: multiplier,
      components: used,
      manualSellPrice: manualSellPrice,
      employeeId: AppSession.instance.currentEmployeeId,
      employeeName: AppSession.instance.currentEmployeeName ?? '',
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (orderId > 0) {
      setState(() => _status = '${S.t('blend_created_prefix')} $orderId');
      _nameController.clear();
      _quantityController.text = '1';
      _sellPriceController.clear();
      for (final c in _usedControllers.values) {
        c.text = '0';
      }
      await _load();
    } else {
      setState(() => _status = S.t('blend_failed'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.t('blends_title'))),
      body: Column(
        children: [
          Expanded(
            child: _components.isEmpty
                ? Center(child: Text(S.t('no_beans_available')))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _components.length,
                    itemBuilder: (context, index) {
                      final c = _components[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Expanded(
                                child: Text('${S.t('available_label')}: ${c.availableQty.toStringAsFixed(2)}'),
                              ),
                              SizedBox(
                                width: 90,
                                child: TextField(
                                  controller: _usedControllers[c.id],
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: InputDecoration(labelText: S.t('used_label'), isDense: true),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: S.t('blend_name'), border: const OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _quantityController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(labelText: S.t('blend_quantity_kg'), border: const OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _sellPriceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(labelText: S.t('sell_price_optional'), border: const OutlineInputBorder()),
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
                    onPressed: _submitting ? null : _createBlend,
                    icon: const Icon(Icons.check_circle_outline),
                    label: Text(S.t('create_blend')),
                  ),
                ),
                if (_status != null) ...[
                  const SizedBox(height: 10),
                  Text(_status!, textAlign: TextAlign.center),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
