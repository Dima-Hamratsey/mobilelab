import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobileapp/models/station.dart';
import 'package:mobileapp/network/network_status_service.dart';
import 'package:mobileapp/repositories/api_auth_repository.dart';
import 'package:mobileapp/repositories/api_station_repository.dart';
import 'package:mobileapp/screens/home_content.dart';
import 'package:mobileapp/services/auth_service.dart';
import 'package:mobileapp/services/station_service.dart';
import 'package:mobileapp/widgets/gold_scaffold.dart';
import 'package:mobileapp/widgets/station_editor_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final PageController _controller;
  final AuthService _authService = AuthService(
    repository: ApiAuthRepository(),
  );
  final NetworkStatusService _networkStatus = NetworkStatusService();
  late final StationService _stationService = StationService(
    repository: ApiStationRepository(networkStatus: _networkStatus),
  );
  StreamSubscription<bool>? _networkSub;
  bool? _lastOnline;

  int _activeIndex = 0;
  List<Station> _stations = [];
  bool _isLoading = true;
  bool _didShowOfflineWarning = false;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.92);
    _loadData();
    _seedNetworkStatus();
    _networkSub = _networkStatus.onStatusChanged.listen(_handleNetworkChange);
  }

  Future<void> _seedNetworkStatus() async {
    final isOnline = await _networkStatus.isOnline();
    if (!mounted) {
      return;
    }
    _lastOnline = isOnline;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didShowOfflineWarning) {
      return;
    }

    final args = ModalRoute.of(context)?.settings.arguments;
    final offline = args is Map && args['offline'] == true;
    if (offline) {
      _showSnack('Автовхід без інтернету. Частина функцій недоступна.');
    }
    _didShowOfflineWarning = true;
  }

  @override
  void dispose() {
    _controller.dispose();
    _networkSub?.cancel();
    super.dispose();
  }

  Future<void> _handleNetworkChange(bool isOnline) async {
    if (!mounted) {
      return;
    }
    final wasOffline = _lastOnline == false;
    if (!isOnline && _lastOnline != false) {
      _showSnack('Втрачено інтернет-зʼєднання.');
    }
    if (isOnline && wasOffline) {
      _showSnack('Інтернет-зʼєднання відновлено.');
      await _stationService.syncStations();
      if (!mounted) {
        return;
      }
      await _loadData();
    }
    _lastOnline = isOnline;
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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

  Future<void> _handleLogout() async {
    await _authService.logout();
    if (!mounted) {
      return;
    }
    Navigator.pushReplacementNamed(context, '/');
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
      await _handleLogout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeStation =
        _stations.isNotEmpty ? _stations[_activeIndex] : null;

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
          onPressed: _confirmLogout,
          icon: const Icon(Icons.logout),
          tooltip: 'Вийти',
        ),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: _openStationEditor,
        tooltip: 'Додати станцію',
        child: const Icon(Icons.add),
      ),
      child: HomeContent(
        isLoading: _isLoading,
        stations: _stations,
        activeIndex: _activeIndex,
        controller: _controller,
        onPageChanged: (index) {
          setState(() {
            _activeIndex = index;
          });
        },
        onEdit: activeStation == null
            ? null
            : () => _openStationEditor(station: activeStation),
        onDelete: activeStation == null
            ? null
            : () => _confirmDelete(activeStation),
      ),
    );
  }
}
