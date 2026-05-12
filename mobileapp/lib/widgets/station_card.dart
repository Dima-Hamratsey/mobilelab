import 'package:flutter/material.dart';

import 'package:mobileapp/widgets/gold_panel.dart';
import 'package:mobileapp/widgets/metric_pill.dart';

class StationCard extends StatelessWidget {
  const StationCard({
    required this.name,
    required this.location,
    required this.temperature,
    required this.load,
    required this.hashrate,
    required this.mined,
    super.key,
  });

  final String name;
  final String location;
  final String temperature;
  final String load;
  final String hashrate;
  final String mined;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return GoldPanel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: theme.textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            location,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              MetricPill(
                label: 'Темп',
                value: temperature,
                icon: Icons.thermostat,
              ),
              MetricPill(
                label: 'Навантаж',
                value: load,
                icon: Icons.speed,
              ),
              MetricPill(
                label: 'Хешрейт',
                value: hashrate,
                icon: Icons.bolt,
              ),
              MetricPill(
                label: 'Добуто',
                value: mined,
                icon: Icons.monetization_on,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
