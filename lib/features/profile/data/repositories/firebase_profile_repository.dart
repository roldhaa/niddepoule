import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:niddepoule/features/auth/data/models/user_profile.dart';
import 'package:niddepoule/features/profile/data/repositories/profile_repository.dart';

class FirebaseProfileRepository implements ProfileRepository {
  FirebaseProfileRepository(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<UserProfile?> getById(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromMap(doc.data()!, id: doc.id);
  }

  @override
  Future<void> save(UserProfile profile) async {
    await _firestore.collection('users').doc(profile.uid).set(profile.toMap());
  }
}
