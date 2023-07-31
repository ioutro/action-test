import 'package:desafio_clock_it_in/features/auth/services/local_auth_service.dart';
import 'package:desafio_clock_it_in/features/collaborators/repositories/collaborator_local_repository.dart';
import 'package:desafio_clock_it_in/features/collaborators/repositories/collaborator_remote_repository.dart';

import 'package:desafio_clock_it_in/features/collaborators/services/notification_service.dart';
import 'package:desafio_clock_it_in/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';

import 'package:http/http.dart' as http;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

import 'features/auth/cubit/auth_cubit.dart';
import 'features/auth/repositories/auth_user_repository.dart';
import 'features/auth/repositories/token_repository.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/collaborators/cubit/collaborator_list_cubit.dart';
import 'features/collaborators/models/collaborator.dart';
import 'features/collaborators/screens/collaborator_list_screen.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(CollaboratorAdapter());

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();

  NavigatorState get _navigator => _rootNavigatorKey.currentState!;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit(
        userRepository: AuthUserRepository(httpClient: http.Client()),
        tokenRepository: TokenRepository(
          secureStorage: const FlutterSecureStorage(),
        ),
        localAuthService: LocalAuthService(auth: LocalAuthentication()),
      ),
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) async {
          switch (state) {
            case AuthLoading():
              break;
            case AuthLoggedIn():
              final box = await Hive.openBox<Collaborator>('colaborators');
              _navigator.pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => CollaboratorListCubit(
                        HiveColaboratorLocalRepository(box),
                        HttpCollaboratorRemoteRepository(http.Client()),
                        NotificationService(),
                      )..load(),
                      child: const CollaboratorListScreen(),
                    ),
                  ),
                  (_) => false);
              break;
            case AuthLoggedOut():
              _navigator.pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                  (_) => false);
              break;
            case AuthFailure():
              break;
          }
        },
        child: MaterialApp(
          title: 'Clock In It',
          navigatorKey: _rootNavigatorKey,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: const SplashScreen(),
        ),
      ),
    );
  }
}

class UselessWidget extends StatelessWidget {
  const UselessWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
