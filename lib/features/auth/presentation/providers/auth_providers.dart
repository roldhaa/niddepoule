import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:niddepoule/core/providers/core_providers.dart';
import 'package:niddepoule/features/auth/data/models/user_profile.dart';

/// Etat d authentification (stream).
final authStateProvider = StreamProvider<UserProfile?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges();
});

/// Utilisateur connecte courant.
final currentUserProvider = Provider<UserProfile?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController(this.ref) : super(const AsyncData(null));

  final Ref ref;

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      await ref.read(authServiceProvider).signIn(
            email: email,
            password: password,
          );
    });
    state = result.hasError
        ? AsyncError(result.error!, result.stackTrace!)
        : const AsyncData(null);
  }

  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      await ref.read(authServiceProvider).signUp(
            fullName: fullName,
            email: email,
            password: password,
          );
    });
    state = result.hasError
        ? AsyncError(result.error!, result.stackTrace!)
        : const AsyncData(null);
  }

  Future<void> signOut() async {
    await ref.read(authServiceProvider).signOut();
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>(
  (ref) => AuthController(ref),
);
