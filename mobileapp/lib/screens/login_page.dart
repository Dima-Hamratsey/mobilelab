import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mobileapp/cubits/login_cubit.dart';
import 'package:mobileapp/network/network_status_service.dart';
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
  bool _isCheckingSession = true;

  @override
  void initState() {
    super.initState();
    _tryAutoLogin();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _tryAutoLogin() async {
    final authService = context.read<AuthService>();
    final networkStatus = context.read<NetworkStatusService>();
    final sessionUser = await authService.getSessionUser();
    if (!mounted) {
      return;
    }

    if (sessionUser == null) {
      setState(() {
        _isCheckingSession = false;
      });
      return;
    }

    final isOnline = await networkStatus.isOnline();
    if (!mounted) {
      return;
    }

    Navigator.pushReplacementNamed(
      context,
      '/home',
      arguments: {'offline': !isOnline},
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    await context.read<LoginCubit>().login(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Вкажіть пошту';
    }
    final isValid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    if (!isValid) {
      return 'Некоректна пошта';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) {
      return 'Вкажіть пароль';
    }
    if (password.length < 8) {
      return 'Мінімум 8 символів';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == LoginStatus.failure) {
          final message = switch (state.failureReason) {
            LoginFailureReason.offline => 'Немає інтернету для входу.',
            LoginFailureReason.invalidCredentials =>
              'Невірна пошта або пароль.',
            _ => 'Помилка входу.',
          };
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
          context.read<LoginCubit>().resetStatus();
        }
        if (state.status == LoginStatus.success) {
          context.read<LoginCubit>().resetStatus();
          Navigator.pushReplacementNamed(context, '/home');
        }
      },
      child: BlocBuilder<LoginCubit, LoginState>(
        builder: (context, state) {
          final isLoading = state.status == LoginStatus.loading;
          if (_isCheckingSession) {
            return const GoldScaffold(
              title: 'Вхід',
              child: Center(child: CircularProgressIndicator()),
            );
          }

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
                            validator: _validateEmail,
                          ),
                          const SizedBox(height: 12),
                          GoldTextField(
                            label: 'Пароль',
                            hint: 'Мінімум 8 символів',
                            prefixIcon: Icons.lock_outline,
                            obscureText: true,
                            controller: _passwordController,
                            validator: _validatePassword,
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: isLoading ? null : _handleLogin,
                            icon: isLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.login),
                            label: Text(
                              isLoading ? 'Перевірка...' : 'Увійти',
                            ),
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
        },
      ),
    );
  }
}
