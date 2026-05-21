import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mobileapp/api/api_client.dart';
import 'package:mobileapp/api/api_config.dart';
import 'package:mobileapp/api/token_storage.dart';
import 'package:mobileapp/cubits/login_cubit.dart';
import 'package:mobileapp/cubits/profile_cubit.dart';
import 'package:mobileapp/cubits/register_cubit.dart';
import 'package:mobileapp/cubits/session_cubit.dart';
import 'package:mobileapp/cubits/stations_cubit.dart';
import 'package:mobileapp/network/network_status_service.dart';
import 'package:mobileapp/repositories/api_auth_repository.dart';
import 'package:mobileapp/repositories/api_station_repository.dart';
import 'package:mobileapp/repositories/local_auth_repository.dart';
import 'package:mobileapp/repositories/local_station_repository.dart';
import 'package:mobileapp/screens/home_page.dart';
import 'package:mobileapp/screens/login_page.dart';
import 'package:mobileapp/screens/profile_page.dart';
import 'package:mobileapp/screens/register_page.dart';
import 'package:mobileapp/services/auth_service.dart';
import 'package:mobileapp/services/station_service.dart';

void main() {
  final tokenStorage = TokenStorage();
  final networkStatus = NetworkStatusService();
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

  runApp(
    MinerApp(
      authService: authService,
      stationService: stationService,
      networkStatus: networkStatus,
    ),
  );
}

class MinerApp extends StatelessWidget {
  const MinerApp({
    required this.authService,
    required this.stationService,
    required this.networkStatus,
    super.key,
  });

  final AuthService authService;
  final StationService stationService;
  final NetworkStatusService networkStatus;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authService),
        RepositoryProvider.value(value: stationService),
        RepositoryProvider.value(value: networkStatus),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => SessionCubit(authService: authService),
          ),
        ],
        child: MaterialApp(
          title: 'Miner Lab',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.amber,
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => BlocProvider(
                  create: (context) => LoginCubit(
                    authService: context.read<AuthService>(),
                    networkStatus: context.read<NetworkStatusService>(),
                  ),
                  child: const LoginPage(),
                ),
            '/register': (context) => BlocProvider(
                  create: (context) => RegisterCubit(
                    authService: context.read<AuthService>(),
                  ),
                  child: const RegisterPage(),
                ),
            '/home': (context) => BlocProvider(
                  create: (context) => StationsCubit(
                    stationService: context.read<StationService>(),
                    networkStatus: context.read<NetworkStatusService>(),
                  )..initialize(),
                  child: const HomePage(),
                ),
            '/profile': (context) => BlocProvider(
                  create: (context) => ProfileCubit(
                    authService: context.read<AuthService>(),
                    stationService: context.read<StationService>(),
                  )..initialize(),
                  child: const ProfilePage(),
                ),
          },
        ),
      ),
    );
  }
}
