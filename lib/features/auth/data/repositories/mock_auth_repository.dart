import 'dart:async';

import 'package:niddepoule/features/auth/data/models/user_profile.dart';
import 'package:niddepoule/features/auth/data/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  final _controller = StreamController<UserProfile?>.broadcast();
  UserProfile? _current;

  @override
  Stream<UserProfile?> authStateChanges() => _controller.stream;

  @override
  Future<UserProfile> signIn({
    required String email,
    required String password,
  }) async {
    final now = DateTime.now();
    _current ??= UserProfile(
      uid: 'mock-user',
      fullName: 'Utilisateur CivicRoad',
      email: email,
      createdAt: now,
      updatedAt: now,
    );
    _controller.add(_current);
    return _current!;
  }

  @override
  Future<UserProfile> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final now = DateTime.now();
    _current = UserProfile(
      uid: DateTime.now().millisecondsSinceEpoch.toString(),
      fullName: fullName,
      email: email,
      createdAt: now,
      updatedAt: now,
    );
    _controller.add(_current);
    return _current!;
  }

  @override
  Future<void> signOut() async {
    _current = null;
    _controller.add(null);
  }
}
