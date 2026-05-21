import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  TokenStorage({SharedPreferences? preferences})
      : _preferences = preferences == null
            ? SharedPreferences.getInstance()
            : Future.value(preferences);

  final Future<SharedPreferences> _preferences;

  static const String _tokenKey = 'auth_token';

  Future<void> save(String token) async {
    final prefs = await _preferences;
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> read() async {
    final prefs = await _preferences;
    return prefs.getString(_tokenKey);
  }

  Future<void> clear() async {
    final prefs = await _preferences;
    await prefs.remove(_tokenKey);
  }
}
