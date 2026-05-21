import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobileapp/api/api_client.dart';
import 'package:mobileapp/services/auth_service.dart';

enum RegisterStatus { idle, loading, success, failure }

class RegisterState {
  const RegisterState({
    this.status = RegisterStatus.idle,
    this.errorMessage,
  });

  final RegisterStatus status;
  final String? errorMessage;

  RegisterState copyWith({
    RegisterStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RegisterState(
      status: status ?? this.status,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit({required AuthService authService})
      : _authService = authService,
        super(const RegisterState());

  final AuthService _authService;

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(status: RegisterStatus.loading, clearError: true));
    try {
      await _authService.register(
        name: name,
        email: email,
        password: password,
      );
      emit(state.copyWith(status: RegisterStatus.success));
    } catch (error) {
      final message = error is ApiException ? error.message : error.toString();
      emit(
        state.copyWith(
          status: RegisterStatus.failure,
          errorMessage: message,
        ),
      );
    }
  }

  void resetStatus() {
    emit(state.copyWith(status: RegisterStatus.idle, clearError: true));
  }
}
