import 'dart:async';
import 'dart:math';
import 'package:desafio_clock_it_in/features/collaborators/repositories/collaborator_local_repository.dart';
import 'package:desafio_clock_it_in/features/collaborators/repositories/collaborator_remote_repository.dart';
import 'package:desafio_clock_it_in/features/collaborators/services/notification_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/collaborator.dart';

part 'collaborator_list_state.dart';

class CollaboratorListCubit extends Cubit<CollaboratorListState> {
  CollaboratorListCubit(
    this._collaboratorLocalRepository,
    this._iCollaboratorRemoteRepository,
    this._notificationService,
    {
      int notificationIntervalSeconds = 60, 
    }
  ) : super(CollaboratorListLoadingState()) {
    _timer = Timer.periodic(Duration(seconds: notificationIntervalSeconds),
        (Timer t) => showRandomColaboratorNotification());
  }

  late Timer _timer;
  final ICollaboratorLocalRepository _collaboratorLocalRepository;
  final ICollaboratorRemoteRepository _iCollaboratorRemoteRepository;
  final INotificationService _notificationService;

  @override
  Future<void> close() async {
    super.close();
    _timer.cancel();
  }

  Future<void> load() async {
    emit(CollaboratorListLoadingState());

    try {
      final collaborators =
          await _iCollaboratorRemoteRepository.getCollaborators();
      emit(CollaboratorListLoadedState(collaborators));
      // salvar no banco de dados local
      for (final collaborator in collaborators) {
        await _collaboratorLocalRepository.addColaborator(collaborator);
      }
    } catch (e) {
      emit(CollaboratorListErrorState('Error loading data from API'));
    }
  }

  Future<void> showRandomColaboratorNotification() async {
    final colaborators = switch (state) {
      CollaboratorListLoadedState loaded => loaded.colaborators,
      _ => null
    };

    if (colaborators == null) return;
    if (colaborators.isEmpty) return;

    if (kDebugMode) {
      print("showing notification");
    }

    if (colaborators.isNotEmpty) {
      final random = Random();
      final randomColaborator =
          colaborators[random.nextInt(colaborators.length)];
      await _notificationService
          .showNotificationWithColaborator(randomColaborator);
    }
  }
}
