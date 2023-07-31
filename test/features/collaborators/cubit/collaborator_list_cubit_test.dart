import 'package:desafio_clock_it_in/features/collaborators/cubit/collaborator_list_cubit.dart';
import 'package:desafio_clock_it_in/features/collaborators/models/collaborator.dart';
import 'package:desafio_clock_it_in/features/collaborators/repositories/collaborator_local_repository.dart';
import 'package:desafio_clock_it_in/features/collaborators/repositories/collaborator_remote_repository.dart';
import 'package:desafio_clock_it_in/features/collaborators/services/notification_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'collaborator_list_cubit_test.mocks.dart';

@GenerateMocks([
  ICollaboratorLocalRepository,
  ICollaboratorRemoteRepository,
  INotificationService
])
void main() {
  late MockICollaboratorLocalRepository localRepository;
  late MockICollaboratorRemoteRepository remoteRepository;
  late MockINotificationService notificationService;

  final Collaborator mockCollaborator = Collaborator(
    id: 'id',
    name: 'name',
    personalId: 0,
    biometric: [0.0, 0.0],
    pic: [1, 2, 3],
    createdAt: 'createdAt',
    faker: false,
  );

  setUp(() {
    localRepository = MockICollaboratorLocalRepository();
    remoteRepository = MockICollaboratorRemoteRepository();
    notificationService = MockINotificationService();
  });

  group('CollaboratorListCubit', () {
    test('Deve ter o estado inicial como loading', () {
      final cubit = CollaboratorListCubit(
        localRepository,
        remoteRepository,
        notificationService,
      );

      expect(cubit.state, isA<CollaboratorListLoadingState>());
      cubit.close();
    });

    blocTest<CollaboratorListCubit, CollaboratorListState>(
      'Deve buscar e emitir a lista de colabores',
      build: () {
        when(remoteRepository.getCollaborators()).thenAnswer(
          (_) async => [mockCollaborator, mockCollaborator],
        );

        return CollaboratorListCubit(
          localRepository,
          remoteRepository,
          notificationService,
        );
      },
      act: (cubit) => cubit.load(),
      expect: () => [
        CollaboratorListLoadingState(),
        CollaboratorListLoadedState([mockCollaborator, mockCollaborator]),
      ],
    );

    blocTest<CollaboratorListCubit, CollaboratorListState>(
      'Deve buscar e salvar a lista de colaboradores no repositorio local',
      build: () {
        when(remoteRepository.getCollaborators()).thenAnswer(
          (_) async => [mockCollaborator, mockCollaborator],
        );

        return CollaboratorListCubit(
          localRepository,
          remoteRepository,
          notificationService,
        );
      },
      act: (cubit) => cubit.load(),
      verify: (_) {
        verify(
          localRepository.addColaborator(any),
        ).called(2);
      },
    );

    blocTest<CollaboratorListCubit, CollaboratorListState>(
      'Deve emitir estado de erro quando o repositorio remoto lança Exception',
      build: () {
        when(remoteRepository.getCollaborators()).thenThrow(Exception());

        return CollaboratorListCubit(
          localRepository,
          remoteRepository,
          notificationService,
        );
      },
      act: (cubit) => cubit.load(),
      expect: () => [
        CollaboratorListLoadingState(),
        CollaboratorListErrorState('Error loading data from API'),
      ],
    );

    blocTest<CollaboratorListCubit, CollaboratorListState>(
      'showRandomColaboratorNotification deve fazer nada quando o estado não é CollaboratorListLoadedState',
      build: () {
        return CollaboratorListCubit(
          localRepository,
          remoteRepository,
          notificationService,
          notificationIntervalSeconds: 1,
        );
      },
      act: (cubit) => cubit.showRandomColaboratorNotification(),
      verify: (_) {
        verifyNever(notificationService.showNotificationWithColaborator(any));
      },
    );

    blocTest<CollaboratorListCubit, CollaboratorListState>(
      'showRandomColaboratorNotification deve fazer nada quando a lista de colabores é vazia',
      build: () {
        when(remoteRepository.getCollaborators()).thenAnswer((_) async => []);

        return CollaboratorListCubit(
          localRepository,
          remoteRepository,
          notificationService,
          notificationIntervalSeconds: 1,
        )..load();
      },
      act: (cubit) => cubit.showRandomColaboratorNotification(),
      wait: const Duration(seconds: 1),
      verify: (_) {
        verifyNever(notificationService.showNotificationWithColaborator(any));
      },
    );

    blocTest<CollaboratorListCubit, CollaboratorListState>(
      'showRandomColaboratorNotification deve mostrar notificação quando a lista de colabores não é vazia',
      build: () {
        when(remoteRepository.getCollaborators()).thenAnswer(
          (_) async => [mockCollaborator, mockCollaborator],
        );

        return CollaboratorListCubit(
          localRepository,
          remoteRepository,
          notificationService,
          notificationIntervalSeconds: 1,
        )..load();
      },
      act: (cubit) => cubit.showRandomColaboratorNotification(),
      wait: const Duration(seconds: 1),
      verify: (_) {
        verify(notificationService.showNotificationWithColaborator(any))
            .called(1);
      },
    );
  });
}
