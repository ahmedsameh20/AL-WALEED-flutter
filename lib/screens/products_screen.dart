import 'package:flutter/material.dart';

import '../db/product_dao.dart';
import '../l10n/app_strings.dart';
import '../models/product.dart';
import '../utils/app_settings.dart';
import 'barcode_scanner_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _nameController = TextEditingController();
  final _buyPriceController = TextEditingController();
  final _sellPriceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _barcodeController = TextEditingController();

  String _type = 'بن';
  late Future<List<Product>> _productsFuture;

  bool get _isCups => _type == 'أكواب';
  double get _lowStockThreshold => AppSettings.instance.lowStockThreshold;

  @override
  void initState() {
    super.initState();
    _productsFuture = ProductDAO.getAll();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _buyPriceController.dispose();
    _sellPriceController.dispose();
    _quantityController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  Future<void> _scanInto(TextEditingController controller) async {
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    );
    if (code != null && code.isNotEmpty) {
      controller.text = code;
    }
  }

  void _refresh() {
    setState(() => _productsFuture = ProductDAO.getAll());
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _addProduct() async {
    final name = _nameController.text.trim();
    final buyPrice = double.tryParse(_buyPriceController.text.trim());
    final sellPrice = double.tryParse(_sellPriceController.text.trim());
    final quantity = _isCups ? 0.0 : double.tryParse(_quantityController.text.trim());

    if (name.isEmpty || buyPrice == null || sellPrice == null || quantity == null) {
      _showMessage(S.t('err_fill_fields_correctly'));
      return;
    }
    if (buyPrice <= 0 || sellPrice <= 0) {
      _showMessage(S.t('err_price_must_be_positive'));
      return;
    }
    if (quantity < 0) {
      _showMessage(S.t('err_quantity_negative'));
      return;
    }

    await ProductDAO.insert(
      name: name,
      type: _type,
      buyPrice: buyPrice,
      sellPrice: sellPrice,
      quantity: quantity,
      barcode: _barcodeController.text.trim(),
    );

    _nameController.clear();
    _buyPriceController.clear();
    _sellPriceController.clear();
    _quantityController.clear();
    _barcodeController.clear();
    _showMessage(S.t('product_added'));
    _refresh();
  }

  Future<void> _deleteProduct(Product product) async {
    await ProductDAO.delete(product.id);
    _showMessage(S.t('product_deleted'));
    _refresh();
  }

  Future<void> _editProduct(Product product) async {
    final nameController = TextEditingController(text: product.name);
    final buyController = TextEditingController(text: product.buyPrice.toString());
    final sellController = TextEditingController(text: product.sellPrice.toString());
    final initQtyController = TextEditingController(text: product.initialQuantity.toString());
    final qtyController = TextEditingController(text: product.quantity.toString());
    final barcodeController = TextEditingController(text: product.barcode);
    String type = product.type;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final isCups = type == 'أكواب';
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(S.t('edit_product'), style: Theme.of(sheetContext).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: S.t('name'), border: const OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: type,
                    decoration: InputDecoration(labelText: S.t('type'), border: const OutlineInputBorder()),
                    items: [
                      DropdownMenuItem(value: 'بن', child: Text(S.t('type_beans'))),
                      DropdownMenuItem(value: 'أكواب', child: Text(S.t('type_cups'))),
                    ],
                    onChanged: (value) => setSheetState(() => type = value ?? type),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: buyController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: S.t('buy_price'), border: const OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: sellController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: S.t('sell_price'), border: const OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: initQtyController,
                    enabled: !isCups,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: S.t('initial_quantity'), border: const OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: qtyController,
                    enabled: !isCups,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: S.t('remaining_quantity'), border: const OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: barcodeController,
                          decoration: InputDecoration(labelText: S.t('barcode_label'), border: const OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final code = await Navigator.of(sheetContext).push<String>(
                            MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
                          );
                          if (code != null && code.isNotEmpty) {
                            setSheetState(() => barcodeController.text = code);
                          }
                        },
                        icon: const Icon(Icons.qr_code_scanner),
                        label: Text(S.t('scan_button')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6D4C41),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        final buyPrice = double.tryParse(buyController.text.trim());
                        final sellPrice = double.tryParse(sellController.text.trim());
                        final initQty = isCups ? 0.0 : double.tryParse(initQtyController.text.trim());
                        final qty = isCups ? 0.0 : double.tryParse(qtyController.text.trim());
                        final name = nameController.text.trim();

                        if (name.isEmpty || buyPrice == null || sellPrice == null || initQty == null || qty == null) {
                          _showMessage(S.t('err_edit_fields'));
                          return;
                        }
                        if (buyPrice <= 0 || sellPrice <= 0) {
                          _showMessage(S.t('err_price_must_be_positive'));
                          return;
                        }
                        if (initQty < 0 || qty < 0) {
                          _showMessage(S.t('err_quantity_negative'));
                          return;
                        }

                        await ProductDAO.update(
                          id: product.id,
                          name: name,
                          type: type,
                          buyPrice: buyPrice,
                          sellPrice: sellPrice,
                          initialQuantity: initQty,
                          quantity: qty,
                          barcode: barcodeController.text.trim(),
                        );

                        if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                        _refresh();
                      },
                      child: Text(S.t('save')),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(S.t('confirm_delete')),
        content: Text('${S.t('confirm_delete_item_prefix')} "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(S.t('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(S.t('delete'), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteProduct(product);
    }
  }

  String _fmt(double value) => value == 0 ? '-' : value.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.t('products_title'))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: S.t('product_name'), border: const OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _type,
                  decoration: InputDecoration(labelText: S.t('type'), border: const OutlineInputBorder()),
                  items: [
                    DropdownMenuItem(value: 'بن', child: Text(S.t('type_beans'))),
                    DropdownMenuItem(value: 'أكواب', child: Text(S.t('type_cups'))),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _type = value ?? _type;
                      if (_isCups) _quantityController.clear();
                    });
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _buyPriceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(labelText: S.t('buy_price'), border: const OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _sellPriceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(labelText: S.t('sell_price'), border: const OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _quantityController,
                  enabled: !_isCups,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: S.t('quantity'), border: const OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _barcodeController,
                        decoration: InputDecoration(labelText: S.t('barcode_label'), border: const OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      onPressed: () => _scanInto(_barcodeController),
                      icon: const Icon(Icons.qr_code_scanner),
                      label: Text(S.t('scan_button')),
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
                    onPressed: _addProduct,
                    icon: const Icon(Icons.add),
                    label: Text(S.t('add')),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final products = snapshot.data ?? [];
                if (products.isEmpty) {
                  return Center(child: Text(S.t('no_products_yet')));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final isLowStock = !product.isCups && product.quantity <= _lowStockThreshold;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      color: isLowStock ? Colors.red.shade50 : null,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    product.name,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                if (isLowStock) ...[
                                  Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 18),
                                  const SizedBox(width: 4),
                                  Text(
                                    S.t('low_stock_badge'),
                                    style: TextStyle(color: Colors.red.shade700, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Chip(label: Text(S.productType(product.type))),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 16,
                              runSpacing: 4,
                              children: [
                                Text('${S.t('buy_label')}: ${_fmt(product.buyPrice)}'),
                                Text('${S.t('sell_label')}: ${_fmt(product.sellPrice)}'),
                                if (!product.isCups) ...[
                                  Text('${S.t('remaining_label')}: ${_fmt(product.quantity)}'),
                                  Text('${S.t('initial_label')}: ${_fmt(product.initialQuantity)}'),
                                  Text('${S.t('cost_label')}: ${_fmt(product.costValue)}'),
                                  Text('${S.t('remaining_value_label')}: ${_fmt(product.remainingValue)}'),
                                  Text('${S.t('sold_value_label')}: ${_fmt(product.soldValue)}'),
                                ],
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Color(0xFF6D4C41)),
                                  onPressed: () => _editProduct(product),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _confirmDelete(product),
                                ),
                              ],
                            ),
                          ],
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
