import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobileapp/network/network_status_service.dart';
import 'package:mobileapp/services/auth_service.dart';

enum LoginStatus { idle, loading, success, failure }

enum LoginFailureReason { offline, invalidCredentials, unknown }

class LoginState {
  const LoginState({
    this.status = LoginStatus.idle,
    this.failureReason,
  });

  final LoginStatus status;
  final LoginFailureReason? failureReason;

  LoginState copyWith({
    LoginStatus? status,
    LoginFailureReason? failureReason,
    bool clearFailure = false,
  }) {
    return LoginState(
      status: status ?? this.status,
      failureReason: clearFailure ? null : failureReason ?? this.failureReason,
    );
  }
}

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({
    required AuthService authService,
    required NetworkStatusService networkStatus,
  })  : _authService = authService,
        _networkStatus = networkStatus,
        super(const LoginState());

  final AuthService _authService;
  final NetworkStatusService _networkStatus;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final isOnline = await _networkStatus.isOnline();
    if (!isOnline) {
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          failureReason: LoginFailureReason.offline,
        ),
      );
      return;
    }

    emit(state.copyWith(status: LoginStatus.loading, clearFailure: true));
    final user = await _authService.login(email: email, password: password);
    if (user == null) {
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          failureReason: LoginFailureReason.invalidCredentials,
        ),
      );
      return;
    }

    emit(state.copyWith(status: LoginStatus.success, clearFailure: true));
  }

  void resetStatus() {
    emit(state.copyWith(status: LoginStatus.idle, clearFailure: true));
  }
}
