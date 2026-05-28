import 'package:niddepoule/features/auth/data/models/user_profile.dart';

abstract class AuthRepository {
  Stream<UserProfile?> authStateChanges();
  Future<UserProfile> signIn({
    required String email,
    required String password,
  });
  Future<UserProfile> signUp({
    required String fullName,
    required String email,
    required String password,
  });
  Future<void> signOut();
}
