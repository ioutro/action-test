import 'package:bloc_test/bloc_test.dart';
import 'package:desafio_clock_it_in/features/auth/cubit/auth_cubit.dart';
import 'package:desafio_clock_it_in/features/auth/models/token.dart';
import 'package:desafio_clock_it_in/features/auth/repositories/auth_user_repository.dart';
import 'package:desafio_clock_it_in/features/auth/repositories/token_repository.dart';
import 'package:desafio_clock_it_in/features/auth/services/local_auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_cubit_test.mocks.dart';

@GenerateMocks([IAuthUserRepository, ITokenRepository, ILocalAuthService])
void main() {
  late AuthCubit authCubit;
  late MockIAuthUserRepository userRepository;
  late MockITokenRepository tokenRepository;
  late MockILocalAuthService localAuthService;

  setUp(() {
    userRepository = MockIAuthUserRepository();
    tokenRepository = MockITokenRepository();
    localAuthService = MockILocalAuthService();
    authCubit = AuthCubit(
      userRepository: userRepository,
      tokenRepository: tokenRepository,
      localAuthService: localAuthService,
    );
  });

  tearDown(() {
    authCubit.close();
  });

  group('signIn', () {
    const token = Token(accessToken: 'access', refreshToken: 'refresh');

    blocTest<AuthCubit, AuthState>(
      'Deve emitir [AuthLoading, AuthLoggedIn] quando signIn é concluido com sucesso e a autenticação biometrica não está disponivel',
      build: () => authCubit,
      act: (cubit) => cubit.signIn('email', 'password'),
      expect: () => [
        AuthLoading(),
        AuthLoggedIn(token),
      ],
      setUp: () {
        when(userRepository.signIn(any, any)).thenAnswer((_) async => token);
        when(localAuthService.isBiometricAvailable())
            .thenAnswer((_) async => false);
        when(tokenRepository.saveToken(any)).thenAnswer((_) async {});
      },
    );

    blocTest<AuthCubit, AuthState>(
      'Deve emitir [AuthLoading, AuthFailure] quando signIn é concluido com sucesso mas autenticação biometrica falha',
      build: () => authCubit,
      act: (cubit) => cubit.signIn('email', 'password'),
      expect: () => [
        AuthLoading(),
        AuthFailure(error: 'Failed biometric auth', didBiometricFail: true),
      ],
      setUp: () {
        when(userRepository.signIn(any, any)).thenAnswer((_) async => token);
        when(localAuthService.isBiometricAvailable())
            .thenAnswer((_) async => true);
        when(localAuthService.authenticate()).thenAnswer((_) async => false);
      },
    );

    blocTest<AuthCubit, AuthState>(
      'Deve emitir [AuthLoading, AuthFailure] quando signIn lança Exception',
      build: () => authCubit,
      act: (cubit) => cubit.signIn('email', 'password'),
      expect: () => [
        AuthLoading(),
        AuthFailure(error: 'Exception: Failed', didBiometricFail: false),
      ],
      setUp: () {
        when(userRepository.signIn(any, any)).thenThrow(Exception('Failed'));
      },
    );
  });

  group('signUp', () {
    const token = Token(accessToken: 'access', refreshToken: 'refresh');

    blocTest<AuthCubit, AuthState>(
      'Deve emitir [AuthLoading, AuthLoggedIn] quando signUp tem sucesso',
      build: () => authCubit,
      act: (cubit) => cubit.signUp('name', 'username', 'password'),
      expect: () => [
        AuthLoading(),
        AuthLoggedIn(token),
      ],
      setUp: () {
        when(userRepository.signUp(any, any, any))
            .thenAnswer((_) async => token);
        when(tokenRepository.saveToken(any)).thenAnswer((_) async {});
      },
    );

    blocTest<AuthCubit, AuthState>(
      'Deve emitir [AuthLoading, AuthFailure] quando signUp lança Exception',
      build: () => authCubit,
      act: (cubit) => cubit.signUp('name', 'username', 'password'),
      expect: () => [
        AuthLoading(),
        AuthFailure(error: 'Exception: Failed', didBiometricFail: false),
      ],
      setUp: () {
        when(userRepository.signUp(any, any, any))
            .thenThrow(Exception('Failed'));
      },
    );
  });

  group('refreshToken', () {
    const oldToken =
        Token(accessToken: 'old_access', refreshToken: 'old_refresh');
    const newToken =
        Token(accessToken: 'new_access', refreshToken: 'new_refresh');

    blocTest<AuthCubit, AuthState>(
      'Deve emitir [AuthLoading, AuthLoggedIn] quando refreshToken tem sucesso',
      build: () => authCubit,
      act: (cubit) => cubit.refreshToken(),
      expect: () => [
        AuthLoading(),
        AuthLoggedIn(newToken),
      ],
      setUp: () {
        when(tokenRepository.getToken()).thenAnswer((_) async => oldToken);
        when(userRepository.refreshToken(any))
            .thenAnswer((_) async => newToken);
        when(tokenRepository.saveToken(any)).thenAnswer((_) async {});
      },
    );

    blocTest<AuthCubit, AuthState>(
      'Deve emitir [AuthLoading, AuthLoggedOut] quando refreshToken retorna nulo (token expirado)',
      build: () => authCubit,
      act: (cubit) => cubit.refreshToken(),
      expect: () => [
        AuthLoading(),
        AuthLoggedOut(),
      ],
      setUp: () {
        when(tokenRepository.getToken()).thenAnswer((_) async => oldToken);
        when(userRepository.refreshToken(any)).thenAnswer((_) async => null);
        when(tokenRepository.deleteToken()).thenAnswer((_) async {});
      },
    );
  });

  group('signOut', () {
    const token = Token(accessToken: 'access', refreshToken: 'refresh');

    blocTest<AuthCubit, AuthState>(
      'Deve emitir [AuthLoading, AuthLoggedOut] quando signOut tem sucesso',
      build: () => authCubit,
      act: (cubit) => cubit.signOut(),
      expect: () => [
        AuthLoading(),
        AuthLoggedOut(),
      ],
      setUp: () {
        when(tokenRepository.getToken()).thenAnswer((_) async => token);
        when(userRepository.signOut(any)).thenAnswer((_) async {});
        when(tokenRepository.deleteToken()).thenAnswer((_) async {});
      },
    );

    blocTest<AuthCubit, AuthState>(
      'Deve emitir [AuthLoading, AuthFailure] quando signOut lança Exception',
      build: () => authCubit,
      act: (cubit) => cubit.signOut(),
      expect: () => [
        AuthLoading(),
        AuthFailure(error: 'Exception: Failed', didBiometricFail: false),
      ],
      setUp: () {
        when(tokenRepository.getToken()).thenAnswer((_) async => token);
        when(userRepository.signOut(any)).thenThrow(Exception('Failed'));
      },
    );
  });

  group('initialCheck', () {
    const token = Token(accessToken: 'access', refreshToken: 'refresh');

    blocTest<AuthCubit, AuthState>(
      'Deve emitir [AuthLoggedOut] quando initialCheck não acha nenhum token',
      build: () => authCubit,
      act: (cubit) => cubit.initialCheck(),
      expect: () => [
        AuthLoggedOut(),
      ],
      setUp: () {
        when(tokenRepository.getToken()).thenAnswer((_) async => null);
      },
    );

    blocTest<AuthCubit, AuthState>(
      'Deve emitir [AuthFailure] quando initialCheck acha um token mas a autenticação biometrica falha',
      build: () => authCubit,
      act: (cubit) => cubit.initialCheck(),
      expect: () => [
        AuthFailure(
            error: 'Failed biometric authentication', didBiometricFail: true),
      ],
      setUp: () {
        when(tokenRepository.getToken()).thenAnswer((_) async => token);
        when(localAuthService.isBiometricAvailable())
            .thenAnswer((_) async => true);
        when(localAuthService.authenticate()).thenAnswer((_) async => false);
      },
    );
  });
}
