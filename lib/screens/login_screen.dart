import 'package:flutter/material.dart';

import '../db/user_dao.dart';
import '../utils/app_session.dart';
import 'owner_dashboard.dart';
import 'seller_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  String _userType = 'owner';
  String? _message;
  bool _loading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() => _message = '⚠️ أدخل اسم المستخدم وكلمة السر');
      return;
    }

    setState(() {
      _loading = true;
      _message = null;
    });

    final employee = await UserDAO.login(username, password);

    if (!mounted) return;
    setState(() => _loading = false);

    if (employee == null) {
      setState(() => _message = '❌ بيانات غير صحيحة أو الحساب غير مفعل');
      return;
    }

    final isOwner = _userType == 'owner';
    AppSession.instance.login(employee.id, employee.name, isOwner);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => isOwner ? const OwnerDashboard() : const SellerDashboard(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEBE9),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'تسجيل الدخول',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 20),
                  ToggleButtons(
                    isSelected: [_userType == 'owner', _userType == 'seller'],
                    onPressed: (index) {
                      setState(() => _userType = index == 0 ? 'owner' : 'seller');
                    },
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Text('مدير'),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Text('عامل'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'اسم المستخدم',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'كلمة السر',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _login(),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6D4C41),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _loading ? null : _login,
                      child: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('تسجيل الدخول'),
                    ),
                  ),
                  if (_message != null) ...[
                    const SizedBox(height: 12),
                    Text(_message!, style: const TextStyle(color: Colors.red)),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
