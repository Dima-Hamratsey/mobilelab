import 'package:flutter/material.dart';

import 'package:mobileapp/repositories/local_auth_repository.dart';
import 'package:mobileapp/services/auth_service.dart';
import 'package:mobileapp/widgets/coin_badge.dart';
import 'package:mobileapp/widgets/gold_panel.dart';
import 'package:mobileapp/widgets/gold_scaffold.dart';
import 'package:mobileapp/widgets/gold_text_field.dart';
import 'package:mobileapp/widgets/section_title.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService(
    repository: LocalAuthRepository(),
  );

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    await _authService.register(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });

    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return GoldScaffold(
      title: 'Реєстрація',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            const Center(child: CoinBadge()),
            const SizedBox(height: 16),
            const SectionTitle(
              title: 'Створіть акаунт',
              subtitle: 'Підключіть свої майнінг-станції.',
            ),
            const SizedBox(height: 16),
            GoldPanel(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    GoldTextField(
                      label: "Повне ім'я",
                      prefixIcon: Icons.person_outline,
                      controller: _nameController,
                      validator: _authService.validateName,
                    ),
                    const SizedBox(height: 12),
                    GoldTextField(
                      label: 'Пошта',
                      hint: 'operator@gmail.com',
                      prefixIcon: Icons.alternate_email,
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController,
                      validator: _authService.validateEmail,
                    ),
                    const SizedBox(height: 12),
                    GoldTextField(
                      label: 'Пароль',
                      hint: 'Створіть надійний пароль',
                      prefixIcon: Icons.lock_outline,
                      obscureText: true,
                      controller: _passwordController,
                      validator: _authService.validatePassword,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _isLoading ? null : _handleRegister,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.person_add_alt_1),
                      label: Text(
                        _isLoading ? 'Створення...' : 'Створити акаунт',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Вже є акаунт?'),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Увійти'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
