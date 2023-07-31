import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/token.dart';

abstract class IAuthUserRepository {
  Future<Token> signIn(String username, String password);
  Future<Token> signUp(String name, String username, String password);
  Future<Token?> refreshToken(String refreshToken);
  Future<void> signOut(String accessToken);
  Future<bool> checkAuth(String accessToken);
}

class AuthUserRepository implements IAuthUserRepository {
  final http.Client httpClient;

  AuthUserRepository({required this.httpClient});

  // simples rest api para autenticação jwt
  static const kHost = 'https://eastern-thinker-316700.uc.r.appspot.com';

  @override
  Future<Token> signIn(String username, String password) async {
    final response = await httpClient.post(
      Uri.parse('$kHost/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to sign in');
    }

    final json = jsonDecode(response.body);
    return Token(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
    );
  }

  @override
  Future<Token> signUp(String name, String username, String password) async {
    final response = await httpClient.post(
      Uri.parse('$kHost/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          {'name': username, 'username': username, 'password': password}),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to sign up');
    }

    final json = jsonDecode(response.body);
    return Token(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
    );
  }

  @override
  Future<Token?> refreshToken(String refreshToken) async {
    final response = await httpClient.post(
      Uri.parse('$kHost/auth/refresh'),
      headers: {'Authorization': 'Bearer $refreshToken'},
    );

    if (response.statusCode != 200) {
      return null;
    }

    final json = jsonDecode(response.body);
    return Token(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
    );
  }

  @override
  Future<void> signOut(String accessToken) async {
    final response = await httpClient.post(
      Uri.parse('$kHost/auth/logout'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to sign out');
    }
  }

  @override
  Future<bool> checkAuth(String accessToken) async {
    final response = await httpClient.post(
      Uri.parse('$kHost/auth/check-auth'),
      headers: {'Authorization': 'Bearer $refreshToken'},
    );

    return response.statusCode == 200;
  }
}
