import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:niddepoule/features/auth/data/models/user_profile.dart';
import 'package:niddepoule/features/auth/data/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth, this._firestore);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  Stream<UserProfile?> authStateChanges() {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        final now = DateTime.now();
        final profile = UserProfile(
          uid: user.uid,
          fullName: user.displayName ?? 'Nouveau citoyen',
          email: user.email ?? '',
          photoUrl: user.photoURL,
          createdAt: now,
          updatedAt: now,
        );
        await _firestore.collection('users').doc(user.uid).set(profile.toMap());
        return profile;
      }
      return UserProfile.fromMap(doc.data()!, id: doc.id);
    });
  }

  @override
  Future<UserProfile> signIn({
    required String email,
    required String password,
  }) async {
    final credential =
        await _auth.signInWithEmailAndPassword(email: email, password: password);
    final user = credential.user!;
    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists) return UserProfile.fromMap(doc.data()!, id: doc.id);
    final now = DateTime.now();
    final profile = UserProfile(
      uid: user.uid,
      fullName: user.displayName ?? 'Citoyen',
      email: user.email ?? email,
      photoUrl: user.photoURL,
      createdAt: now,
      updatedAt: now,
    );
    await _firestore.collection('users').doc(user.uid).set(profile.toMap());
    return profile;
  }

  @override
  Future<UserProfile> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.updateDisplayName(fullName);
    final now = DateTime.now();
    final profile = UserProfile(
      uid: credential.user!.uid,
      fullName: fullName,
      email: email,
      createdAt: now,
      updatedAt: now,
    );
    await _firestore.collection('users').doc(profile.uid).set(profile.toMap());
    return profile;
  }

  @override
  Future<void> signOut() => _auth.signOut();
}
