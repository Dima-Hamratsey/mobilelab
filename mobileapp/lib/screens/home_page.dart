import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobileapp/cubits/session_cubit.dart';
import 'package:mobileapp/cubits/stations_cubit.dart';
import 'package:mobileapp/models/station.dart';
import 'package:mobileapp/screens/home_content.dart';
import 'package:mobileapp/widgets/gold_scaffold.dart';
import 'package:mobileapp/widgets/station_editor_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final PageController _controller;
  bool _didShowOfflineWarning = false;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.92);
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
      context.read<StationsCubit>().showOfflineWarning();
    }
    _didShowOfflineWarning = true;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _openStationEditor({Station? station}) async {
    final result = await showDialog<Station>(
      context: context,
      builder: (context) {
        return StationEditorDialog(
          station: station,
        );
      },
    );

    if (result == null || !mounted) {
      return;
    }

    if (station == null) {
      await context.read<StationsCubit>().addStation(result);
    } else {
      await context.read<StationsCubit>().updateStation(result);
    }
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

    if (!mounted) {
      return;
    }

    if (shouldDelete != true) {
      return;
    }

    await context.read<StationsCubit>().deleteStation(station.id);
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

    if (!mounted) {
      return;
    }

    if (shouldLogout == true) {
      await context.read<SessionCubit>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<StationsCubit, StationsState>(
          listenWhen: (previous, current) =>
              previous.notice != current.notice && current.notice != null,
          listener: (context, state) {
            final message = switch (state.notice) {
              StationsNotice.offlineLost => 'Втрачено інтернет-зʼєднання.',
              StationsNotice.onlineRestored => 'Інтернет-зʼєднання відновлено.',
              StationsNotice.offlineAutoLogin =>
                'Автовхід без інтернету. Частина функцій недоступна.',
              _ => null,
            };
            if (message != null) {
              _showSnack(message);
            }
            context.read<StationsCubit>().clearNotice();
          },
        ),
        BlocListener<StationsCubit, StationsState>(
          listenWhen: (previous, current) =>
              previous.status != current.status &&
              current.status == StationsStatus.failure,
          listener: (context, state) {
            final message =
                state.errorMessage ?? 'Не вдалося завантажити дані.';
            _showSnack('Помилка: $message');
          },
        ),
        BlocListener<StationsCubit, StationsState>(
          listenWhen: (previous, current) =>
              previous.activeIndex != current.activeIndex,
          listener: (context, state) {
            if (_controller.hasClients) {
              _controller.jumpToPage(state.activeIndex);
            }
          },
        ),
        BlocListener<SessionCubit, SessionState>(
          listenWhen: (previous, current) =>
              previous.status != current.status,
          listener: (context, state) {
            if (state.status == SessionStatus.loggedOut) {
              context.read<SessionCubit>().reset();
              Navigator.pushReplacementNamed(context, '/');
            }
            if (state.status == SessionStatus.failure) {
              final message =
                  state.errorMessage ?? 'Не вдалося вийти з акаунта.';
              _showSnack(message);
              context.read<SessionCubit>().reset();
            }
          },
        ),
      ],
      child: BlocBuilder<StationsCubit, StationsState>(
        builder: (context, state) {
          final activeStation = state.stations.isNotEmpty
              ? state.stations[state.activeIndex]
              : null;
          final isLoading = state.status == StationsStatus.loading ||
              state.status == StationsStatus.initial;

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
              isLoading: isLoading,
              stations: state.stations,
              activeIndex: state.activeIndex,
              controller: _controller,
              onPageChanged: (index) {
                context.read<StationsCubit>().setActiveIndex(index);
              },
              onEdit: activeStation == null
                  ? null
                  : () => _openStationEditor(station: activeStation),
              onDelete: activeStation == null
                  ? null
                  : () => _confirmDelete(activeStation),
            ),
          );
        },
      ),
    );
  }
}
