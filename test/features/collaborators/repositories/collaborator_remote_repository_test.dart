import 'package:desafio_clock_it_in/features/collaborators/models/collaborator.dart';
import 'package:desafio_clock_it_in/features/collaborators/repositories/collaborator_remote_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

import 'collaborator_remote_repository_test.mocks.dart';



@GenerateMocks([http.Client])
void main() {
  group('HttpCollaboratorRemoteRepository', () {
    late MockClient httpClient;
    late HttpCollaboratorRemoteRepository collaboratorRemoteRepository;

    setUp(() {
      httpClient = MockClient();
      collaboratorRemoteRepository = HttpCollaboratorRemoteRepository(httpClient);
    });

    test('getCollaborators retorna lista de colaboradores se a chamada da api completa com sucesso', () async {
      when(httpClient.get(any)).thenAnswer((_) async => http.Response('''
      [
        {
          "id": "testId",
          "name": "John Doe",
          "personalId": 12345,
          "biometric": [[1.1, 2.2, 3.3]],
          "pic": {"data": [1, 2, 3]},
          "createdAt": "createdAt",
          "faker": false
        }
      ]''', 200));
      
      final collaborators = await collaboratorRemoteRepository.getCollaborators();

      expect(collaborators, isA<List<Collaborator>>());
      expect(collaborators.first.id, 'testId');
    });

    test('getCollaborators joga Exception se a chamada completa com erro', () {
      when(httpClient.get(any)).thenAnswer((_) async => http.Response('Not Found', 404));

      expect(collaboratorRemoteRepository.getCollaborators(), throwsA(isA<Exception>()));
    });
  });
}
