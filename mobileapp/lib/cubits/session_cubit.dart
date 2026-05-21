import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobileapp/services/auth_service.dart';

enum SessionStatus { idle, loggingOut, loggedOut, failure }

class SessionState {
  const SessionState({
    this.status = SessionStatus.idle,
    this.errorMessage,
  });

  final SessionStatus status;
  final String? errorMessage;

  SessionState copyWith({
    SessionStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SessionState(
      status: status ?? this.status,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class SessionCubit extends Cubit<SessionState> {
  SessionCubit({required AuthService authService})
      : _authService = authService,
        super(const SessionState());

  final AuthService _authService;

  Future<void> logout() async {
    emit(state.copyWith(status: SessionStatus.loggingOut, clearError: true));
    try {
      await _authService.logout();
      emit(state.copyWith(status: SessionStatus.loggedOut));
    } catch (error) {
      emit(
        state.copyWith(
          status: SessionStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void reset() {
    emit(state.copyWith(status: SessionStatus.idle, clearError: true));
  }
}
