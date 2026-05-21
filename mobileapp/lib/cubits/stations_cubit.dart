import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobileapp/models/station.dart';
import 'package:mobileapp/network/network_status_service.dart';
import 'package:mobileapp/services/station_service.dart';

enum StationsStatus { initial, loading, ready, failure }

enum StationsNotice { offlineLost, onlineRestored, offlineAutoLogin }

class StationsState {
  const StationsState({
    this.status = StationsStatus.initial,
    this.stations = const [],
    this.activeIndex = 0,
    this.notice,
    this.errorMessage,
  });

  final StationsStatus status;
  final List<Station> stations;
  final int activeIndex;
  final StationsNotice? notice;
  final String? errorMessage;

  StationsState copyWith({
    StationsStatus? status,
    List<Station>? stations,
    int? activeIndex,
    StationsNotice? notice,
    bool clearNotice = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return StationsState(
      status: status ?? this.status,
      stations: stations ?? this.stations,
      activeIndex: activeIndex ?? this.activeIndex,
      notice: clearNotice ? null : notice ?? this.notice,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class StationsCubit extends Cubit<StationsState> {
  StationsCubit({
    required StationService stationService,
    required NetworkStatusService networkStatus,
  })  : _stationService = stationService,
        _networkStatus = networkStatus,
        super(const StationsState());

  final StationService _stationService;
  final NetworkStatusService _networkStatus;
  StreamSubscription<bool>? _networkSub;
  bool? _lastOnline;

  Future<void> initialize() async {
    await _seedNetworkStatus();
    _networkSub = _networkStatus.onStatusChanged.listen(_handleNetworkChange);
    await loadStations();
  }

  Future<void> loadStations() async {
    emit(state.copyWith(status: StationsStatus.loading, clearError: true));
    try {
      final stations = await _stationService.getStations();
      final nextIndex = stations.isEmpty
          ? 0
          : state.activeIndex.clamp(0, stations.length - 1);
      emit(
        state.copyWith(
          status: StationsStatus.ready,
          stations: stations,
          activeIndex: nextIndex,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: StationsStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void setActiveIndex(int index) {
    emit(state.copyWith(activeIndex: index));
  }

  Future<void> addStation(Station station) async {
    await _stationService.addStation(station);
    await loadStations();
  }

  Future<void> updateStation(Station station) async {
    await _stationService.updateStation(station);
    await loadStations();
  }

  Future<void> deleteStation(String id) async {
    await _stationService.deleteStation(id);
    await loadStations();
  }

  void showOfflineWarning() {
    emit(state.copyWith(notice: StationsNotice.offlineAutoLogin));
  }

  void clearNotice() {
    emit(state.copyWith(clearNotice: true));
  }

  Future<void> _seedNetworkStatus() async {
    final isOnline = await _networkStatus.isOnline();
    _lastOnline = isOnline;
  }

  Future<void> _handleNetworkChange(bool isOnline) async {
    final wasOffline = _lastOnline == false;
    if (!isOnline && _lastOnline != false) {
      emit(state.copyWith(notice: StationsNotice.offlineLost));
    }
    if (isOnline && wasOffline) {
      emit(state.copyWith(notice: StationsNotice.onlineRestored));
      await _stationService.syncStations();
      await loadStations();
    }
    _lastOnline = isOnline;
  }

  @override
  Future<void> close() async {
    await _networkSub?.cancel();
    return super.close();
  }
}
