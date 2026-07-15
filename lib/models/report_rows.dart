class EmployeeSales {
  final String employeeName;
  final int invoiceCount;
  final double totalSales;

  const EmployeeSales({
    required this.employeeName,
    required this.invoiceCount,
    required this.totalSales,
  });

  factory EmployeeSales.fromMap(Map<String, Object?> map) {
    return EmployeeSales(
      employeeName: map['employee_name'] as String? ?? '',
      invoiceCount: map['invoice_count'] as int? ?? 0,
      totalSales: (map['total_sales'] as num?)?.toDouble() ?? 0,
    );
  }
}

class ProductQuantity {
  final String productName;
  final double quantity;

  const ProductQuantity({required this.productName, required this.quantity});

  factory ProductQuantity.fromMap(Map<String, Object?> map) {
    return ProductQuantity(
      productName: map['name'] as String? ?? '',
      quantity: (map['total_qty'] as num?)?.toDouble() ?? 0,
    );
  }
}

class DailySales {
  final String date;
  final double totalSales;

  const DailySales({required this.date, required this.totalSales});

  factory DailySales.fromMap(Map<String, Object?> map) {
    return DailySales(
      date: map['day'] as String? ?? '',
      totalSales: (map['total_sales'] as num?)?.toDouble() ?? 0,
    );
  }
}

class ProfitRow {
  final String productName;
  final double totalQty;
  final double totalSales;
  final double totalCost;
  final double profit;

  const ProfitRow({
    required this.productName,
    required this.totalQty,
    required this.totalSales,
    required this.totalCost,
    required this.profit,
  });

  factory ProfitRow.fromMap(Map<String, Object?> map) {
    return ProfitRow(
      productName: map['product_name'] as String? ?? '',
      totalQty: (map['total_qty'] as num?)?.toDouble() ?? 0,
      totalSales: (map['total_sales'] as num?)?.toDouble() ?? 0,
      totalCost: (map['total_cost'] as num?)?.toDouble() ?? 0,
      profit: (map['profit'] as num?)?.toDouble() ?? 0,
    );
  }
}
