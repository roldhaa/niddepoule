import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:niddepoule/core/ai/ai_validation_service.dart';
import 'package:niddepoule/core/constants/app_constants.dart';
import 'package:niddepoule/features/auth/data/models/user_profile.dart';
import 'package:niddepoule/features/potholes/data/models/pothole.dart';
import 'package:niddepoule/features/potholes/data/services/pothole_service.dart';
import 'package:niddepoule/features/profile/data/services/user_service.dart';
import 'package:niddepoule/features/reports/data/models/report.dart';
import 'package:niddepoule/features/reports/data/services/storage_service.dart';

/// Orchestration du signalement: Storage + transaction Firestore.
class ReportService {
  ReportService({
    required FirebaseFirestore firestore,
    required StorageService storageService,
    required PotholeService potholeService,
    required UserService userService,
    required AiValidationService aiValidationService,
  })  : _firestore = firestore,
        _storageService = storageService,
        _potholeService = potholeService,
        _userService = userService,
        _aiValidationService = aiValidationService;

  final FirebaseFirestore _firestore;
  final StorageService _storageService;
  final PotholeService _potholeService;
  final UserService _userService;
  final AiValidationService _aiValidationService;

  CollectionReference<Map<String, dynamic>> get _reports =>
      _firestore.collection('reports');

  Stream<List<Report>> watchRecentReports({int limit = 100}) {
    return _reports
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Report.fromMap(doc.data(), id: doc.id))
              .toList(),
        );
  }

  Stream<List<Report>> watchReportsForPothole(String potholeId) {
    return _reports
        .where('duplicateGroupId', isEqualTo: potholeId)
        .snapshots()
        .map(
          (snapshot) {
            final list = snapshot.docs
                .map((doc) => Report.fromMap(doc.data(), id: doc.id))
                .toList();
            // Sort in memory to avoid needing a Firestore composite index
            list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return list;
          },
        );
  }

  Stream<List<Report>> watchUserReports(String userId, {int limit = 100}) {
    return _reports
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Report.fromMap(doc.data(), id: doc.id))
              .toList(),
        );
  }

  /// Soumet un signalement avec anti-doublon et XP en transaction Firestore.
  Future<Report> submitReport({
    required UserProfile user,
    required double latitude,
    required double longitude,
    required DangerLevel dangerLevel,
    String? description,
    File? photoFile,
    String? city,
    String? linkedPotholeId,
  }) async {
    final geohash = _computeGeohash(latitude, longitude);
    final reportRef = _reports.doc();
    final newPotholeRef = _firestore.collection('potholes').doc();

    String? photoUrl;
    if (photoFile != null) {
      photoUrl = await _storageService.uploadReportPhoto(
        file: photoFile,
        userId: user.uid,
      );
    }

    var aiStatus = AiValidationStatus.pending;
    var aiScore = 0;
    if (photoUrl != null) {
      final ai = await _aiValidationService.validatePotholeImage(photoUrl);
      aiStatus = ai.isPothole ? AiValidationStatus.approved : AiValidationStatus.rejected;
      aiScore = ai.dangerScore;
    }

    Pothole? duplicate;
    if (linkedPotholeId != null) {
      duplicate = await _potholeService.getById(linkedPotholeId);
      if (duplicate == null) {
        throw StateError('Nid-de-poule introuvable: $linkedPotholeId');
      }
    } else {
      final nearby = await _potholeService.fetchNearby(
        latitude: latitude,
        longitude: longitude,
        radiusMeters: AppConstants.duplicateRadiusMeters * 2.5,
      );
      duplicate = _potholeService.findDuplicateWithin20m(
        nearby,
        latitude: latitude,
        longitude: longitude,
      );
    }

    final now = DateTime.now();
    final potholeId = duplicate?.id ?? newPotholeRef.id;

    await _firestore.runTransaction((transaction) async {
      final userRef = _firestore.collection('users').doc(user.uid);
      final userSnap = await transaction.get(userRef);
      if (!userSnap.exists || userSnap.data() == null) {
        throw StateError('Profil utilisateur introuvable: ${user.uid}');
      }

      if (duplicate != null) {
        final potholeRef = _firestore.collection('potholes').doc(duplicate.id);
        final potholeSnap = await transaction.get(potholeRef);
        if (!potholeSnap.exists || potholeSnap.data() == null) {
          throw StateError('Pothole introuvable pendant la transaction.');
        }
        final existing = Pothole.fromMap(potholeSnap.data()!, id: potholeSnap.id);
        final photos = List<String>.from(existing.photoUrls);
        if (photoUrl != null) photos.add(photoUrl);

        transaction.update(potholeRef, {
          'id': existing.id,
          'reportCount': existing.reportCount + 1,
          'lastReportedAt': Timestamp.fromDate(now),
          'dangerLevel': dangerLevel.name,
          'photoUrls': photos,
        });
      } else {
        transaction.set(newPotholeRef, {
          ...Pothole(
            id: newPotholeRef.id,
            latitude: latitude,
            longitude: longitude,
            geohash: geohash,
            dangerLevel: dangerLevel,
            reportCount: 1,
            status: 'open',
            firstReportedAt: now,
            lastReportedAt: now,
            photoUrls: photoUrl == null ? [] : [photoUrl],
            city: city,
          ).toMap(),
          'id': newPotholeRef.id,
        });
      }

      final report = Report(
        id: reportRef.id,
        userId: user.uid,
        potholeId: potholeId,
        latitude: latitude,
        longitude: longitude,
        geohash: geohash,
        description: description,
        photoUrl: photoUrl,
        dangerLevel: dangerLevel,
        aiValidationStatus: aiStatus,
        aiDangerScore: aiScore,
        status: 'open',
        duplicateGroupId: potholeId,
        createdAt: now,
        updatedAt: now,
        city: city,
      );
      transaction.set(reportRef, {
        ...report.toMap(),
      });

      final profile = UserProfile.fromMap(userSnap.data()!, id: userSnap.id);
      final updated = _userService.applyReportReward(
        profile: profile,
        hasPhoto: photoUrl != null,
        communityConfirmed: false,
      );
      transaction.update(userRef, {
        'uid': profile.uid,
        'xp': updated.xp,
        'reportsCount': updated.reportsCount,
        'badges': updated.badges,
        'updatedAt': Timestamp.fromDate(now),
      });
    });

    final saved = await reportRef.get();
    return Report.fromMap(saved.data()!, id: saved.id);
  }

  String _computeGeohash(double lat, double lon) {
    return '${lat.toStringAsFixed(4)}_${lon.toStringAsFixed(4)}';
  }
}
