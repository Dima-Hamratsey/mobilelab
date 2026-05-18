import 'package:mobileapp/models/station.dart';

class StationList {
  const StationList({required this.items});

  final List<Station> items;

  factory StationList.empty() {
    return const StationList(items: []);
  }

  StationList copyWith({List<Station>? items}) {
    return StationList(items: items ?? this.items);
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((station) => station.toJson()).toList(),
    };
  }

  factory StationList.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    final stations = rawItems
      .whereType<Map<String, dynamic>>()
      .map(Station.fromJson)
      .toList();

    return StationList(items: stations);
  }
}
