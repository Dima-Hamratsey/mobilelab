import 'package:flutter/material.dart';

import 'package:mobileapp/models/station.dart';
import 'package:mobileapp/repositories/local_auth_repository.dart';
import 'package:mobileapp/repositories/local_station_repository.dart';
import 'package:mobileapp/services/auth_service.dart';
import 'package:mobileapp/services/station_service.dart';
import 'package:mobileapp/widgets/gold_panel.dart';
import 'package:mobileapp/widgets/gold_scaffold.dart';
import 'package:mobileapp/widgets/metric_card.dart';
import 'package:mobileapp/widgets/metric_grid.dart';
import 'package:mobileapp/widgets/section_title.dart';
import 'package:mobileapp/widgets/station_card.dart';
import 'package:mobileapp/widgets/station_editor_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final PageController _controller;
  final AuthService _authService = AuthService(
    repository: LocalAuthRepository(),
  );
  final StationService _stationService = StationService(
    repository: LocalStationRepository(),
  );

  int _activeIndex = 0;
  List<Station> _stations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.92);
    _loadData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final stations = await _stationService.getStations();
    if (!mounted) {
      return;
    }
    final nextIndex = stations.isEmpty
        ? 0
        : _activeIndex.clamp(0, stations.length - 1);
    setState(() {
      _stations = stations;
      _activeIndex = nextIndex;
      _isLoading = false;
    });
  }

  Future<void> _openStationEditor({Station? station}) async {
    final result = await showDialog<Station>(
      context: context,
      builder: (context) {
        return StationEditorDialog(
          station: station,
          stationService: _stationService,
        );
      },
    );

    if (result == null || !mounted) {
      return;
    }

    if (station == null) {
      await _stationService.addStation(result);
    } else {
      await _stationService.updateStation(result);
    }

    await _loadData();
  }

  Future<void> _confirmDelete(Station station) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Видалити станцію?'),
          content: Text('Станція "${station.name}" буде видалена.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Скасувати'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Видалити'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    await _stationService.deleteStation(station.id);
    await _loadData();
  }

  String _formatTemp(double value) => '${value.toStringAsFixed(0)} °C';
  String _formatLoad(double value) => '${value.toStringAsFixed(0)}%';
  String _formatHashrate(double value) => '${value.toStringAsFixed(0)} TH/s';
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
    final activeStation =
        _stations.isNotEmpty ? _stations[_activeIndex] : null;

    final content = _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle(
                  title: 'Майнингові станції',
                  subtitle: 'Гортайте карти, щоб перемикатися.',
                ),
                const SizedBox(height: 12),
                if (_stations.isEmpty)
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
                          controller: _controller,
                          itemCount: _stations.length,
                          onPageChanged: (index) {
                            setState(() {
                              _activeIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            final station = _stations[index];
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
                              onPressed: () =>
                                  _openStationEditor(station: activeStation),
                              icon: const Icon(Icons.edit_outlined),
                              label: const Text('Редагувати'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _confirmDelete(activeStation!),
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
                        value: _formatLoad(activeStation.metrics.loadPercent),
                        icon: Icons.speed,
                      ),
                      MetricCard(
                        label: 'Хешрейт',
                        value:
                            _formatHashrate(activeStation.metrics.hashrateThs),
                        icon: Icons.bolt,
                      ),
                      MetricCard(
                        label: 'Добуто',
                        value: _formatMined(activeStation.metrics.minedBtc),
                        icon: Icons.monetization_on,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );

    return GoldScaffold(
      title: 'Центр керування',
      actions: [
        IconButton(
          onPressed: () {
            Navigator.pushNamed(context, '/profile');
          },
          icon: const Icon(Icons.person_outline),
          tooltip: 'Профіль',
        ),
        IconButton(
          onPressed: _handleLogout,
          icon: const Icon(Icons.logout),
          tooltip: 'Вийти',
        ),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: _openStationEditor,
        tooltip: 'Додати станцію',
        child: const Icon(Icons.add),
      ),
      child: content,
    );
  }
}
