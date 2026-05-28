import 'package:firebase_auth/firebase_auth.dart';
import 'package:niddepoule/features/auth/data/models/user_profile.dart';
import 'package:niddepoule/features/profile/data/services/user_service.dart';

/// Authentification Firebase + creation profil utilisateur.
class AuthService {
  AuthService(this._auth, this._userService);

  final FirebaseAuth _auth;
  final UserService _userService;

  Stream<UserProfile?> authStateChanges() {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      await _userService.ensureProfileExists(
        uid: user.uid,
        fullName: user.displayName ?? 'Citoyen CivicRoad',
        email: user.email ?? '',
        photoUrl: user.photoURL,
      );
      return _userService.getById(user.uid);
    });
  }

  Future<UserProfile> signIn({
    required String email,
    required String password,
  }) async {
    final UserCredential credential;
    try {
      credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_authErrorMessage(e));
    }
    final user = credential.user!;
    await _userService.ensureProfileExists(
      uid: user.uid,
      fullName: user.displayName ?? 'Citoyen CivicRoad',
      email: user.email ?? email,
      photoUrl: user.photoURL,
    );
    return (await _userService.getById(user.uid))!;
  }

  Future<UserProfile> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final UserCredential credential;
    try {
      credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_authErrorMessage(e));
    }
    await credential.user?.updateDisplayName(fullName);
    final uid = credential.user!.uid;
    final now = DateTime.now();
    final profile = UserProfile(
      uid: uid,
      fullName: fullName,
      email: email,
      createdAt: now,
      updatedAt: now,
    );
    await _userService.save(profile);
    return profile;
  }

  Future<void> signOut() => _auth.signOut();

  User? get currentFirebaseUser => _auth.currentUser;

  String _authErrorMessage(FirebaseAuthException e) {
    return switch (e.code) {
      'invalid-email' => 'Email invalide.',
      'user-disabled' => 'Compte desactive.',
      'user-not-found' => 'Aucun compte associe a cet email.',
      'wrong-password' => 'Mot de passe incorrect.',
      'email-already-in-use' => 'Cet email est deja utilise.',
      'weak-password' => 'Mot de passe trop faible.',
      'operation-not-allowed' => 'Operation non autorisee.',
      'network-request-failed' => 'Reseau indisponible. Verifie internet/DNS.',
      'too-many-requests' => 'Trop de tentatives. Reessaie dans quelques minutes.',
      _ => e.message ?? 'Erreur d authentification.',
    };
  }
}
