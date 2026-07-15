import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends ChangeNotifier {
  LocaleController._();
  static final LocaleController instance = LocaleController._();

  static const _prefsKey = 'language';

  String _language = 'ar';
  String get language => _language;
  bool get isArabic => _language == 'ar';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _language = prefs.getString(_prefsKey) ?? 'ar';
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    if (lang == _language) return;
    _language = lang;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, lang);
  }
}

/// Lightweight string lookup keyed by the current [LocaleController] language.
class S {
  S._();

  static String t(String key) {
    final lang = LocaleController.instance.language;
    return _strings[key]?[lang] ?? key;
  }

  /// Displays a stored product `type` value ('بن' / 'أكواب' / 'توليفة')
  /// translated for the current language. The underlying stored value is
  /// never changed, since it's used in queries/comparisons.
  static String paymentMethod(String method) {
    switch (method) {
      case 'card':
        return t('payment_card');
      case 'wallet':
        return t('payment_wallet');
      case 'cash':
      default:
        return t('payment_cash');
    }
  }

  static String productType(String dbType) {
    switch (dbType) {
      case 'بن':
        return t('type_beans');
      case 'أكواب':
        return t('type_cups');
      case 'توليفة':
        return t('type_blend');
      default:
        return dbType;
    }
  }

  static const Map<String, Map<String, String>> _strings = {
    // Common
    'cancel': {'ar': 'إلغاء', 'en': 'Cancel'},
    'delete': {'ar': 'حذف', 'en': 'Delete'},
    'save': {'ar': 'حفظ', 'en': 'Save'},
    'add': {'ar': 'إضافة', 'en': 'Add'},
    'yes': {'ar': 'نعم', 'en': 'Yes'},
    'no': {'ar': 'لا', 'en': 'No'},
    'confirm_delete': {'ar': 'تأكيد الحذف', 'en': 'Confirm Delete'},
    'confirm_delete_item_prefix': {'ar': 'هل تريد حذف', 'en': 'Delete'},
    'name': {'ar': 'الاسم', 'en': 'Name'},
    'type': {'ar': 'النوع', 'en': 'Type'},
    'type_beans': {'ar': 'بن', 'en': 'Beans'},
    'type_cups': {'ar': 'أكواب', 'en': 'Cups'},
    'type_blend': {'ar': 'توليفة', 'en': 'Blend'},
    'currency': {'ar': 'جنيه', 'en': 'EGP'},
    'total_colon': {'ar': 'الإجمالي:', 'en': 'Total:'},

    // Login
    'login_title': {'ar': 'تسجيل الدخول', 'en': 'Login'},
    'role_owner': {'ar': 'مدير', 'en': 'Manager'},
    'role_seller': {'ar': 'عامل', 'en': 'Seller'},
    'business_owner_label': {'ar': 'المالك', 'en': 'Owner'},
    'username': {'ar': 'اسم المستخدم', 'en': 'Username'},
    'password': {'ar': 'كلمة السر', 'en': 'Password'},
    'err_enter_credentials': {
      'ar': 'أدخل اسم المستخدم وكلمة السر',
      'en': 'Enter username and password',
    },
    'err_invalid_credentials': {
      'ar': 'بيانات غير صحيحة أو الحساب غير مفعل',
      'en': 'Invalid credentials or inactive account',
    },

    // Dashboards
    'welcome': {'ar': 'أهلاً', 'en': 'Welcome'},
    'dashboard_title_owner': {'ar': 'لوحة المدير', 'en': 'Manager Dashboard'},
    'dashboard_title_seller': {'ar': 'لوحة العامل', 'en': 'Seller Dashboard'},
    'nav_orders': {'ar': 'تسجيل الطلب', 'en': 'New Order'},
    'nav_products': {'ar': 'المنتجات', 'en': 'Products'},
    'nav_employees': {'ar': 'الموظفين', 'en': 'Employees'},
    'nav_promo_codes': {'ar': 'أكواد الخصم', 'en': 'Promo Codes'},
    'nav_invoices': {'ar': 'الفواتير', 'en': 'Invoices'},
    'nav_blends': {'ar': 'توليفات البن', 'en': 'Coffee Blends'},
    'nav_expenses': {'ar': 'المصروفات', 'en': 'Expenses'},
    'nav_sales': {'ar': 'المبيعات', 'en': 'Sales'},
    'nav_profits': {'ar': 'الأرباح', 'en': 'Profits'},
    'nav_logs': {'ar': 'السجل', 'en': 'Logs'},
    'nav_notes': {'ar': 'المحادثة', 'en': 'Chat'},
    'nav_settings': {'ar': 'الإعدادات', 'en': 'Settings'},
    'section_operations': {'ar': 'العمليات اليومية', 'en': 'Daily Operations'},
    'section_management': {'ar': 'الإدارة', 'en': 'Management'},
    'section_finance': {'ar': 'المالية والتقارير', 'en': 'Finance & Reports'},
    'section_more': {'ar': 'المزيد', 'en': 'More'},
    'log_out': {'ar': 'تسجيل الخروج', 'en': 'Log Out'},

    // Products
    'products_title': {'ar': 'إدارة المنتجات', 'en': 'Manage Products'},
    'product_name': {'ar': 'اسم المنتج', 'en': 'Product Name'},
    'buy_price': {'ar': 'سعر الشراء', 'en': 'Buy Price'},
    'sell_price': {'ar': 'سعر البيع', 'en': 'Sell Price'},
    'quantity': {'ar': 'الكمية', 'en': 'Quantity'},
    'edit_product': {'ar': 'تعديل المنتج', 'en': 'Edit Product'},
    'initial_quantity': {'ar': 'الكمية الأصلية', 'en': 'Initial Quantity'},
    'remaining_quantity': {'ar': 'الكمية المتبقية', 'en': 'Remaining Quantity'},
    'no_products_yet': {'ar': 'لا توجد منتجات بعد', 'en': 'No products yet'},
    'err_fill_fields_correctly': {
      'ar': 'تأكد من إدخال كل الحقول بشكل صحيح.',
      'en': 'Make sure all fields are filled correctly.',
    },
    'err_price_must_be_positive': {
      'ar': 'الأسعار يجب أن تكون أكبر من صفر.',
      'en': 'Prices must be greater than zero.',
    },
    'err_quantity_negative': {
      'ar': 'الكمية لا يمكن أن تكون سالبة.',
      'en': 'Quantity cannot be negative.',
    },
    'product_added': {'ar': 'تم إضافة المنتج', 'en': 'Product added'},
    'product_deleted': {'ar': 'تم حذف المنتج', 'en': 'Product deleted'},
    'err_edit_fields': {
      'ar': 'خطأ أثناء التعديل: تأكد من الحقول',
      'en': 'Error while editing: check the fields',
    },
    'buy_label': {'ar': 'شراء', 'en': 'Buy'},
    'sell_label': {'ar': 'بيع', 'en': 'Sell'},
    'remaining_label': {'ar': 'متبقي', 'en': 'Remaining'},
    'initial_label': {'ar': 'أصلي', 'en': 'Initial'},
    'cost_label': {'ar': 'تكلفة', 'en': 'Cost'},
    'remaining_value_label': {'ar': 'قيمة متبقية', 'en': 'Remaining value'},
    'sold_value_label': {'ar': 'قيمة مباعة', 'en': 'Sold value'},

    // Employees
    'employees_title': {'ar': 'إدارة الموظفين', 'en': 'Manage Employees'},
    'worker_name': {'ar': 'اسم العامل', 'en': 'Worker Name'},
    'salary': {'ar': 'المرتب', 'en': 'Salary'},
    'save_edit': {'ar': 'حفظ التعديل', 'en': 'Save Changes'},
    'hire': {'ar': 'توظيف', 'en': 'Hire'},
    'no_employees_yet': {'ar': 'لا يوجد موظفون بعد', 'en': 'No employees yet'},
    'err_all_fields_required': {
      'ar': 'كل الحقول مطلوبة.',
      'en': 'All fields are required.',
    },
    'err_salary_must_be_number': {
      'ar': 'المرتب يجب أن يكون رقمًا.',
      'en': 'Salary must be a number.',
    },
    'err_salary_must_be_positive': {
      'ar': 'المرتب يجب أن يكون أكبر من صفر.',
      'en': 'Salary must be greater than zero.',
    },
    'password_optional_hint': {
      'ar': 'اتركه فارغًا للإبقاء على كلمة السر الحالية',
      'en': 'Leave blank to keep current password',
    },
    'employee_hired_prefix': {'ar': 'تم توظيف', 'en': 'Hired'},
    'employee_updated': {
      'ar': 'تم تعديل الموظف بنجاح.',
      'en': 'Employee updated successfully.',
    },
    'err_operation_prefix': {
      'ar': 'حدث خطأ أثناء العملية:',
      'en': 'An error occurred:',
    },
    'active': {'ar': 'مفعل', 'en': 'Active'},
    'inactive': {'ar': 'معطل', 'en': 'Inactive'},
    'salary_label': {'ar': 'مرتب', 'en': 'Salary'},
    'username_label': {'ar': 'مستخدم', 'en': 'Username'},
    'toggle_active': {'ar': 'تفعيل/تعطيل', 'en': 'Activate/Deactivate'},

    // Orders
    'orders_title': {'ar': 'تسجيل الطلب', 'en': 'New Order'},
    'product': {'ar': 'المنتج', 'en': 'Product'},
    'add_short': {'ar': 'أضف', 'en': 'Add'},
    'no_products_added_yet': {
      'ar': 'لم تتم إضافة منتجات بعد',
      'en': 'No products added yet',
    },
    'customer_name': {'ar': 'اسم العميل', 'en': 'Customer Name'},
    'phone': {'ar': 'رقم الهاتف', 'en': 'Phone Number'},
    'subtotal': {'ar': 'الإجمالي الفرعي', 'en': 'Subtotal'},
    'vat_label': {'ar': 'ضريبة القيمة المضافة', 'en': 'VAT'},
    'promo_code_hint': {'ar': 'كود الخصم (اختياري)', 'en': 'Promo code (optional)'},
    'apply_code': {'ar': 'تطبيق', 'en': 'Apply'},
    'remove_code': {'ar': 'إزالة', 'en': 'Remove'},
    'discount_label': {'ar': 'الخصم', 'en': 'Discount'},
    'invalid_promo_code': {'ar': 'كود الخصم غير صالح', 'en': 'Invalid promo code'},
    'promo_code_applied': {'ar': 'تم تطبيق كود الخصم.', 'en': 'Promo code applied.'},
    'payment_method_label': {'ar': 'طريقة الدفع', 'en': 'Payment Method'},
    'payment_cash': {'ar': 'نقدًا', 'en': 'Cash'},
    'payment_card': {'ar': 'بطاقة', 'en': 'Card'},
    'payment_wallet': {'ar': 'محفظة إلكترونية', 'en': 'Mobile Wallet'},
    'total': {'ar': 'الإجمالي', 'en': 'Total'},
    'confirm_order': {'ar': 'تأكيد الطلب', 'en': 'Confirm Order'},
    'err_select_product': {'ar': 'اختر منتجًا', 'en': 'Select a product'},
    'err_no_decimal_cups': {
      'ar': 'لا يمكن إدخال كميات عشرية للأكواب',
      'en': 'Cups quantity must be a whole number',
    },
    'err_enter_valid_quantity': {
      'ar': 'تأكد من إدخال الكمية بشكل صحيح',
      'en': 'Make sure the quantity is valid',
    },
    'err_no_products_added': {
      'ar': 'لم تقم بإضافة أي منتجات!',
      'en': "You haven't added any products!",
    },
    'err_invalid_phone': {
      'ar': 'رقم الهاتف غير صالح',
      'en': 'Invalid phone number',
    },
    'order_saved_prefix': {
      'ar': 'تم حفظ الفاتورة بنجاح (رقم',
      'en': 'Order saved successfully (invoice #',
    },
    'order_failed': {
      'ar': 'فشل في حفظ الطلب (تأكد من توفر الكمية)',
      'en': 'Failed to save the order (check stock availability)',
    },
    'price_label': {'ar': 'سعر', 'en': 'Price'},

    // Invoices
    'invoices_title': {'ar': 'فواتير الطلبات', 'en': 'Order Invoices'},
    'search_invoices_hint': {
      'ar': 'بحث برقم الفاتورة أو اسم العميل أو الهاتف',
      'en': 'Search by invoice number, customer, or phone',
    },
    'no_invoices': {'ar': 'لا توجد فواتير', 'en': 'No invoices'},
    'edit_note': {'ar': 'تعديل الملاحظة', 'en': 'Edit Note'},
    'write_note_hint': {'ar': 'اكتب الملاحظة', 'en': 'Write the note'},
    'confirm_delete_invoice_prefix': {
      'ar': 'تأكيد حذف الفاتورة #',
      'en': 'Confirm deleting invoice #',
    },
    'note_button': {'ar': 'ملاحظة', 'en': 'Note'},
    'print_button': {'ar': 'طباعة', 'en': 'Print'},
    'invoice_hash': {'ar': 'فاتورة #', 'en': 'Invoice #'},
    'customer_label': {'ar': 'العميل', 'en': 'Customer'},
    'phone_label': {'ar': 'الهاتف', 'en': 'Phone'},
    'employee_label': {'ar': 'الموظف', 'en': 'Employee'},
    'note_label': {'ar': 'ملاحظة', 'en': 'Note'},
    'print_preview_shop': {'ar': 'مطحن الوليد للبن', 'en': 'Al-Waleed Coffee Mill'},
    'invoice_number_label': {'ar': 'رقم الفاتورة', 'en': 'Invoice Number'},
    'date_label': {'ar': 'التاريخ', 'en': 'Date'},
    'time_label': {'ar': 'الساعة', 'en': 'Time'},
    'products_label': {'ar': 'المنتجات', 'en': 'Products'},
    'notes_label': {'ar': 'ملاحظات', 'en': 'Notes'},
    'no_mobile_print': {
      'ar': 'لا تتوفر طباعة مباشرة على الجوال — استخدم لقطة شاشة أو المشاركة.',
      'en': "Direct printing isn't available on mobile — use a screenshot or share instead.",
    },

    // Expenses
    'expenses_title': {'ar': 'إدارة المصروفات', 'en': 'Manage Expenses'},
    'amount': {'ar': 'المبلغ', 'en': 'Amount'},
    'note': {'ar': 'ملاحظة', 'en': 'Note'},
    'no_expenses_yet': {'ar': 'لا توجد مصروفات بعد', 'en': 'No expenses yet'},
    'err_invalid_amount': {'ar': 'المبلغ غير صالح', 'en': 'Invalid amount'},
    'err_amount_must_be_positive': {
      'ar': 'المبلغ يجب أن يكون أكبر من صفر.',
      'en': 'Amount must be greater than zero.',
    },
    'confirm_delete_expense_prefix': {'ar': 'حذف مصروف #', 'en': 'Delete expense #'},
    'confirm_delete_expense_value': {'ar': 'بقيمة', 'en': 'worth'},
    'total_expenses': {'ar': 'إجمالي المصروفات', 'en': 'Total Expenses'},

    // Sales report
    'sales_report_title': {
      'ar': 'تقرير المبيعات حسب الموظف',
      'en': 'Sales Report by Employee',
    },
    'period': {'ar': 'الفترة', 'en': 'Period'},
    'period_hour': {'ar': 'آخر ساعة', 'en': 'Last hour'},
    'period_today': {'ar': 'اليوم', 'en': 'Today'},
    'period_week': {'ar': 'آخر 7 أيام', 'en': 'Last 7 days'},
    'period_month': {'ar': 'آخر 30 يوم', 'en': 'Last 30 days'},
    'period_year': {'ar': 'آخر سنة', 'en': 'Last year'},
    'no_sales_in_period': {
      'ar': 'لا توجد مبيعات في هذه الفترة',
      'en': 'No sales in this period',
    },
    'invoice_count_label': {'ar': 'عدد الفواتير', 'en': 'Invoice count'},
    'show_quantities_sold': {'ar': 'عرض الكميات المباعة', 'en': 'Show quantities sold'},
    'quantities_by_product': {
      'ar': 'الكميات المباعة حسب المنتج',
      'en': 'Quantities sold by product',
    },
    'no_data': {'ar': 'لا توجد بيانات', 'en': 'No data'},
    'sales_trend_title': {'ar': 'اتجاه المبيعات آخر', 'en': 'Sales Trend — Last'},
    'days_label': {'ar': 'أيام', 'en': 'days'},

    // Profit report
    'profit_report_title': {
      'ar': 'تقرير الأرباح حسب المنتج',
      'en': 'Profit Report by Product',
    },
    'no_profit_data_yet': {'ar': 'لا توجد بيانات أرباح بعد', 'en': 'No profit data yet'},
    'profit_by_product_chart_title': {'ar': 'الأرباح حسب المنتج', 'en': 'Profit by Product'},
    'quantity_label': {'ar': 'الكمية', 'en': 'Quantity'},
    'sell_total_label': {'ar': 'البيع', 'en': 'Sales'},
    'cost_total_label': {'ar': 'التكلفة', 'en': 'Cost'},
    'profit_label': {'ar': 'الربح', 'en': 'Profit'},

    // Logs
    'logs_title': {'ar': 'سجل العمليات', 'en': 'Activity Log'},
    'no_logs_yet': {'ar': 'لا يوجد سجل عمليات بعد', 'en': 'No activity logs yet'},

    // Blends
    'blends_title': {'ar': 'إنشاء توليفة بن', 'en': 'Create Coffee Blend'},
    'no_beans_available': {
      'ar': 'لا يوجد بن متاح حاليًا',
      'en': 'No beans available right now',
    },
    'available_label': {'ar': 'متوفر', 'en': 'Available'},
    'used_label': {'ar': 'مستخدم', 'en': 'Used'},
    'blend_name': {'ar': 'اسم التوليفة', 'en': 'Blend Name'},
    'blend_quantity_kg': {'ar': 'الكمية (كجم)', 'en': 'Quantity (kg)'},
    'sell_price_optional': {'ar': 'سعر البيع (اختياري)', 'en': 'Sell price (optional)'},
    'create_blend': {'ar': 'إنشاء التوليفة', 'en': 'Create Blend'},
    'err_enter_valid_quantity_blend': {
      'ar': 'أدخل كمية صحيحة (مثلاً 1 أو 2)',
      'en': 'Enter a valid quantity (e.g. 1 or 2)',
    },
    'err_enter_blend_name': {'ar': 'أدخل اسم التوليفة', 'en': 'Enter the blend name'},
    'err_quantity_sum_mismatch_prefix': {
      'ar': 'مجموع الكميات يجب أن يكون',
      'en': 'The total quantity must be',
    },
    'err_quantity_sum_mismatch_kg_now': {'ar': 'كجم (الآن:', 'en': 'kg (currently:'},
    'err_invalid_sell_price': {'ar': 'سعر البيع غير صالح', 'en': 'Invalid sell price'},
    'blend_created_prefix': {
      'ar': 'تم تسجيل التوليفة كفاتورة داخلية برقم:',
      'en': 'Blend recorded as internal invoice #',
    },
    'blend_failed': {
      'ar': 'حدث خطأ أثناء إنشاء التوليفة (تأكد من توفر الكميات)',
      'en': 'Failed to create the blend (check component availability)',
    },

    // Notes / Chat
    'chat_title': {'ar': 'المحادثة', 'en': 'Chat'},
    'no_other_employees': {'ar': 'لا يوجد موظفون آخرون', 'en': 'No other employees'},
    'no_messages_yet': {'ar': 'لا توجد رسائل بعد', 'en': 'No messages yet'},
    'message_hint': {'ar': 'اكتب رسالتك هنا...', 'en': 'Type your message here...'},

    // Settings
    'settings_title': {'ar': 'الإعدادات', 'en': 'Settings'},
    'choose_section': {'ar': 'اختر القسم:', 'en': 'Choose section:'},
    'section_invoices': {'ar': 'الفواتير', 'en': 'Invoices'},
    'section_orders': {'ar': 'الطلبات', 'en': 'Orders'},
    'section_products': {'ar': 'المنتجات', 'en': 'Products'},
    'section_expenses': {'ar': 'المصروفات', 'en': 'Expenses'},
    'reset': {'ar': 'ريست', 'en': 'Reset'},
    'confirm_delete_section_prefix': {
      'ar': 'سيتم حذف كل بيانات',
      'en': 'This will permanently delete all',
    },
    'confirm_delete_section_suffix': {
      'ar': 'نهائيًا. هل أنت متأكد؟',
      'en': 'data. Are you sure?',
    },
    'section_deleted_prefix': {'ar': 'تم حذف بيانات', 'en': 'Deleted'},
    'section_deleted_suffix': {'ar': 'بنجاح.', 'en': 'data successfully.'},
    'language': {'ar': 'اللغة', 'en': 'Language'},
    'arabic': {'ar': 'العربية', 'en': 'Arabic'},
    'english': {'ar': 'الإنجليزية', 'en': 'English'},
    'vat_rate_label': {'ar': 'نسبة ضريبة القيمة المضافة (%)', 'en': 'VAT Rate (%)'},
    'vat_rate_hint': {
      'ar': 'تُطبّق على كل الطلبات الجديدة',
      'en': 'Applied to all new orders',
    },
    'save_vat_rate': {'ar': 'حفظ النسبة', 'en': 'Save Rate'},
    'err_invalid_vat_rate': {
      'ar': 'أدخل نسبة ضريبة صحيحة (0-100)',
      'en': 'Enter a valid VAT rate (0-100)',
    },
    'vat_rate_saved': {'ar': 'تم حفظ نسبة الضريبة.', 'en': 'VAT rate saved.'},

    // Low stock
    'low_stock_title': {'ar': 'تنبيه: مخزون منخفض', 'en': 'Low Stock Alert'},
    'low_stock_threshold_label': {'ar': 'حد المخزون المنخفض', 'en': 'Low Stock Threshold'},
    'low_stock_threshold_hint': {
      'ar': 'تنبيه عند وصول كمية منتج إلى هذا الحد أو أقل',
      'en': 'Alert when a product quantity drops to this or below',
    },
    'save_threshold': {'ar': 'حفظ الحد', 'en': 'Save Threshold'},
    'err_invalid_threshold': {
      'ar': 'أدخل رقمًا صحيحًا أكبر من أو يساوي صفر',
      'en': 'Enter a valid number (0 or greater)',
    },
    'threshold_saved': {'ar': 'تم حفظ الحد.', 'en': 'Threshold saved.'},
    'low_stock_badge': {'ar': 'مخزون منخفض', 'en': 'Low stock'},
    'low_stock_banner_prefix': {'ar': 'تنبيه: مخزون منخفض على', 'en': 'Low stock on'},
    'low_stock_banner_suffix': {'ar': 'منتج', 'en': 'product(s)'},

    // Promo codes
    'promo_codes_title': {'ar': 'أكواد الخصم', 'en': 'Promo Codes'},
    'add_promo_code': {'ar': 'إضافة كود', 'en': 'Add Code'},
    'code_label': {'ar': 'الكود', 'en': 'Code'},
    'type_label': {'ar': 'النوع', 'en': 'Type'},
    'type_percentage': {'ar': 'نسبة مئوية', 'en': 'Percentage'},
    'type_fixed': {'ar': 'مبلغ ثابت', 'en': 'Fixed amount'},
    'value_label': {'ar': 'القيمة', 'en': 'Value'},
    'no_promo_codes': {'ar': 'لا توجد أكواد خصم بعد', 'en': 'No promo codes yet'},
    'err_code_required': {'ar': 'أدخل الكود', 'en': 'Enter a code'},
    'err_value_positive': {'ar': 'أدخل قيمة أكبر من صفر', 'en': 'Enter a value greater than zero'},
    'err_code_exists': {'ar': 'هذا الكود مستخدم بالفعل', 'en': 'This code already exists'},
    'code_added': {'ar': 'تم إضافة الكود بنجاح.', 'en': 'Code added successfully.'},
    'confirm_delete_code_prefix': {'ar': 'هل تريد حذف الكود', 'en': 'Delete the code'},
    'active_label': {'ar': 'مفعل', 'en': 'Active'},
    'inactive_label': {'ar': 'غير مفعل', 'en': 'Inactive'},
  };
}
