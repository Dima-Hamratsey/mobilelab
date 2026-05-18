import 'dart:convert';

import 'package:mobileapp/models/user.dart';
import 'package:mobileapp/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalAuthRepository extends IAuthRepository {
  LocalAuthRepository({SharedPreferences? preferences})
      : _preferences = preferences == null
            ? SharedPreferences.getInstance()
            : Future.value(preferences);

  final Future<SharedPreferences> _preferences;

  static const String _userKey = 'registered_user';
  static const String _sessionKey = 'session_user';

  @override
  Future<void> registerUser(User user) async {
    final prefs = await _preferences;
    final payload = jsonEncode(user.toJson());
    await prefs.setString(_userKey, payload);
  }

  @override
  Future<User?> login(String email, String password) async {
    final prefs = await _preferences;
    final rawUser = prefs.getString(_userKey);
    if (rawUser == null) {
      return null;
    }

    final storedUser = User.fromJson(
      jsonDecode(rawUser) as Map<String, dynamic>,
    );

    if (storedUser.email != email || storedUser.password != password) {
      return null;
    }

    await prefs.setString(_sessionKey, rawUser);
    return storedUser;
  }

  @override
  Future<User?> getSessionUser() async {
    final prefs = await _preferences;
    final rawUser = prefs.getString(_sessionKey);
    if (rawUser == null) {
      return null;
    }

    return User.fromJson(jsonDecode(rawUser) as Map<String, dynamic>);
  }

  @override
  Future<void> clearSession() async {
    final prefs = await _preferences;
    await prefs.remove(_sessionKey);
  }
}
