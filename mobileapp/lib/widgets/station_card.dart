import 'package:flutter/material.dart';

import 'package:mobileapp/models/station.dart';
import 'package:mobileapp/widgets/gold_panel.dart';
import 'package:mobileapp/widgets/metric_pill.dart';

class StationCard extends StatelessWidget {
  const StationCard({
    required this.station,
    super.key,
  });

  final Station station;

  String _formatTemp(double value) => '${value.toStringAsFixed(0)} °C';
  String _formatLoad(double value) => '${value.toStringAsFixed(0)}%';
  String _formatHashrate(double value) => '${value.toStringAsFixed(0)} TH/s';
  String _formatMined(double value) => '${value.toStringAsFixed(3)} BTC';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return GoldPanel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(station.name, style: theme.textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            station.location,
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
                value: _formatTemp(station.metrics.temperatureC),
                icon: Icons.thermostat,
              ),
              MetricPill(
                label: 'Навантаж',
                value: _formatLoad(station.metrics.loadPercent),
                icon: Icons.speed,
              ),
              MetricPill(
                label: 'Хешрейт',
                value: _formatHashrate(station.metrics.hashrateThs),
                icon: Icons.bolt,
              ),
              MetricPill(
                label: 'Добуто',
                value: _formatMined(station.metrics.minedBtc),
                icon: Icons.monetization_on,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
