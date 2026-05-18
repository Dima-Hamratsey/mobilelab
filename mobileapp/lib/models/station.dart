import 'package:mobileapp/models/station_metrics.dart';

class Station {
  const Station({
    required this.id,
    required this.name,
    required this.location,
    required this.metrics,
  });

  final String id;
  final String name;
  final String location;
  final StationMetrics metrics;

  Station copyWith({
    String? id,
    String? name,
    String? location,
    StationMetrics? metrics,
  }) {
    return Station(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      metrics: metrics ?? this.metrics,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'metrics': metrics.toJson(),
    };
  }

  factory Station.fromJson(Map<String, dynamic> json) {
    final rawMetrics = json['metrics'];
    final metricsMap = rawMetrics is Map
        ? Map<String, dynamic>.from(rawMetrics)
        : const <String, dynamic>{};
    return Station(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      location: json['location'] as String? ?? '',
      metrics: StationMetrics.fromJson(metricsMap),
    );
  }
}
