import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:niddepoule/features/auth/data/models/user_profile.dart';
import 'package:niddepoule/features/profile/domain/services/gamification_service.dart';

/// Gestion des profils utilisateurs Firestore.
class UserService {
  UserService(this._firestore, {GamificationService? gamification})
      : _gamification = gamification ?? GamificationService();

  final FirebaseFirestore _firestore;
  final GamificationService _gamification;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Future<UserProfile?> getById(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserProfile.fromMap(doc.data()!, id: doc.id);
  }

  Future<void> save(UserProfile profile) async {
    await _users.doc(profile.uid).set(
      profile.copyWith(updatedAt: DateTime.now()).toMap(),
      SetOptions(merge: true),
    );
  }

  Future<void> ensureProfileExists({
    required String uid,
    required String fullName,
    required String email,
    String? photoUrl,
  }) async {
    final existing = await getById(uid);
    if (existing != null) return;
    final now = DateTime.now();
    final profile = UserProfile(
      uid: uid,
      fullName: fullName,
      email: email,
      photoUrl: photoUrl,
      createdAt: now,
      updatedAt: now,
    );
    await save(profile);
  }

  Stream<UserProfile?> watchUserProfile(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      final data = doc.data();
      if (!doc.exists || data == null) return null;
      return UserProfile.fromMap(data, id: doc.id);
    });
  }

  /// Calcule le profil mis a jour apres un signalement (sans ecrire).
  UserProfile applyReportReward({
    required UserProfile profile,
    required bool hasPhoto,
    bool communityConfirmed = false,
  }) {
    return _gamification.applyReportReward(
      profile: profile,
      hasPhoto: hasPhoto,
      communityConfirmed: communityConfirmed,
    );
  }
}
