import 'package:flutter/material.dart';

import 'package:mobileapp/widgets/coin_badge.dart';
import 'package:mobileapp/widgets/gold_panel.dart';
import 'package:mobileapp/widgets/gold_scaffold.dart';
import 'package:mobileapp/widgets/metric_card.dart';
import 'package:mobileapp/widgets/metric_grid.dart';
import 'package:mobileapp/widgets/profile_tile.dart';
import 'package:mobileapp/widgets/section_title.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GoldScaffold(
      title: 'Профіль',
      actions: [
        IconButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
          icon: const Icon(Icons.home_outlined),
          tooltip: 'Головна',
        ),
      ],
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CoinBadge(size: 64),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Олексій Мороз',
                        style: theme.textTheme.titleLarge),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            const SectionTitle(
              title: 'Дані користувача',
            ),
            const SizedBox(height: 12),
            const GoldPanel(
              child: Column(
                children: [
                  ProfileTile(
                    label: 'Пошта',
                    value: 'operator@vault.io',
                    icon: Icons.alternate_email,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const SectionTitle(
              title: 'Сумарні показники',
            ),
            const SizedBox(height: 12),
            const MetricGrid(
              children: [
                MetricCard(
                  label: 'Загальний хешрейт',
                  value: '281 TH/s',
                  icon: Icons.bolt,
                ),
                MetricCard(
                  label: 'Сер. температура',
                  value: '61 °C',
                  icon: Icons.thermostat,
                ),
                MetricCard(
                  label: 'Добуто сьогодні',
                  value: '0.083 BTC',
                  icon: Icons.monetization_on,
                ),
                MetricCard(
                  label: 'Добуто сьогодні, \$',
                  value: '6 640 \$',
                  icon: Icons.attach_money,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const SectionTitle(
              title: 'Додати станцію',
            ),
            const SizedBox(height: 12),
            GoldPanel(
              child: Column(
                children: [
                  FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Додати станцію'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/');
              },
              child: const Text('Вийти'),
            ),
          ],
        ),
      ),
    );
  }
}
