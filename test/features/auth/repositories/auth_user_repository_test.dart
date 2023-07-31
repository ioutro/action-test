import 'package:desafio_clock_it_in/features/auth/models/token.dart';
import 'package:desafio_clock_it_in/features/auth/repositories/auth_user_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';

import '../../collaborators/repositories/collaborator_remote_repository_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late MockClient httpClient;
  late AuthUserRepository authUserRepository;

  setUp(() {
    httpClient = MockClient();
    authUserRepository = AuthUserRepository(httpClient: httpClient);
  });

  void whenHttpClientToReturnBadRequest() {
    when(
      httpClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      ),
    ).thenAnswer((_) async => http.Response('Bad request', 400));
  }

  void whenHttpClientToReturnsTokens({required int code}) {
    when(
      httpClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      ),
    ).thenAnswer((_) async =>
        http.Response('{"access_token": "at", "refresh_token": "rt"}', code));
  }

  group('signIn', () {
    const testUsername = 'username';
    const testPassword = 'password';

    test('Deve retornar um token quando o codigo do cliente http for 200', () async {
      whenHttpClientToReturnsTokens(code: 200);

      final token = await authUserRepository.signIn(testUsername, testPassword);

      expect(token, isNotNull);
      expect(token, isA<Token>());
      expect(token.accessToken, 'at');
      expect(token.refreshToken, 'rt');
    });

    test('Deve lançar uma Exception quando um status code de erro é retornado pelo cliente http', () {
      whenHttpClientToReturnBadRequest();

      expect(
        authUserRepository.signIn(testUsername, testPassword),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('signUp', () {
    const testName = 'name';
    const testUsername = 'username';
    const testPassword = 'password';

    test('Deve lançar uma Exception quando um status code de erro é retornado pelo cliente http', () {
      whenHttpClientToReturnBadRequest();

      expect(
        authUserRepository.signUp(testName, testUsername, testPassword),
        throwsA(isA<Exception>()),
      );
    });

    test(
        'Deve retornar um token quando o status code 201 é retornado pelo cliente http',
        () async {
      whenHttpClientToReturnsTokens(code: 201);

      final token =
          await authUserRepository.signUp(testName, testUsername, testPassword);

      expect(token, isNotNull);
      expect(token, isA<Token>());
      expect(token.accessToken, 'at');
      expect(token.refreshToken, 'rt');
    });

    // Add more tests for other edge cases
  });

  group('refreshToken', () {
    const testRefreshToken = 'refreshToken';

    test('Deve retornar null quando o cliente http retorna status code de erro', () async {
      when(
        httpClient.post(
          any,
          headers: anyNamed('headers'),
        ),
      ).thenAnswer((_) async => http.Response('Unauthorized', 401));

      final token = await authUserRepository.refreshToken(testRefreshToken);

      expect(token, isNull);
    });

    test(
        'Deve retornar um token quando o cliente http retorna status code 200',
        () async {
      when(
        httpClient.post(
          any,
          headers: anyNamed('headers'),
        ),
      ).thenAnswer((_) async =>
          http.Response('{"access_token": "at", "refresh_token": "rt"}', 200));

      final token = await authUserRepository.refreshToken(testRefreshToken);

      expect(token, isNotNull);
      expect(token, isA<Token>());
      expect(token?.accessToken, 'at');
      expect(token?.refreshToken, 'rt');
    });
  });

  group('signOut', () {
    const testAccessToken = 'accessToken';

    test('Deve lançar Exception quando um status code de erro é retornado pelo cliente http', () {
      when(
        httpClient.post(
          any,
          headers: anyNamed('headers'),
        ),
      ).thenAnswer((_) async => http.Response('Unauthorized', 401));

      expect(
        authUserRepository.signOut(testAccessToken),
        throwsA(isA<Exception>()),
      );
    });
  });
}
