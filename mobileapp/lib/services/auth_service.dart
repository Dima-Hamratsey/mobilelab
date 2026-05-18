import 'package:mobileapp/models/user.dart';
import 'package:mobileapp/repositories/auth_repository.dart';

class AuthService {
  AuthService({required IAuthRepository repository}) : _repository = repository;

  final IAuthRepository _repository;

  String? validateName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) {
      return 'Вкажіть ім\'я';
    }
    if (RegExp(r'\d').hasMatch(name)) {
      return 'Ім\'я не може містити цифри';
    }
    return null;
  }

  String? validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Вкажіть пошту';
    }
    final isValid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
      .hasMatch(email);
    if (!isValid) {
      return 'Некоректна пошта';
    }
    return null;
  }

  String? validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) {
      return 'Вкажіть пароль';
    }
    if (password.length < 8) {
      return 'Мінімум 8 символів';
    }
    return null;
  }

  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final user = User(
      name: name.trim(),
      email: email.trim().toLowerCase(),
      password: password,
    );
    await _repository.registerUser(user);
    await _repository.login(user.email, user.password);
    return user;
  }

  Future<User?> login({
    required String email,
    required String password,
  }) async {
    return _repository.login(email.trim().toLowerCase(), password);
  }

  Future<User?> getSessionUser() {
    return _repository.getSessionUser();
  }

  Future<void> logout() {
    return _repository.clearSession();
  }
}
