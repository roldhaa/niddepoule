import 'package:niddepoule/features/auth/data/models/user_profile.dart';
import 'package:niddepoule/features/profile/data/repositories/profile_repository.dart';

class MockProfileRepository implements ProfileRepository {
  final Map<String, UserProfile> _profiles = {};

  @override
  Future<UserProfile?> getById(String uid) async => _profiles[uid];

  @override
  Future<void> save(UserProfile profile) async {
    _profiles[profile.uid] = profile;
  }
}
