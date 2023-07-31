import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/token.dart';

abstract class ITokenRepository {
  Future<void> saveToken(Token token);
  Future<Token?> getToken();
  Future<void> deleteToken();
}

class TokenRepository implements ITokenRepository {
  final FlutterSecureStorage secureStorage;

  TokenRepository({required this.secureStorage});

  @override
  Future<void> saveToken(Token token) async {
    await secureStorage.write(key: 'accessToken', value: token.accessToken);
    await secureStorage.write(key: 'refreshToken', value: token.refreshToken);
    if (kDebugMode) {
      print("tokens saved");
    }
  }

  @override
  Future<Token?> getToken() async {
    final accessToken = await secureStorage.read(key: 'accessToken');
    final refreshToken = await secureStorage.read(key: 'refreshToken');

    if (accessToken != null && refreshToken != null) {
      return Token(accessToken: accessToken, refreshToken: refreshToken);
    } else {
      return null;
    }
  }

  @override
  Future<void> deleteToken() async {
    await secureStorage.delete(key: 'accessToken');
    await secureStorage.delete(key: 'refreshToken');
  }
}
