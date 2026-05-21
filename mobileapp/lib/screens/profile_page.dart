import 'dart:async';

import 'package:flutter/material.dart';

import 'package:mobileapp/models/profile_data.dart';
import 'package:mobileapp/mqtt/mqtt_temperature_service.dart';
import 'package:mobileapp/repositories/api_auth_repository.dart';
import 'package:mobileapp/repositories/api_station_repository.dart';
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
  static const double _btcUsdRate = 80000;

  final AuthService _authService = AuthService(
    repository: ApiAuthRepository(),
  );
  final StationService _stationService = StationService(
    repository: ApiStationRepository(),
  );

  late final Future<ProfileData> _profileFuture;
  late final MqttTemperatureService _mqttService;
  StreamSubscription<double?>? _temperatureSub;
  StreamSubscription<bool>? _connectionSub;
  double? _temperature;
  bool _mqttConnected = false;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
    _initMqtt();
  }

  @override
  void dispose() {
    _temperatureSub?.cancel();
    _connectionSub?.cancel();
    _mqttService.dispose();
    super.dispose();
  }

  void _initMqtt() {
    final clientId = 'mobileapp_${DateTime.now().millisecondsSinceEpoch}';
    const brokerIp = '10.102.31.71';

    _mqttService = MqttTemperatureService(
      server: brokerIp,
      clientId: clientId,
      topic: 'esp8266/temperature',
      websocketServer: 'ws://$brokerIp',
    );
    _mqttService.connect();

    _temperatureSub = _mqttService.temperatureStream.listen((value) {
      if (!mounted) {
        return;
      }
      setState(() {
        _temperature = value;
      });
    });

    _connectionSub = _mqttService.connectionStream.listen((connected) {
      if (!mounted) {
        return;
      }
      setState(() {
        _mqttConnected = connected;
      });
    });
  }

  Future<ProfileData> _loadProfile() async {
    final user = await _authService.getSessionUser();
    final stations = await _stationService.getStations();
    return ProfileData(user: user, stations: stations);
  }

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

  Future<void> _confirmLogout() async {
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

    if (shouldLogout == true) {
      await _authService.logout();
      if (!mounted) {
        return;
      }
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
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
      child: FutureBuilder<ProfileData>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Помилка: ${snapshot.error}'),
            );
          }

          final data = snapshot.data ??
              const ProfileData(user: null, stations: []);
          return _buildContent(context, data);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, ProfileData data) {
    final theme = Theme.of(context);
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
    final tempLabel = _temperature == null
        ? '—'
        : '${_temperature!.toStringAsFixed(1)} °C';
    final tempSuffix = _mqttConnected
        ? ''
        : ' (немає з\'єднання)';

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
            onPressed: _confirmLogout,
            child: const Text('Вийти'),
          ),
        ],
      ),
    );
  }
}
