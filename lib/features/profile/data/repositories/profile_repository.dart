import 'package:niddepoule/features/auth/data/models/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile?> getById(String uid);
  Future<void> save(UserProfile profile);
}
