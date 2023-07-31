import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/collaborator.dart';

abstract interface class ICollaboratorLocalRepository {
  Future<void> addColaborator(Collaborator colaborator);
  Future<void> updateColaborator(int index, Collaborator colaborator);
  Future<void> deleteColaborator(int index);
  List<Collaborator> getColaborators();
  Future<void> clearColaborators();
}

final class HiveColaboratorLocalRepository implements ICollaboratorLocalRepository {
  late Box<Collaborator> colaboratorBox;

  HiveColaboratorLocalRepository(this.colaboratorBox);

  @override
  Future addColaborator(Collaborator colaborator) async {
    await colaboratorBox.add(colaborator);
  }

  @override
  Future updateColaborator(int index, Collaborator colaborator) async {
    await colaboratorBox.putAt(index, colaborator);
  }

  @override
  Future deleteColaborator(int index) async {
    await colaboratorBox.deleteAt(index);
  }

  @override
  List<Collaborator> getColaborators() {
    return colaboratorBox.values.toList();
  }

  @override
  Future clearColaborators() async {
    await colaboratorBox.clear();
  }
}
