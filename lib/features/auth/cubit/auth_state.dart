part of 'auth_cubit.dart';

sealed class AuthState extends Equatable{}

class AuthLoggedOut extends AuthState {
  AuthLoggedOut();
  
  @override
  List<Object?> get props => [];
}

class AuthLoading extends AuthState {
  @override
  List<Object?> get props => [];
}

class AuthLoggedIn extends AuthState {
  final Token token;
  AuthLoggedIn(this.token);

  @override
  List<Object?> get props => [token];
}

class AuthFailure extends AuthState {
  final String error;
  final bool didBiometricFail;
  AuthFailure({required this.error, required this.didBiometricFail});

  @override
  List<Object?> get props => [error, didBiometricFail];
}
