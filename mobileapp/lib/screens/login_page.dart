import 'package:flutter/material.dart';

import 'package:mobileapp/widgets/coin_badge.dart';
import 'package:mobileapp/widgets/gold_panel.dart';
import 'package:mobileapp/widgets/gold_scaffold.dart';
import 'package:mobileapp/widgets/gold_text_field.dart';
import 'package:mobileapp/widgets/section_title.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

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
              child: Column(
                children: [
                  const GoldTextField(
                    label: 'Пошта',
                    hint: 'operator@vault.io',
                    prefixIcon: Icons.alternate_email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  const GoldTextField(
                    label: 'Пароль',
                    hint: 'Мінімум 8 символів',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                    icon: const Icon(Icons.login),
                    label: const Text('Увійти'),
                  ),
                ],
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
