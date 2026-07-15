import 'package:flutter/material.dart';

import '../db/product_dao.dart';
import '../models/product.dart';

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

  String _type = 'بن';
  late Future<List<Product>> _productsFuture;

  bool get _isCups => _type == 'أكواب';

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
    super.dispose();
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
      _showMessage('❌ تأكد من إدخال كل الحقول بشكل صحيح.');
      return;
    }

    await ProductDAO.insert(
      name: name,
      type: _type,
      buyPrice: buyPrice,
      sellPrice: sellPrice,
      quantity: quantity,
    );

    _nameController.clear();
    _buyPriceController.clear();
    _sellPriceController.clear();
    _quantityController.clear();
    _showMessage('✔ تم إضافة المنتج');
    _refresh();
  }

  Future<void> _deleteProduct(Product product) async {
    await ProductDAO.delete(product.id);
    _showMessage('✔ تم حذف المنتج');
    _refresh();
  }

  Future<void> _editProduct(Product product) async {
    final nameController = TextEditingController(text: product.name);
    final buyController = TextEditingController(text: product.buyPrice.toString());
    final sellController = TextEditingController(text: product.sellPrice.toString());
    final initQtyController = TextEditingController(text: product.initialQuantity.toString());
    final qtyController = TextEditingController(text: product.quantity.toString());
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
                  Text('تعديل المنتج', style: Theme.of(sheetContext).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'الاسم', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: type,
                    decoration: const InputDecoration(labelText: 'النوع', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'بن', child: Text('بن')),
                      DropdownMenuItem(value: 'أكواب', child: Text('أكواب')),
                    ],
                    onChanged: (value) => setSheetState(() => type = value ?? type),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: buyController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'سعر الشراء', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: sellController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'سعر البيع', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: initQtyController,
                    enabled: !isCups,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'الكمية الأصلية', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: qtyController,
                    enabled: !isCups,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'الكمية المتبقية', border: OutlineInputBorder()),
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
                          _showMessage('❌ خطأ أثناء التعديل: تأكد من الحقول');
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
                        );

                        if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                        _refresh();
                      },
                      child: const Text('حفظ'),
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
        title: const Text('تأكيد الحذف'),
        content: Text('هل تريد حذف "${product.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
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
      appBar: AppBar(title: const Text('📦 إدارة المنتجات')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'اسم المنتج', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _type,
                  decoration: const InputDecoration(labelText: 'النوع', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'بن', child: Text('بن')),
                    DropdownMenuItem(value: 'أكواب', child: Text('أكواب')),
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
                        decoration: const InputDecoration(labelText: 'سعر الشراء', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _sellPriceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'سعر البيع', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _quantityController,
                  enabled: !_isCups,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'الكمية', border: OutlineInputBorder()),
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
                    label: const Text('إضافة'),
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
                  return const Center(child: Text('لا توجد منتجات بعد'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
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
                                Chip(label: Text(product.type)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 16,
                              runSpacing: 4,
                              children: [
                                Text('شراء: ${_fmt(product.buyPrice)}'),
                                Text('بيع: ${_fmt(product.sellPrice)}'),
                                if (!product.isCups) ...[
                                  Text('متبقي: ${_fmt(product.quantity)}'),
                                  Text('أصلي: ${_fmt(product.initialQuantity)}'),
                                  Text('تكلفة: ${_fmt(product.costValue)}'),
                                  Text('قيمة متبقية: ${_fmt(product.remainingValue)}'),
                                  Text('قيمة مباعة: ${_fmt(product.soldValue)}'),
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
