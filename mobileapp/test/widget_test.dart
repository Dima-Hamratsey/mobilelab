// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:mobileapp/api/api_client.dart';
import 'package:mobileapp/api/api_config.dart';
import 'package:mobileapp/api/token_storage.dart';
import 'package:mobileapp/main.dart';
import 'package:mobileapp/network/network_status_service.dart';
import 'package:mobileapp/repositories/api_auth_repository.dart';
import 'package:mobileapp/repositories/api_station_repository.dart';
import 'package:mobileapp/repositories/local_auth_repository.dart';
import 'package:mobileapp/repositories/local_station_repository.dart';
import 'package:mobileapp/services/auth_service.dart';
import 'package:mobileapp/services/station_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _TestNetworkStatusService extends NetworkStatusService {
  @override
  Future<bool> isOnline() async => true;

  @override
  Stream<bool> get onStatusChanged => const Stream<bool>.empty();
}

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Shows login screen', (WidgetTester tester) async {
    final tokenStorage = TokenStorage();
    final networkStatus = _TestNetworkStatusService();
    final localAuth = LocalAuthRepository();
    final localStations = LocalStationRepository();
    final apiClient = ApiClient(
      baseUrl: apiBaseUrl,
      tokenStorage: tokenStorage,
    );
    final authRepository = ApiAuthRepository(
      client: apiClient,
      tokenStorage: tokenStorage,
      localAuth: localAuth,
      localStations: localStations,
      networkStatus: networkStatus,
    );
    final stationRepository = ApiStationRepository(
      client: apiClient,
      tokenStorage: tokenStorage,
      localStations: localStations,
      networkStatus: networkStatus,
    );
    final authService = AuthService(repository: authRepository);
    final stationService = StationService(repository: stationRepository);

    await tester.pumpWidget(
      MinerApp(
        authService: authService,
        stationService: stationService,
        networkStatus: networkStatus,
      ),
    );

    expect(find.text('Вхід'), findsOneWidget);
  });
}
