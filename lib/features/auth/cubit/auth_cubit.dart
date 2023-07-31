import 'package:desafio_clock_it_in/features/auth/services/local_auth_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/token.dart';
import '../repositories/auth_user_repository.dart';
import '../repositories/token_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final IAuthUserRepository _userRepository;
  final ITokenRepository _tokenRepository;
  final ILocalAuthService _localAuthService;

  AuthCubit(
      {required IAuthUserRepository userRepository,
      required ITokenRepository tokenRepository,
      required ILocalAuthService localAuthService})
      : _tokenRepository = tokenRepository,
        _userRepository = userRepository,
        _localAuthService = localAuthService,
        super(AuthLoading()) {
    () async {
      await Future.delayed(const Duration(seconds: 1));
      initialCheck();
    }();
  }

  Future<void> signIn(String email, String password) async {
    emit(AuthLoading());

    try {
      final token = await _userRepository.signIn(email, password);
      if (await _localAuthService.isBiometricAvailable()) {
        final didAuthenticate = await _localAuthService.authenticate();
        if (!didAuthenticate) {
          emit(AuthFailure(
              error: 'Failed biometric auth', didBiometricFail: true));
          return;
        }
      }

      await _tokenRepository.saveToken(token);

      emit(AuthLoggedIn(token));
    } catch (e) {
      emit(AuthFailure(error: e.toString(), didBiometricFail: false));
    }
  }

  Future<void> signUp(String name, String username, String password) async {
    emit(AuthLoading());

    try {
      final token = await _userRepository.signUp(name, username, password);
      await _tokenRepository.saveToken(token);
      emit(AuthLoggedIn(token));
    } catch (e) {
      emit(AuthFailure(error: e.toString(), didBiometricFail: false));
    }
  }

  Future<void> refreshToken() async {
    emit(AuthLoading());

    try {
      final oldToken = await _tokenRepository.getToken();
      if (oldToken == null) {
        emit(AuthLoggedOut());
        return;
      }

      final newToken =
          await _userRepository.refreshToken(oldToken.refreshToken);

      // expired token
      if (newToken == null) {
        print("token expired");
        await _tokenRepository.deleteToken();
        emit(AuthLoggedOut());
        return;
      }

      await _tokenRepository.saveToken(newToken);
      emit(AuthLoggedIn(newToken));
    } catch (e) {
      emit(AuthFailure(error: e.toString(), didBiometricFail: false));
    }
  }

  Future<void> signOut() async {
    emit(AuthLoading());

    try {
      final token = await _tokenRepository.getToken();
      if (token != null) {
        await _userRepository.signOut(token.accessToken);
        await _tokenRepository.deleteToken();
      }
      emit(AuthLoggedOut());
    } catch (e) {
      emit(AuthFailure(error: e.toString(), didBiometricFail: false));
    }
  }

  Future<void> initialCheck() async {
    final hasTokenStored = (await _tokenRepository.getToken()) != null;

    if (!hasTokenStored) {
      emit(AuthLoggedOut());
      return;
    }

    // Requere biometria para continuar com autenticação
    if (await _localAuthService.isBiometricAvailable()) {
      final didAuthenticate = await _localAuthService.authenticate();
      if (!didAuthenticate) {
        emit(AuthFailure(
            error: 'Failed biometric authentication', didBiometricFail: true));
        return;
      }
    }

    refreshToken();
  }
}
