import 'package:flutter/material.dart';

import '../models/collaborator.dart';

class CollaboratorDetailsScreen extends StatelessWidget {
  final Collaborator colaborator;
  const CollaboratorDetailsScreen({super.key, required this.colaborator});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collaborator Details'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Name'),
            subtitle: Text(colaborator.name),
          ),
          ListTile(
            title: Text('ID'),
            subtitle: Text(colaborator.id),
          ),
          ListTile(
            title: const Text('Personal ID'),
            subtitle: Text(colaborator.personalId.toString()),
          ),
          ListTile(
            title: const Text('Biometric Data'),
            subtitle: Text(colaborator.biometric.join(', ')),
          ),
          ListTile(
            title: const Text('Pic'),
            subtitle: Text(colaborator.pic.join(', ')),
          ),
          ListTile(
            title: const Text('Created At'),
            subtitle: Text(colaborator.createdAt),
          ),
          ListTile(
            title: const Text('Faker'),
            subtitle: Text(colaborator.faker ? 'Yes' : 'No'),
          ),
        ],
      ),
    );
  }
}
