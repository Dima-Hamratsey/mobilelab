import 'package:flutter/material.dart';

import 'package:mobileapp/repositories/local_auth_repository.dart';
import 'package:mobileapp/services/auth_service.dart';
import 'package:mobileapp/widgets/coin_badge.dart';
import 'package:mobileapp/widgets/gold_panel.dart';
import 'package:mobileapp/widgets/gold_scaffold.dart';
import 'package:mobileapp/widgets/gold_text_field.dart';
import 'package:mobileapp/widgets/section_title.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService(
    repository: LocalAuthRepository(),
  );

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    final user = await _authService.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Невірна пошта або пароль.')),
      );
      return;
    }

    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return GoldScaffold(
      title: 'Вхід',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            const Center(child: CoinBadge()),
            const SizedBox(height: 16),
            const SectionTitle(
              title: 'Логін в додаток',
            ),
            const SizedBox(height: 16),
            GoldPanel(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    GoldTextField(
                      label: 'Пошта',
                      hint: 'operator@vault.io',
                      prefixIcon: Icons.alternate_email,
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController,
                      validator: _authService.validateEmail,
                    ),
                    const SizedBox(height: 12),
                    GoldTextField(
                      label: 'Пароль',
                      hint: 'Мінімум 8 символів',
                      prefixIcon: Icons.lock_outline,
                      obscureText: true,
                      controller: _passwordController,
                      validator: _authService.validatePassword,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _isLoading ? null : _handleLogin,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.login),
                      label: Text(_isLoading ? 'Перевірка...' : 'Увійти'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text('Реєстрація'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
