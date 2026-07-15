import 'package:flutter/material.dart';

import 'screens/login_screen.dart';

void main() {
  runApp(const AlWaleedApp());
}

class AlWaleedApp extends StatelessWidget {
  const AlWaleedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AL-WALEED Coffee Manager',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6D4C41)),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: const LoginScreen(),
    );
  }
}
