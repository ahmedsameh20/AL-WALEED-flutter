import 'package:flutter/material.dart';

import '../utils/app_session.dart';
import 'login_screen.dart';

class SellerDashboard extends StatelessWidget {
  const SellerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة العامل'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              AppSession.instance.logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          'أهلاً ${AppSession.instance.currentEmployeeName} (عامل)\nقيد الإنشاء...',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
