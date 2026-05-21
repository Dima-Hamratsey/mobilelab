import 'package:flutter/material.dart';

import 'package:mobileapp/models/station.dart';
import 'package:mobileapp/widgets/gold_panel.dart';
import 'package:mobileapp/widgets/metric_card.dart';
import 'package:mobileapp/widgets/metric_grid.dart';
import 'package:mobileapp/widgets/section_title.dart';
import 'package:mobileapp/widgets/station_card.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({
    required this.isLoading,
    required this.stations,
    required this.activeIndex,
    required this.controller,
    required this.onPageChanged,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final bool isLoading;
  final List<Station> stations;
  final int activeIndex;
  final PageController controller;
  final ValueChanged<int> onPageChanged;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  String _formatTemp(double value) => '${value.toStringAsFixed(0)} °C';
  String _formatLoad(double value) => '${value.toStringAsFixed(0)}%';
  String _formatHashrate(double value) => '${value.toStringAsFixed(0)} TH/s';
  String _formatMined(double value) => '${value.toStringAsFixed(3)} BTC';

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final theme = Theme.of(context);
    final activeStation = stations.isNotEmpty
      ? stations[activeIndex]
      : null;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            title: 'Майнингові станції',
            subtitle: 'Гортайте карти, щоб перемикатися.',
          ),
          const SizedBox(height: 12),
          if (stations.isEmpty)
            GoldPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Станцій ще немає',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  const Text('Додайте першу через кнопку +.'),
                ],
              ),
            )
          else
            Column(
              children: [
                SizedBox(
                  height: 250,
                  child: PageView.builder(
                    controller: controller,
                    itemCount: stations.length,
                    onPageChanged: onPageChanged,
                    itemBuilder: (context, index) {
                      final station = stations[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: StationCard(station: station),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Редагувати'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Видалити'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          if (activeStation != null) ...[
            const SizedBox(height: 24),
            const SectionTitle(
              title: 'Показники',
              subtitle: 'Характеристики активної станції.',
            ),
            const SizedBox(height: 12),
            MetricGrid(
              children: [
                MetricCard(
                  label: 'Температура',
                  value: _formatTemp(
                    activeStation.metrics.temperatureC,
                  ),
                  icon: Icons.thermostat,
                ),
                MetricCard(
                  label: 'Навантаження',
                  value: _formatLoad(
                    activeStation.metrics.loadPercent,
                  ),
                  icon: Icons.speed,
                ),
                MetricCard(
                  label: 'Хешрейт',
                  value: _formatHashrate(
                    activeStation.metrics.hashrateThs,
                  ),
                  icon: Icons.bolt,
                ),
                MetricCard(
                  label: 'Добуто',
                  value: _formatMined(
                    activeStation.metrics.minedBtc,
                  ),
                  icon: Icons.monetization_on,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
