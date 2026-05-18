import 'package:flutter/material.dart';

import 'package:mobileapp/models/station.dart';
import 'package:mobileapp/models/user.dart';
import 'package:mobileapp/repositories/local_auth_repository.dart';
import 'package:mobileapp/repositories/local_station_repository.dart';
import 'package:mobileapp/services/auth_service.dart';
import 'package:mobileapp/services/station_service.dart';
import 'package:mobileapp/widgets/coin_badge.dart';
import 'package:mobileapp/widgets/gold_panel.dart';
import 'package:mobileapp/widgets/gold_scaffold.dart';
import 'package:mobileapp/widgets/metric_card.dart';
import 'package:mobileapp/widgets/metric_grid.dart';
import 'package:mobileapp/widgets/profile_tile.dart';
import 'package:mobileapp/widgets/section_title.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService(
    repository: LocalAuthRepository(),
  );
  final StationService _stationService = StationService(
    repository: LocalStationRepository(),
  );

  User? _user;
  List<Station> _stations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = await _authService.getSessionUser();
    final stations = await _stationService.getStations();
    if (!mounted) {
      return;
    }
    setState(() {
      _user = user;
      _stations = stations;
      _isLoading = false;
    });
  }

  String _formatHashrate(double value) => '${value.toStringAsFixed(0)} TH/s';
  String _formatTemp(double value) => '${value.toStringAsFixed(0)} °C';
  String _formatMined(double value) => '${value.toStringAsFixed(3)} BTC';

  Future<void> _handleLogout() async {
    await _authService.logout();
    if (!mounted) {
      return;
    }
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalHashrate = _stations.fold<double>(
      0,
      (sum, station) => sum + station.metrics.hashrateThs,
    );
    final totalTemp = _stations.fold<double>(
      0,
      (sum, station) => sum + station.metrics.temperatureC,
    );
    final double averageTemp =
        _stations.isEmpty ? 0 : totalTemp / _stations.length;
    final totalMined = _stations.fold<double>(
      0,
      (sum, station) => sum + station.metrics.minedBtc,
    );

    final content = _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
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
                          _user?.name ?? 'Невідомий користувач',
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
                        value: _user?.name ?? '—',
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 12),
                      ProfileTile(
                        label: 'Пошта',
                        value: _user?.email ?? '—',
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
                MetricGrid(
                  children: [
                    MetricCard(
                      label: 'Загальний хешрейт',
                      value: _formatHashrate(totalHashrate),
                      icon: Icons.bolt,
                    ),
                    MetricCard(
                      label: 'Сер. температура',
                      value: _formatTemp(averageTemp),
                      icon: Icons.thermostat,
                    ),
                    MetricCard(
                      label: 'Добуто всього',
                      value: _formatMined(totalMined),
                      icon: Icons.monetization_on,
                    ),
                    MetricCard(
                      label: 'Кількість станцій',
                      value: _stations.length.toString(),
                      icon: Icons.storage_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: _handleLogout,
                  child: const Text('Вийти'),
                ),
              ],
            ),
          );

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
      child: content,
    );
  }
}
