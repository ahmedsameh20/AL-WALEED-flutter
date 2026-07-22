# Elgendy Coffee Manager (Flutter)

A cross-platform (Android/iOS) coffee shop management app, migrated from the original [AL-WALEED JavaFX desktop app](https://github.com/ahmedsameh20/AL-WALEED) to Flutter/Dart. Fully bilingual (Arabic/English) with native RTL support, running entirely offline on a local SQLite database.

## Features

- **Orders & invoices** — take orders, apply promo codes and VAT, print receipts to Bluetooth thermal printers
- **Products & inventory** — manage stock, buy/sell prices, and low-stock alerts; scan or assign barcodes via the device camera
- **Coffee blends** — build custom bean blends from existing inventory
- **Employees & shifts** — manager/seller roles, salted+hashed credentials, clock in/out with shift history and reports
- **Customers & promo codes** — track customer purchase history and manage discount codes
- **Expenses** — log operational expenses
- **Reports** — sales and profit reports, per-employee shift summaries
- **Activity log** — auditable log of logins, orders, and management actions across the app
- **Chat/notes** — internal messaging between employees
- **Settings** — language toggle (ar/en), configurable VAT rate, low-stock threshold, and Bluetooth printer selection

## Tech stack

- Flutter 3.32+ / Dart 3.8+
- `sqflite` — local SQLite persistence
- `mobile_scanner` — camera-based barcode scanning
- `print_bluetooth_thermal` + `esc_pos_utils_plus` — Bluetooth thermal receipt printing
- `flutter_local_notifications` — low-stock alerts
- `fl_chart` — sales/profit charts
- `flutter_localizations` — bilingual Arabic/English UI with RTL layout

## Requirements

- Flutter 3.32+ / Dart 3.8+
- Android Studio / Xcode for platform builds

## Running

```bash
flutter pub get
flutter run
```

Default seeded accounts (owner role): `ahmed` / `1234`, `sameh` / `1234`.
