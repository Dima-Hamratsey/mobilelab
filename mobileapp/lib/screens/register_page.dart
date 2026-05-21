import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobileapp/cubits/register_cubit.dart';
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
    await context.read<RegisterCubit>().register(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) {
      return 'Вкажіть ім\'я';
    }
    if (RegExp(r'\d').hasMatch(name)) {
      return 'Ім\'я не може містити цифри';
    }
    return null;
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
    return BlocListener<RegisterCubit, RegisterState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == RegisterStatus.failure) {
          final message =
              state.errorMessage ?? 'Не вдалося зареєструватися.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Помилка: $message')),
          );
          context.read<RegisterCubit>().resetStatus();
        }
        if (state.status == RegisterStatus.success) {
          context.read<RegisterCubit>().resetStatus();
          Navigator.pushReplacementNamed(context, '/home');
        }
      },
      child: BlocBuilder<RegisterCubit, RegisterState>(
        builder: (context, state) {
          final isLoading = state.status == RegisterStatus.loading;
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
                            validator: _validateName,
                          ),
                          const SizedBox(height: 12),
                          GoldTextField(
                            label: 'Пошта',
                            hint: 'operator@gmail.com',
                            prefixIcon: Icons.alternate_email,
                            keyboardType: TextInputType.emailAddress,
                            controller: _emailController,
                            validator: _validateEmail,
                          ),
                          const SizedBox(height: 12),
                          GoldTextField(
                            label: 'Пароль',
                            hint: 'Створіть надійний пароль',
                            prefixIcon: Icons.lock_outline,
                            obscureText: true,
                            controller: _passwordController,
                            validator: _validatePassword,
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: isLoading ? null : _handleRegister,
                            icon: isLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.person_add_alt_1),
                            label: Text(
                              isLoading ? 'Створення...' : 'Створити акаунт',
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
        },
      ),
    );
  }
}
