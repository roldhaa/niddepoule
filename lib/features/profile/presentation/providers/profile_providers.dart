import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:niddepoule/features/auth/data/models/user_profile.dart';
import 'package:niddepoule/features/auth/presentation/providers/auth_providers.dart';
import 'package:niddepoule/core/providers/core_providers.dart';

final currentUserProfileProvider = Provider<UserProfile?>((ref) {
  return ref.watch(currentUserProvider);
});

final userProfileStreamProvider =
    StreamProvider.family<UserProfile?, String>((ref, uid) {
  return ref.watch(userServiceProvider).watchUserProfile(uid);
});
