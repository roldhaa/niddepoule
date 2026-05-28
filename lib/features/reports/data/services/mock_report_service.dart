import 'dart:io';

import 'package:niddepoule/features/auth/data/models/user_profile.dart';
import 'package:niddepoule/features/potholes/data/models/pothole.dart';
import 'package:niddepoule/features/potholes/data/repositories/mock_pothole_repository.dart';
import 'package:niddepoule/features/profile/data/repositories/mock_profile_repository.dart';
import 'package:niddepoule/features/profile/domain/services/gamification_service.dart';
import 'package:niddepoule/features/reports/data/models/report.dart';
import 'package:niddepoule/features/reports/data/repositories/mock_report_repository.dart';
import 'package:niddepoule/features/reports/data/repositories/report_repository.dart';
import 'package:niddepoule/features/reports/domain/services/pothole_merge_service.dart';

/// Service mock pour developpement sans Firebase configure.
class MockReportService {
  MockReportService({
    MockReportRepository? reportRepository,
    MockPotholeRepository? potholeRepository,
    MockProfileRepository? profileRepository,
    PotholeMergeService? mergeService,
    GamificationService? gamification,
  })  : _reportRepository = reportRepository ?? MockReportRepository(),
        _potholeRepository = potholeRepository ?? MockPotholeRepository(),
        _profileRepository = profileRepository ?? MockProfileRepository(),
        _mergeService = mergeService ?? const PotholeMergeService(),
        _gamification = gamification ?? GamificationService();

  final MockReportRepository _reportRepository;
  final MockPotholeRepository _potholeRepository;
  final MockProfileRepository _profileRepository;
  final PotholeMergeService _mergeService;
  final GamificationService _gamification;

  Stream<List<Report>> watchRecentReports() =>
      _reportRepository.watchRecentReports();

  Stream<List<Report>> watchReportsForPothole(String potholeId) {
    return _reportRepository.watchRecentReports().map(
          (reports) => reports
              .where((r) => r.duplicateGroupId == potholeId)
              .toList(),
        );
  }

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
    final geohash = '${latitude.toStringAsFixed(4)}_${longitude.toStringAsFixed(4)}';
    final report = await _reportRepository.createReport(
      CreateReportInput(
        userId: user.uid,
        latitude: latitude,
        longitude: longitude,
        geohash: geohash,
        dangerLevel: dangerLevel,
        description: description,
        photoFile: photoFile,
        city: city,
      ),
    );

    Pothole? duplicate;
    if (linkedPotholeId != null) {
      final all = await _potholeRepository.fetchNearby(
        latitude: latitude,
        longitude: longitude,
        radiusMeters: 100000,
      );
      duplicate = all.where((p) => p.id == linkedPotholeId).firstOrNull;
      duplicate ??= Pothole(
        id: linkedPotholeId,
        latitude: latitude,
        longitude: longitude,
        geohash: geohash,
        dangerLevel: dangerLevel,
        reportCount: 0,
        status: 'open',
        firstReportedAt: DateTime.now(),
        lastReportedAt: DateTime.now(),
      );
    } else {
      final nearby = await _potholeRepository.fetchNearby(
        latitude: latitude,
        longitude: longitude,
        radiusMeters: 50,
      );
      duplicate = _mergeService.findDuplicate(
        nearby,
        latitude: latitude,
        longitude: longitude,
      );
    }

    final String potholeId;
    if (linkedPotholeId != null && duplicate != null) {
      potholeId = duplicate.id;
      await _potholeRepository.upsert(
        duplicate.copyWith(
          reportCount: duplicate.reportCount + 1,
          lastReportedAt: DateTime.now(),
          dangerLevel: dangerLevel,
          photoUrls: [
            ...duplicate.photoUrls,
            if (report.photoUrl != null) report.photoUrl!,
          ],
        ),
      );
    } else if (duplicate != null) {
      potholeId = duplicate.id;
      await _potholeRepository.upsert(
        duplicate.copyWith(
          reportCount: duplicate.reportCount + 1,
          lastReportedAt: DateTime.now(),
          dangerLevel: dangerLevel,
          photoUrls: [
            ...duplicate.photoUrls,
            if (report.photoUrl != null) report.photoUrl!,
          ],
        ),
      );
    } else {
      potholeId = 'p_${DateTime.now().microsecondsSinceEpoch}';
      await _potholeRepository.upsert(
        Pothole(
          id: potholeId,
          latitude: latitude,
          longitude: longitude,
          geohash: geohash,
          dangerLevel: dangerLevel,
          reportCount: 1,
          status: 'open',
          firstReportedAt: report.createdAt,
          lastReportedAt: report.createdAt,
          photoUrls: report.photoUrl == null ? [] : [report.photoUrl!],
          city: city,
        ),
      );
    }

    final linkedReport = report.copyWith(duplicateGroupId: potholeId);
    _reportRepository.updateReport(linkedReport);

    final stored = await _profileRepository.getById(user.uid) ?? user;
    final updated = _gamification.applyReportReward(
      profile: stored,
      hasPhoto: report.photoUrl != null,
      communityConfirmed: false,
    );
    await _profileRepository.save(updated);
    return linkedReport;
  }
}
