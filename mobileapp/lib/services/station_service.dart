import 'package:mobileapp/models/station.dart';
import 'package:mobileapp/models/station_metrics.dart';
import 'package:mobileapp/repositories/station_repository.dart';

class StationService {
  StationService({required IStationRepository repository})
      : _repository = repository;

  final IStationRepository _repository;

  Future<List<Station>> getStations() async {
    final list = await _repository.fetchStations();
    return list.items;
  }

  Future<void> addStation(Station station) {
    return _repository.addStation(station);
  }

  Future<void> updateStation(Station station) {
    return _repository.updateStation(station);
  }

  Future<void> deleteStation(String id) {
    return _repository.deleteStation(id);
  }

  Future<void> syncStations() {
    return _repository.syncStations();
  }

  String? validateRequired(String? value, String label) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Заповніть "$label"';
    }
    return null;
  }

  String? validateNumber(
    String? value,
    String label, {
    double? min,
    double? max,
  }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Заповніть "$label"';
    }
    final parsed = double.tryParse(text.replaceAll(',', '.'));
    if (parsed == null) {
      return 'Вкажіть число';
    }
    if (min != null && parsed < min) {
      return 'Мінімум $min';
    }
    if (max != null && parsed > max) {
      return 'Максимум $max';
    }
    return null;
  }

  Station buildStation({
    required String id,
    required String name,
    required String location,
    required double temperatureC,
    required double loadPercent,
    required double hashrateThs,
    required double minedBtc,
  }) {
    return Station(
      id: id,
      name: name.trim(),
      location: location.trim(),
      metrics: StationMetrics(
        temperatureC: temperatureC,
        loadPercent: loadPercent,
        hashrateThs: hashrateThs,
        minedBtc: minedBtc,
      ),
    );
  }
}
