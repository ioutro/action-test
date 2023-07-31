import 'package:desafio_clock_it_in/features/auth/models/token.dart';
import 'package:desafio_clock_it_in/features/auth/repositories/token_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'token_repository_test.mocks.dart';

@GenerateMocks([FlutterSecureStorage])
void main() {
  late MockFlutterSecureStorage mockFlutterSecureStorage;
  late TokenRepository tokenRepository;

  setUp(() {
    mockFlutterSecureStorage = MockFlutterSecureStorage();
    tokenRepository = TokenRepository(secureStorage: mockFlutterSecureStorage);
  });

  group('saveToken', () {
    const testToken = Token(accessToken: 'access', refreshToken: 'refresh');

    test('Deve salvar o token de acesso e o refresh token', () async {
      when(mockFlutterSecureStorage.write(
              key: anyNamed('key'), value: anyNamed('value')))
          .thenAnswer((_) async {});

      await tokenRepository.saveToken(testToken);

      verify(
        mockFlutterSecureStorage.write(key: 'accessToken', value: 'access'),
      ).called(1);
      verify(
        mockFlutterSecureStorage.write(key: 'refreshToken', value: 'refresh'),
      ).called(1);
    });
  });

  group('getToken', () {
    test('Deve retornar null quando o token de acesso ou refresh token não existe',
        () async {
      when(mockFlutterSecureStorage.read(key: anyNamed('key')))
          .thenAnswer((_) async => null);

      final result = await tokenRepository.getToken();

      expect(result, isNull);
    });

    test('Deve retornar o token quando o token de acesso e de refresh existem',
        () async {
      when(mockFlutterSecureStorage.read(key: anyNamed('key')))
          .thenAnswer((_) async => 'token');

      final result = await tokenRepository.getToken();

      expect(result, isA<Token>());
      expect(result!.accessToken, equals('token'));
      expect(result.refreshToken, equals('token'));
    });
  });

  group('deleteToken', () {
    test('Deve deletar ambos os tokens de acesso e de refresh', () async {
      when(mockFlutterSecureStorage.delete(key: anyNamed('key')))
          .thenAnswer((_) async {});

      await tokenRepository.deleteToken();

      verify(mockFlutterSecureStorage.delete(key: 'accessToken')).called(1);
      verify(mockFlutterSecureStorage.delete(key: 'refreshToken')).called(1);
    });
  });
}
