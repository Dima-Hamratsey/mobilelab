import 'package:flutter/material.dart';
import 'package:mobileapp/widgets/coin_badge.dart';
import 'package:mobileapp/widgets/gold_panel.dart';
import 'package:mobileapp/widgets/gold_scaffold.dart';
import 'package:mobileapp/widgets/gold_text_field.dart';
import 'package:mobileapp/widgets/section_title.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

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
              child: Column(
                children: [
                  const GoldTextField(
                    label: "Повне ім'я",
                    hint: 'Олексій Мороз',
                    prefixIcon: Icons.person_outline,
                  ),
                  const SizedBox(height: 12),
                  const GoldTextField(
                    label: 'Пошта',
                    hint: 'operator@vault.io',
                    prefixIcon: Icons.alternate_email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  const GoldTextField(
                    label: 'Пароль',
                    hint: 'Створіть надійний пароль',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                    icon: const Icon(Icons.person_add_alt_1),
                    label: const Text('Створити акаунт'),
                  ),
                ],
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
