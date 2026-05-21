import 'package:mobileapp/models/station.dart';
import 'package:mobileapp/models/station_metrics.dart';

List<Station> stationsFromProfile(Map<String, dynamic> profile) {
  final rawStations = profile['stations'] as List<dynamic>? ?? [];
  return rawStations
      .whereType<Map<String, dynamic>>()
      .map(_stationFromApi)
      .toList();
}

Map<String, dynamic> stationsUpdatePayload(List<Station> stations) {
  return {
    'stations': stations.map(_stationToApi).toList(),
  };
}

Station _stationFromApi(Map<String, dynamic> json) {
  final rawMetrics = json['metrics'];
  final metrics = rawMetrics is Map
    ? Map<String, dynamic>.from(rawMetrics)
    : const <String, dynamic>{};

  final temperature =
    (metrics['temperatureC'] as num?)?.toDouble() ??
    0;
  final loadPercent =
    (metrics['loadPercent'] as num?)?.toDouble() ??
    0;
  final hashrateThs =
    (metrics['hashrateThs'] as num?)?.toDouble() ??
    0;
  final minedBtc = (metrics['minedBtc'] as num?)?.toDouble() ?? 0;
  final location =
    json['location'] as String? ??
    '';

  return Station(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    location: location,
    metrics: StationMetrics(
      temperatureC: temperature,
      loadPercent: loadPercent,
      hashrateThs: hashrateThs,
      minedBtc: minedBtc,
    ),
  );
}

Map<String, dynamic> _stationToApi(Station station) {
  return {
    'id': station.id,
    'name': station.name,
    'location': station.location,
    'metrics': {
      'temperatureC': station.metrics.temperatureC,
      'loadPercent': station.metrics.loadPercent,
      'hashrateThs': station.metrics.hashrateThs,
      'minedBtc': station.metrics.minedBtc,
    },
  };
}
