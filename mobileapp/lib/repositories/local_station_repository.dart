import 'dart:convert';

import 'package:mobileapp/models/station.dart';
import 'package:mobileapp/models/station_list.dart';
import 'package:mobileapp/repositories/station_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStationRepository extends IStationRepository {
  LocalStationRepository({SharedPreferences? preferences})
  : _preferences = preferences == null
    ? SharedPreferences.getInstance()
    : Future.value(preferences);

  final Future<SharedPreferences> _preferences;

  static const String _stationsKey = 'stations';

  @override
  Future<StationList> fetchStations() async {
    final prefs = await _preferences;
    final rawStations = prefs.getString(_stationsKey);
    if (rawStations == null) {
      return StationList.empty();
    }

    return StationList.fromJson(
      jsonDecode(rawStations) as Map<String, dynamic>,
    );
  }

  @override
  Future<void> saveStations(StationList stations) async {
    final prefs = await _preferences;
    final payload = jsonEncode(stations.toJson());
    await prefs.setString(_stationsKey, payload);
  }

  @override
  Future<void> addStation(Station station) async {
    final stations = await fetchStations();
    final updated = StationList(
      items: [...stations.items, station],
    );
    await saveStations(updated);
  }

  @override
  Future<void> updateStation(Station station) async {
    final stations = await fetchStations();
    final updated = stations.items
        .map((item) => item.id == station.id ? station : item)
        .toList();
    await saveStations(StationList(items: updated));
  }

  @override
  Future<void> deleteStation(String id) async {
    final stations = await fetchStations();
    final updated = stations.items.where((item) => item.id != id).toList();
    await saveStations(StationList(items: updated));
  }
}
