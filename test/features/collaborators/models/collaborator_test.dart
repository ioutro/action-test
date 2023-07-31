import 'package:desafio_clock_it_in/features/collaborators/models/collaborator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Collaborator', () {
    test('fromJson deve criar colaborador com sucesso', () {
      final json = {
        'id': 'id',
        'name': 'nome',
        'personalId': 12345,
        'biometric': [[1.1, 2.2, 3.3]],
        'pic': {'type': 'Buffer', 'data': [1, 2, 3]},
        'createdAt': 'createdAt',
        'faker': false,
      };

      final collaborator = Collaborator.fromJson(json);

      expect(collaborator.id, 'id');
      expect(collaborator.name, 'nome');
      expect(collaborator.personalId, 12345);
      expect(collaborator.biometric, [1.1, 2.2, 3.3]);
      expect(collaborator.pic, [1, 2, 3]);
      expect(collaborator.createdAt, 'createdAt');
      expect(collaborator.faker, false);
    });
  });
}