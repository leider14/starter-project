import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repository/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInRequested>(_onAuthSignInRequested);
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
    on<AuthProfileUpdateRequested>(_onAuthProfileUpdateRequested);
  }

  Future<void> _onAuthCheckRequested(
      AuthCheckRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _authRepository.getCurrentUser();
    if (result is DataSuccess) {
      emit(Authenticated(result.data!));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onAuthSignInRequested(
      AuthSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _authRepository.signIn(
      email: event.email,
      password: event.password,
    );
    if (result is DataSuccess) {
      emit(Authenticated(result.data!));
    } else {
      emit(AuthError(result.error?.error?.toString() ?? 'Login failed'));
    }
  }

  Future<void> _onAuthSignUpRequested(
      AuthSignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _authRepository.signUp(
      email: event.email,
      password: event.password,
      fullName: event.fullName,
      bio: event.bio,
      image: event.image,
    );
    if (result is DataSuccess) {
      emit(Authenticated(result.data!));
    } else {
      emit(AuthError(result.error?.error?.toString() ?? 'Registration failed'));
    }
  }

  Future<void> _onAuthSignOutRequested(
      AuthSignOutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await _authRepository.signOut();
    emit(Unauthenticated());
  }

  Future<void> _onAuthProfileUpdateRequested(
      AuthProfileUpdateRequested event, Emitter<AuthState> emit) async {
    final currentState = state;
    if (currentState is Authenticated) {
      emit(AuthLoading());
      final result = await _authRepository.updateProfile(
        fullName: event.fullName,
        bio: event.bio,
        image: event.image,
      );
      if (result is DataSuccess) {
        emit(Authenticated(result.data!));
      } else {
        emit(AuthError(result.error?.error?.toString() ?? 'Update failed'));
        emit(Authenticated(currentState.user));
      }
    }
  }
}
