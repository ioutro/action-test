import 'dart:convert';

import '../models/collaborator.dart';
import 'package:http/http.dart' as http;

abstract interface class ICollaboratorRemoteRepository {
  Future<List<Collaborator>> getCollaborators();
}

final class HttpCollaboratorRemoteRepository
    implements ICollaboratorRemoteRepository {
  static const kApiUrl = 'https://carma.fun/api/dasa';

  final http.Client _httpClient;

  HttpCollaboratorRemoteRepository(this._httpClient);

  @override
  Future<List<Collaborator>> getCollaborators() async {
    final response = await _httpClient.get(Uri.parse(kApiUrl));

    if (response.statusCode != 200) {
      throw Exception('Error loading data from api');
    }

    final List<dynamic> colaboratorJson = json.decode(response.body);
    return colaboratorJson.map((json) => Collaborator.fromJson(json)).toList();
  }
}
