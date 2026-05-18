import 'package:mobileapp/models/user.dart';

abstract class IAuthRepository {
  // Реєстрація: зберігає користувача в SharedPrefs
  Future<void> registerUser(User user);

  // Логін: перевіряє пошту та пароль
  Future<User?> login(String email, String password);

  // Поточний користувач з сесії
  Future<User?> getSessionUser();

  // Видалення даних (для Logout)
  Future<void> clearSession();
}
