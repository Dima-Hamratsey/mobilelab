import 'package:mobileapp/api/api_client.dart';
import 'package:mobileapp/api/api_config.dart';
import 'package:mobileapp/api/api_station_mapper.dart';
import 'package:mobileapp/api/token_storage.dart';
import 'package:mobileapp/models/station.dart';
import 'package:mobileapp/models/station_list.dart';
import 'package:mobileapp/network/network_status_service.dart';
import 'package:mobileapp/repositories/local_station_repository.dart';
import 'package:mobileapp/repositories/station_repository.dart';

class ApiStationRepository extends IStationRepository {
  ApiStationRepository({
    ApiClient? client,
    TokenStorage? tokenStorage,
    LocalStationRepository? localStations,
    NetworkStatusService? networkStatus,
  })  : _localStations = localStations ?? LocalStationRepository(),
        _networkStatus = networkStatus ?? NetworkStatusService(),
        _client = client ??
            ApiClient(
              baseUrl: apiBaseUrl,
              tokenStorage: tokenStorage ?? TokenStorage(),
            );

  final ApiClient _client;
  final LocalStationRepository _localStations;
  final NetworkStatusService _networkStatus;

  @override
  Future<StationList> fetchStations() async {
    final isOnline = await _networkStatus.isOnline();
    if (isOnline) {
      final hasPending = await _localStations.hasPendingSync();
      if (hasPending) {
        await _syncStations();
        return _localStations.fetchStations();
      }
      try {
        final profile = await _client.getJson('/auth/profile');
        final stations = stationsFromProfile(profile);
        final list = StationList(items: stations);
        await _localStations.saveStations(list);
        return list;
      } catch (_) {}
    }

    return _localStations.fetchStations();
  }

  @override
  Future<void> saveStations(StationList stations) {
    return _localStations.saveStations(stations);
  }

  @override
  Future<void> addStation(Station station) async {
    await _localStations.addStation(station);
    await _localStations.setPendingSync(true);
    await _syncStations();
  }

  @override
  Future<void> updateStation(Station station) async {
    await _localStations.updateStation(station);
    await _localStations.setPendingSync(true);
    await _syncStations();
  }

  @override
  Future<void> deleteStation(String id) async {
    await _localStations.deleteStation(id);
    await _localStations.setPendingSync(true);
    await _syncStations();
  }

  @override
  Future<void> syncStations() async {
    final hasPending = await _localStations.hasPendingSync();
    if (!hasPending) {
      return;
    }
    await _syncStations();
  }

  Future<void> _syncStations() async {
    final isOnline = await _networkStatus.isOnline();
    if (!isOnline) {
      return;
    }

    final list = await _localStations.fetchStations();
    try {
      final response = await _client.putJson(
        '/auth/stations',
        stationsUpdatePayload(list.items),
      );
      final stations = stationsFromProfile(response);
      await _localStations.saveStations(
        StationList(items: stations),
      );
      await _localStations.setPendingSync(false);
    } catch (_) {}
  }
}
