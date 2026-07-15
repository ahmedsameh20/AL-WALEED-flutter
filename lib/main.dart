import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/app_strings.dart';
import 'screens/login_screen.dart';
import 'utils/app_settings.dart';

void main() {
  runApp(const AlWaleedApp());
}

class AlWaleedApp extends StatefulWidget {
  const AlWaleedApp({super.key});

  @override
  State<AlWaleedApp> createState() => _AlWaleedAppState();
}

class _AlWaleedAppState extends State<AlWaleedApp> {
  @override
  void initState() {
    super.initState();
    LocaleController.instance.addListener(_onLocaleChanged);
    LocaleController.instance.load();
    AppSettings.instance.load();
  }

  @override
  void dispose() {
    LocaleController.instance.removeListener(_onLocaleChanged);
    super.dispose();
  }

  void _onLocaleChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = LocaleController.instance.isArabic;

    return MaterialApp(
      title: 'AL-WALEED Coffee Manager',
      debugShowCheckedModeBanner: false,
      locale: Locale(isArabic ? 'ar' : 'en'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6D4C41)),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        );
      },
      home: const LoginScreen(),
    );
  }
}
