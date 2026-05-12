import 'package:flutter/material.dart';

import 'package:mobileapp/widgets/gold_scaffold.dart';
import 'package:mobileapp/widgets/metric_card.dart';
import 'package:mobileapp/widgets/metric_grid.dart';
import 'package:mobileapp/widgets/section_title.dart';
import 'package:mobileapp/widgets/station_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final PageController _controller;
  int _activeIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.92);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeStation = _stations[_activeIndex];

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
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/');
          },
          icon: const Icon(Icons.logout),
          tooltip: 'Вийти',
        ),
      ],
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(
              title: 'Майнингові станції',
              subtitle: 'Гортайте карти, щоб перемикатися.',
            ),
            const SizedBox(height: 12),
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
                    child: StationCard(
                      name: station.name,
                      location: station.location,
                      temperature: station.temperature,
                      load: station.load,
                      hashrate: station.hashrate,
                      mined: station.mined,
                    ),
                  );
                },
              ),
            ),
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
                  value: activeStation.temperature,
                  icon: Icons.thermostat,
                ),
                MetricCard(
                  label: 'Навантаження',
                  value: activeStation.load,
                  icon: Icons.speed,
                ),
                MetricCard(
                  label: 'Хешрейт',
                  value: activeStation.hashrate,
                  icon: Icons.bolt,
                ),
                MetricCard(
                  label: 'Добуто',
                  value: activeStation.mined,
                  icon: Icons.monetization_on,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class StationData {
  const StationData({
    required this.name,
    required this.location,
    required this.temperature,
    required this.load,
    required this.hashrate,
    required this.mined,
  });

  final String name;
  final String location;
  final String temperature;
  final String load;
  final String hashrate;
  final String mined;
}

const List<StationData> _stations = [
  StationData(
    name: 'Aurora S-01',
    location: 'Київ / Поділ',
    temperature: '64 °C',
    load: '78%',
    hashrate: '92 TH/s',
    mined: '0.024 BTC',
  ),
  StationData(
    name: 'Nadir S-02',
    location: 'Львів / Вокзал',
    temperature: '58 °C',
    load: '71%',
    hashrate: '88 TH/s',
    mined: '0.019 BTC',
  ),
  StationData(
    name: 'Orbit S-03',
    location: 'Одеса / Док 7',
    temperature: '69 °C',
    load: '84%',
    hashrate: '101 TH/s',
    mined: '0.031 BTC',
  ),
];
