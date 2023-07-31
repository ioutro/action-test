import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

abstract interface class ILocalAuthService {
  Future<bool> isBiometricAvailable();
  Future<bool> authenticate();
}

class LocalAuthService implements ILocalAuthService {
  final LocalAuthentication auth;

  LocalAuthService({required this.auth});

  @override
  Future<bool> isBiometricAvailable() async {
    if (kIsWeb) return false;
    final canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    final hasDeviceSupport = await auth.isDeviceSupported();
    return canAuthenticateWithBiometrics && hasDeviceSupport;
  }

  @override
  Future<bool> authenticate() async {
    try {
      return await auth.authenticate(
        localizedReason: 'Biometric authentication needed.',
        options: const AuthenticationOptions(useErrorDialogs: true),
      );
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }
}
