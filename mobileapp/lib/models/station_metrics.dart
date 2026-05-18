class StationMetrics {
  const StationMetrics({
    required this.temperatureC,
    required this.loadPercent,
    required this.hashrateThs,
    required this.minedBtc,
  });

  final double temperatureC;
  final double loadPercent;
  final double hashrateThs;
  final double minedBtc;

  StationMetrics copyWith({
    double? temperatureC,
    double? loadPercent,
    double? hashrateThs,
    double? minedBtc,
  }) {
    return StationMetrics(
      temperatureC: temperatureC ?? this.temperatureC,
      loadPercent: loadPercent ?? this.loadPercent,
      hashrateThs: hashrateThs ?? this.hashrateThs,
      minedBtc: minedBtc ?? this.minedBtc,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperatureC': temperatureC,
      'loadPercent': loadPercent,
      'hashrateThs': hashrateThs,
      'minedBtc': minedBtc,
    };
  }

  factory StationMetrics.fromJson(Map<String, dynamic> json) {
    return StationMetrics(
      temperatureC: (json['temperatureC'] as num?)?.toDouble() ?? 0,
      loadPercent: (json['loadPercent'] as num?)?.toDouble() ?? 0,
      hashrateThs: (json['hashrateThs'] as num?)?.toDouble() ?? 0,
      minedBtc: (json['minedBtc'] as num?)?.toDouble() ?? 0,
    );
  }
}
