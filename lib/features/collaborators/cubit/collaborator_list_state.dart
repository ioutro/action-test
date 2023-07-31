part of 'collaborator_list_cubit.dart';

sealed class CollaboratorListState extends Equatable {}

class CollaboratorListLoadingState extends CollaboratorListState {
  @override
  List<Object?> get props => [];
}

class CollaboratorListLoadedState extends CollaboratorListState {
  final List<Collaborator> colaborators;
  CollaboratorListLoadedState(this.colaborators);
  @override
  List<Object?> get props => [colaborators];
}

class CollaboratorListErrorState extends CollaboratorListState {
  final String error;
  CollaboratorListErrorState(this.error);
  @override
  List<Object?> get props => [error];
}
