import 'package:desafio_clock_it_in/features/auth/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .secondaryContainer
                .withOpacity(0.2),
            borderRadius: const BorderRadius.all(
              Radius.circular(8),
            ),
          ),
          padding: const EdgeInsets.all(32),
          child: BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
            return switch (state) {
              AuthFailure() => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      state.error,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    ElevatedButton(
                      onPressed: context.read<AuthCubit>().initialCheck,
                      child: const Text("Authenticate"),
                    ),
                  ],
                ),
              _ => CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
            };
          }),
        ),
      ),
    );
  }
}
