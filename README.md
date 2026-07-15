# AL-WALEED Coffee Manager (Flutter)

Flutter/Dart migration of the [AL-WALEED JavaFX coffee shop manager](https://github.com/ahmedsameh20/AL-WALEED), targeting Android and iOS.

## Status

Skeleton in progress. Working so far:

- SQLite schema ported to `sqflite` ([lib/db/db_helper.dart](lib/db/db_helper.dart)), seeded with the same default owner accounts as `setup.sql`
- Login screen with مدير/عامل (owner/seller) toggle, matching the original JavaFX `LoginScreen`
- Placeholder owner/seller dashboards after login

Not yet ported: products, invoices, employees, expenses, logs, notes chat, reports, AI chat panel.

## Requirements

- Flutter 3.32+ / Dart 3.8+
- Android Studio / Xcode for platform builds

## Running

```bash
flutter pub get
flutter run
```

Default seeded accounts (owner role): `ahmed` / `1234`, `sameh` / `1234`.
