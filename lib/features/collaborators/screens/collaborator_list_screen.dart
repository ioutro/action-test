import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/cubit/auth_cubit.dart';
import '../cubit/collaborator_list_cubit.dart';
import 'collaborator_detail_screen.dart';

class CollaboratorListScreen extends StatefulWidget {
  const CollaboratorListScreen({super.key});

  @override
  State<CollaboratorListScreen> createState() => _CollaboratorListScreenState();
}

class _CollaboratorListScreenState extends State<CollaboratorListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Collaborators List"),
        actions: [
          IconButton(
              onPressed: () {
                context.read<AuthCubit>().signOut();
              },
              icon: const Icon(Icons.exit_to_app))
        ],
      ),
      body: BlocBuilder<CollaboratorListCubit, CollaboratorListState>(
        builder: (context, state) {
          return switch (state) {
            CollaboratorListLoadingState _ => const Center(
                child: CircularProgressIndicator(),
              ),
            CollaboratorListErrorState _ => Center(
                child: Text(state.error),
              ),
            CollaboratorListLoadedState _ => ListView.builder(
                shrinkWrap: true,
                itemCount: state.colaborators.length,
                itemBuilder: (context, index) {
                  final colaborator = state.colaborators[index];
                  return ListTile(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CollaboratorDetailsScreen(
                          colaborator: colaborator,
                        ),
                      ),
                    ),
                    title: Text(colaborator.name),
                  );
                },
              )
          };
        },
      ),
    );
  }
}
