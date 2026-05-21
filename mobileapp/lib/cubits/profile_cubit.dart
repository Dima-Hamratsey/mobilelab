import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobileapp/models/profile_data.dart';
import 'package:mobileapp/mqtt/mqtt_temperature_service.dart';
import 'package:mobileapp/services/auth_service.dart';
import 'package:mobileapp/services/station_service.dart';

enum ProfileStatus { loading, ready, failure }

class ProfileState {
  const ProfileState({
    this.status = ProfileStatus.loading,
    this.data = const ProfileData(user: null, stations: []),
    this.temperature,
    this.mqttConnected = false,
    this.errorMessage,
  });

  final ProfileStatus status;
  final ProfileData data;
  final double? temperature;
  final bool mqttConnected;
  final String? errorMessage;

  ProfileState copyWith({
    ProfileStatus? status,
    ProfileData? data,
    double? temperature,
    bool? mqttConnected,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      data: data ?? this.data,
      temperature: temperature ?? this.temperature,
      mqttConnected: mqttConnected ?? this.mqttConnected,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required AuthService authService,
    required StationService stationService,
  })  : _authService = authService,
        _stationService = stationService,
        super(const ProfileState());

  final AuthService _authService;
  final StationService _stationService;
  MqttTemperatureService? _mqttService;
  StreamSubscription<double?>? _temperatureSub;
  StreamSubscription<bool>? _connectionSub;

  Future<void> initialize() async {
    await loadProfile();
    _initMqtt();
  }

  Future<void> loadProfile() async {
    emit(state.copyWith(status: ProfileStatus.loading, clearError: true));
    try {
      final user = await _authService.getSessionUser();
      final stations = await _stationService.getStations();
      emit(
        state.copyWith(
          status: ProfileStatus.ready,
          data: ProfileData(user: user, stations: stations),
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void _initMqtt() {
    final clientId = 'mobileapp_${DateTime.now().millisecondsSinceEpoch}';
    const brokerIp = '10.102.31.71';

    _mqttService = MqttTemperatureService(
      server: brokerIp,
      clientId: clientId,
      topic: 'esp8266/temperature',
      websocketServer: 'ws://$brokerIp',
    );
    _mqttService?.connect();

    _temperatureSub = _mqttService?.temperatureStream.listen((value) {
      emit(state.copyWith(temperature: value));
    });

    _connectionSub = _mqttService?.connectionStream.listen((connected) {
      emit(state.copyWith(mqttConnected: connected));
    });
  }

  @override
  Future<void> close() async {
    await _temperatureSub?.cancel();
    await _connectionSub?.cancel();
    _mqttService?.dispose();
    return super.close();
  }
}
