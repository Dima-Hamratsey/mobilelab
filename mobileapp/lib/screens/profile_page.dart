import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mobileapp/cubits/profile_cubit.dart';
import 'package:mobileapp/cubits/session_cubit.dart';
import 'package:mobileapp/widgets/coin_badge.dart';
import 'package:mobileapp/widgets/gold_panel.dart';
import 'package:mobileapp/widgets/gold_scaffold.dart';
import 'package:mobileapp/widgets/metric_card.dart';
import 'package:mobileapp/widgets/metric_grid.dart';
import 'package:mobileapp/widgets/profile_tile.dart';
import 'package:mobileapp/widgets/section_title.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  static const double _btcUsdRate = 80000;

  String _formatHashrate(double value) {
    return '${value.toStringAsFixed(0)} TH/s';
  }

  String _formatTemp(double value) {
    return '${value.toStringAsFixed(0)} °C';
  }

  String _formatMined(double value) {
    return '${value.toStringAsFixed(3)} BTC';
  }

  String _formatUsd(double value) {
    return '${value.toStringAsFixed(0)} \$';
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Вийти з акаунта?'),
          content: const Text('Сесію буде завершено.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Скасувати'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Вийти'),
            ),
          ],
        );
      },
    );

    if (!context.mounted) {
      return;
    }

    if (shouldLogout == true) {
      await context.read<SessionCubit>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SessionCubit, SessionState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == SessionStatus.loggedOut) {
          context.read<SessionCubit>().reset();
          Navigator.pushReplacementNamed(context, '/');
        }
        if (state.status == SessionStatus.failure) {
          final message =
              state.errorMessage ?? 'Не вдалося вийти з акаунта.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
          context.read<SessionCubit>().reset();
        }
      },
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
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
              IconButton(
                onPressed: () => _confirmLogout(context),
                icon: const Icon(Icons.logout),
                tooltip: 'Вийти',
              ),
            ],
            child: _buildBody(context, state),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, ProfileState state) {
    if (state.status == ProfileStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.status == ProfileStatus.failure) {
      final message = state.errorMessage ?? 'Помилка';
      return Center(child: Text('Помилка: $message'));
    }

    return _buildContent(context, state);
  }

  Widget _buildContent(BuildContext context, ProfileState state) {
    final theme = Theme.of(context);
    final data = state.data;
    final totalHashrate = data.stations.fold<double>(
      0,
      (sum, station) => sum + station.metrics.hashrateThs,
    );
    final totalTemp = data.stations.fold<double>(
      0,
      (sum, station) => sum + station.metrics.temperatureC,
    );
    final averageTemp = data.stations.isEmpty
      ? 0
      : totalTemp / data.stations.length;
    final totalMined = data.stations.fold<double>(
      0,
      (sum, station) => sum + station.metrics.minedBtc,
    );
    final minedUsd = totalMined * _btcUsdRate;
    final tempLabel = state.temperature == null
      ? '—'
      : '${state.temperature!.toStringAsFixed(1)} °C';
    final tempSuffix = state.mqttConnected ? '' : ' (немає з\'єднання)';

    return SingleChildScrollView(
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
                  Text(
                    data.user?.name ?? 'Невідомий користувач',
                    style: theme.textTheme.titleLarge,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const SectionTitle(
            title: 'Дані користувача',
          ),
          const SizedBox(height: 12),
          GoldPanel(
            child: Column(
              children: [
                ProfileTile(
                  label: 'Ім\'я',
                  value: data.user?.name ?? '—',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 12),
                ProfileTile(
                  label: 'Пошта',
                  value: data.user?.email ?? '—',
                  icon: Icons.alternate_email,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GoldPanel(
            child: Text(
              'Поточна температура: $tempLabel$tempSuffix',
            ),
          ),
          const SizedBox(height: 24),
          const SectionTitle(
            title: 'Сумарні показники',
          ),
          const SizedBox(height: 12),
          MetricGrid(
            children: [
              MetricCard(
                label: 'Загальний хешрейт',
                value: _formatHashrate(totalHashrate),
                icon: Icons.bolt,
              ),
              MetricCard(
                label: 'Сер. температура',
                value: _formatTemp(averageTemp.toDouble()),
                icon: Icons.thermostat,
              ),
              MetricCard(
                label: 'Добуто сьогодні',
                value: _formatMined(totalMined),
                icon: Icons.monetization_on,
              ),
              MetricCard(
                label: 'Добуто сьогодні, \$',
                value: _formatUsd(minedUsd),
                icon: Icons.attach_money,
              ),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => _confirmLogout(context),
            child: const Text('Вийти'),
          ),
        ],
      ),
    );
  }
}
