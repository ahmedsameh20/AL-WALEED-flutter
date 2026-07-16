import 'package:flutter/material.dart';

import '../db/customer_dao.dart';
import '../db/order_service.dart';
import '../db/product_dao.dart';
import '../db/promo_code_dao.dart';
import '../l10n/app_strings.dart';
import '../models/order_item.dart';
import '../models/product.dart';
import '../models/promo_code.dart';
import '../utils/app_session.dart';
import '../utils/app_settings.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _quantityController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _promoCodeController = TextEditingController();

  late Future<List<Product>> _productsFuture;
  Product? _selectedProduct;
  final List<OrderItem> _cart = [];
  bool _submitting = false;
  PromoCode? _appliedCode;
  String _paymentMethod = 'cash';

  @override
  void initState() {
    super.initState();
    _productsFuture = ProductDAO.getAll();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _customerNameController.dispose();
    _phoneController.dispose();
    _promoCodeController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  double get _subtotal => _cart.fold(0, (sum, item) => sum + item.totalPrice);
  double get _discountAmount => _appliedCode?.discountFor(_subtotal) ?? 0;
  double get _taxableAmount => _subtotal - _discountAmount;
  double get _vatRate => AppSettings.instance.vatRate;
  double get _taxAmount => _taxableAmount * _vatRate / 100;
  double get _total => _taxableAmount + _taxAmount;

  Future<void> _applyPromoCode() async {
    final code = _promoCodeController.text.trim();
    if (code.isEmpty) return;
    final match = await PromoCodeDAO.findActive(code);
    if (!mounted) return;
    if (match == null) {
      setState(() => _appliedCode = null);
      _showMessage(S.t('invalid_promo_code'));
      return;
    }
    setState(() => _appliedCode = match);
    _showMessage(S.t('promo_code_applied'));
  }

  void _removePromoCode() {
    setState(() {
      _appliedCode = null;
      _promoCodeController.clear();
    });
  }

  void _addToCart() {
    final product = _selectedProduct;
    if (product == null) {
      _showMessage(S.t('err_select_product'));
      return;
    }

    final qtyText = _quantityController.text.trim();
    final isCups = product.isCups;

    double? qty;
    if (isCups) {
      if (!RegExp(r'^\d+$').hasMatch(qtyText)) {
        _showMessage(S.t('err_no_decimal_cups'));
        return;
      }
      qty = double.tryParse(qtyText);
    } else {
      qty = double.tryParse(qtyText);
    }

    if (qty == null || qty <= 0) {
      _showMessage(S.t('err_enter_valid_quantity'));
      return;
    }

    setState(() {
      final existing = _cart.where((i) => i.productId == product.id).toList();
      if (existing.isNotEmpty) {
        existing.first.quantity += qty!;
      } else {
        _cart.add(OrderItem(
          productId: product.id,
          productName: product.name,
          unitPrice: product.sellPrice,
          quantity: qty!,
        ));
      }
      _quantityController.clear();
    });
  }

  void _removeFromCart(OrderItem item) {
    setState(() => _cart.remove(item));
  }

  Future<void> _lookupCustomerByPhone(String phone) async {
    if (phone.trim().length < 7 || _customerNameController.text.trim().isNotEmpty) return;
    final name = await CustomerDAO.findNameByPhone(phone.trim());
    if (!mounted || name == null || name.isEmpty) return;
    if (_customerNameController.text.trim().isEmpty) {
      _customerNameController.text = name;
    }
  }

  Future<void> _submitOrder() async {
    if (_cart.isEmpty) {
      _showMessage(S.t('err_no_products_added'));
      return;
    }

    final phone = _phoneController.text.trim();
    if (phone.isNotEmpty && !RegExp(r'^[0-9+\-\s]{7,15}$').hasMatch(phone)) {
      _showMessage(S.t('err_invalid_phone'));
      return;
    }

    setState(() => _submitting = true);

    final employeeName = AppSession.instance.isOwner
        ? S.t('business_owner_label')
        : (AppSession.instance.currentEmployeeName ?? '');

    final orderId = await OrderService.createOrder(
      customerName: _customerNameController.text.trim(),
      phone: phone,
      employeeId: AppSession.instance.currentEmployeeId,
      employeeName: employeeName,
      items: _cart,
      discountCode: _appliedCode?.code,
      discountAmount: _discountAmount,
      paymentMethod: _paymentMethod,
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (orderId > 0) {
      _showMessage('${S.t('order_saved_prefix')} $orderId)');
      setState(() {
        _cart.clear();
        _customerNameController.clear();
        _phoneController.clear();
        _promoCodeController.clear();
        _appliedCode = null;
        _paymentMethod = 'cash';
        _productsFuture = ProductDAO.getAll();
      });
    } else {
      _showMessage(S.t('order_failed'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.t('orders_title'))),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final products = snapshot.data ?? [];

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    DropdownButtonFormField<Product>(
                      value: _selectedProduct,
                      decoration: InputDecoration(labelText: S.t('product'), border: const OutlineInputBorder()),
                      items: products
                          .map((p) => DropdownMenuItem(value: p, child: Text('${p.name} (${p.sellPrice})')))
                          .toList(),
                      onChanged: (value) => setState(() => _selectedProduct = value),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _quantityController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(labelText: S.t('quantity'), border: const OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6D4C41),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          ),
                          onPressed: _addToCart,
                          icon: const Icon(Icons.add),
                          label: Text(S.t('add_short')),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: _cart.isEmpty
                    ? Center(child: Text(S.t('no_products_added_yet')))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _cart.length,
                        itemBuilder: (context, index) {
                          final item = _cart[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(item.productName),
                              subtitle: Text(
                                '${S.t('price_label')}: ${item.unitPrice.toStringAsFixed(2)}  ×  ${S.t('quantity')}: ${item.quantity}  =  ${item.totalPrice.toStringAsFixed(2)}',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeFromCart(item),
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
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _customerNameController,
                            decoration: InputDecoration(labelText: S.t('customer_name'), border: const OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(labelText: S.t('phone'), border: const OutlineInputBorder()),
                            onChanged: _lookupCustomerByPhone,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _promoCodeController,
                            textCapitalization: TextCapitalization.characters,
                            enabled: _appliedCode == null,
                            decoration: InputDecoration(hintText: S.t('promo_code_hint'), border: const OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton(
                          onPressed: _appliedCode == null ? _applyPromoCode : _removePromoCode,
                          child: Text(_appliedCode == null ? S.t('apply_code') : S.t('remove_code')),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<String>(
                        segments: [
                          ButtonSegment(value: 'cash', label: Text(S.t('payment_cash'))),
                          ButtonSegment(value: 'card', label: Text(S.t('payment_card'))),
                          ButtonSegment(value: 'wallet', label: Text(S.t('payment_wallet'))),
                        ],
                        selected: {_paymentMethod},
                        onSelectionChanged: (selection) => setState(() => _paymentMethod = selection.first),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${S.t('subtotal')}: ${_subtotal.toStringAsFixed(2)} ${S.t('currency')}'),
                        Text('${S.t('vat_label')} (${_vatRate.toStringAsFixed(0)}%): ${_taxAmount.toStringAsFixed(2)} ${S.t('currency')}'),
                      ],
                    ),
                    if (_appliedCode != null) ...[
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${S.t('discount_label')} (${_appliedCode!.code}): -${_discountAmount.toStringAsFixed(2)} ${S.t('currency')}',
                          style: const TextStyle(color: Colors.green),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${S.t('total')}: ${_total.toStringAsFixed(2)} ${S.t('currency')}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6D4C41),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                          ),
                          onPressed: _submitting ? null : _submitOrder,
                          icon: const Icon(Icons.save),
                          label: Text(S.t('confirm_order')),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
