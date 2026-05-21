import 'package:mobileapp/api/api_client.dart';
import 'package:mobileapp/api/api_config.dart';
import 'package:mobileapp/api/api_station_mapper.dart';
import 'package:mobileapp/api/token_storage.dart';
import 'package:mobileapp/models/station_list.dart';
import 'package:mobileapp/models/user.dart';
import 'package:mobileapp/network/network_status_service.dart';
import 'package:mobileapp/repositories/auth_repository.dart';
import 'package:mobileapp/repositories/local_auth_repository.dart';
import 'package:mobileapp/repositories/local_station_repository.dart';

class ApiAuthRepository extends IAuthRepository {
  ApiAuthRepository({
    ApiClient? client,
    TokenStorage? tokenStorage,
    LocalAuthRepository? localAuth,
    LocalStationRepository? localStations,
    NetworkStatusService? networkStatus,
  })  : _tokenStorage = tokenStorage ?? TokenStorage(),
        _localAuth = localAuth ?? LocalAuthRepository(),
        _localStations = localStations ?? LocalStationRepository(),
        _networkStatus = networkStatus ?? NetworkStatusService(),
        _client = client ??
            ApiClient(
              baseUrl: apiBaseUrl,
              tokenStorage: tokenStorage ?? TokenStorage(),
            );

  final ApiClient _client;
  final TokenStorage _tokenStorage;
  final LocalAuthRepository _localAuth;
  final LocalStationRepository _localStations;
  final NetworkStatusService _networkStatus;

  @override
  Future<void> registerUser(User user) async {
    final isOnline = await _networkStatus.isOnline();
    if (!isOnline) {
      throw ApiException(message: 'Немає інтернету');
    }

    await _client.postJson(
      '/auth/register',
      {
        'name': user.name,
        'email': user.email,
        'password': user.password,
      },
    );

    await _localAuth.registerUser(user);
  }

  @override
  Future<User?> login(String email, String password) async {
    try {
      final tokenPayload = await _client.postJson(
        '/auth/login',
        {
          'email': email,
          'password': password,
        },
      );

      final token = tokenPayload['access_token'] as String?;
      if (token == null || token.isEmpty) {
        return null;
      }

      await _tokenStorage.save(token);

      final profile = await _client.getJson('/auth/profile');
      final user = User(
        name: profile['name'] as String? ?? '',
        email: profile['email'] as String? ?? '',
        password: password,
      );

      await _localAuth.registerUser(user);
      await _localAuth.login(user.email, user.password);

      final stations = stationsFromProfile(profile);
      await _localStations.saveStations(
        StationList(items: stations),
      );

      return user;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<User?> getSessionUser() {
    return _localAuth.getSessionUser();
  }

  @override
  Future<void> clearSession() async {
    await _localAuth.clearSession();
    await _tokenStorage.clear();
  }
}
