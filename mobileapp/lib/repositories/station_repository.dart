import 'package:mobileapp/models/station.dart';
import 'package:mobileapp/models/station_list.dart';

abstract class IStationRepository {
  Future<StationList> fetchStations();
  Future<void> saveStations(StationList stations);
  Future<void> addStation(Station station);
  Future<void> updateStation(Station station);
  Future<void> deleteStation(String id);
}
