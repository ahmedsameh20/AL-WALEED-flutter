import 'package:flutter/material.dart';

import '../db/order_service.dart';
import '../db/product_dao.dart';
import '../l10n/app_strings.dart';
import '../models/order_item.dart';
import '../models/product.dart';
import '../utils/app_session.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _quantityController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _phoneController = TextEditingController();

  late Future<List<Product>> _productsFuture;
  Product? _selectedProduct;
  final List<OrderItem> _cart = [];
  bool _submitting = false;

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
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  double get _total => _cart.fold(0, (sum, item) => sum + item.totalPrice);

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

  Future<void> _submitOrder() async {
    if (_cart.isEmpty) {
      _showMessage(S.t('err_no_products_added'));
      return;
    }

    setState(() => _submitting = true);

    final employeeName = AppSession.instance.isOwner
        ? S.t('business_owner_label')
        : (AppSession.instance.currentEmployeeName ?? '');

    final orderId = await OrderService.createOrder(
      customerName: _customerNameController.text.trim(),
      phone: _phoneController.text.trim(),
      employeeId: AppSession.instance.currentEmployeeId,
      employeeName: employeeName,
      items: _cart,
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (orderId > 0) {
      _showMessage('${S.t('order_saved_prefix')} $orderId)');
      setState(() {
        _cart.clear();
        _customerNameController.clear();
        _phoneController.clear();
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
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
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
