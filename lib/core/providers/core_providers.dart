import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:niddepoule/core/ai/ai_validation_service.dart';
import 'package:niddepoule/core/ai/mock_ai_validation_service.dart';
import 'package:niddepoule/core/location/location_service.dart';
import 'package:niddepoule/core/map/map_service.dart';
import 'package:niddepoule/core/map/mapbox_map_service.dart';
import 'package:niddepoule/features/auth/data/services/auth_service.dart';
import 'package:niddepoule/features/claims/data/repositories/claim_repository.dart';
import 'package:niddepoule/features/claims/data/repositories/mock_claim_repository.dart';
import 'package:niddepoule/features/comments/data/services/comment_service.dart';
import 'package:niddepoule/features/potholes/data/services/pothole_service.dart';
import 'package:niddepoule/features/profile/data/services/user_service.dart';
import 'package:niddepoule/features/profile/domain/services/gamification_service.dart';
import 'package:niddepoule/features/reports/data/services/report_service.dart';
import 'package:niddepoule/features/reports/data/services/storage_service.dart';
import 'package:niddepoule/features/reports/domain/services/pothole_merge_service.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((_) => FirebaseAuth.instance);
final firestoreProvider =
    Provider<FirebaseFirestore>((_) => FirebaseFirestore.instance);
final storageProvider = Provider<FirebaseStorage>((_) => FirebaseStorage.instance);

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService(ref.watch(storageProvider));
});

final userServiceProvider = Provider<UserService>((ref) {
  return UserService(ref.watch(firestoreProvider));
});

final potholeServiceProvider = Provider<PotholeService>((ref) {
  return PotholeService(ref.watch(firestoreProvider));
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    ref.watch(firebaseAuthProvider),
    ref.watch(userServiceProvider),
  );
});

final reportServiceProvider = Provider<ReportService>((ref) {
  return ReportService(
    firestore: ref.watch(firestoreProvider),
    storageService: ref.watch(storageServiceProvider),
    potholeService: ref.watch(potholeServiceProvider),
    userService: ref.watch(userServiceProvider),
    aiValidationService: ref.watch(aiValidationServiceProvider),
  );
});

final commentServiceProvider = Provider<CommentService>((ref) {
  return CommentService(ref.watch(firestoreProvider));
});

final claimRepositoryProvider = Provider<ClaimRepository>((_) {
  return MockClaimRepository();
});

final mapServiceProvider = Provider<MapService>((_) => MapboxMapService());
final locationServiceProvider = Provider<LocationService>((_) => LocationService());
final aiValidationServiceProvider =
    Provider<AiValidationService>((_) => MockAiValidationService());
final potholeMergeServiceProvider =
    Provider<PotholeMergeService>((_) => const PotholeMergeService());
final gamificationServiceProvider =
    Provider<GamificationService>((_) => GamificationService());
