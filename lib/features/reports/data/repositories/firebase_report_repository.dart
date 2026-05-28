import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:niddepoule/features/reports/data/models/report.dart';
import 'package:niddepoule/features/reports/data/repositories/report_repository.dart';
import 'package:niddepoule/features/reports/data/services/storage_service.dart';

/// Compatibilite legacy - preferer [ReportService].
class FirebaseReportRepository implements ReportRepository {
  FirebaseReportRepository(this._firestore, this._storage);

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  late final StorageService _storageService = StorageService(_storage);

  @override
  Stream<List<Report>> watchRecentReports() {
    return _firestore
        .collection('reports')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Report.fromMap(doc.data(), id: doc.id))
              .toList(),
        );
  }

  @override
  Future<Report> createReport(CreateReportInput input) async {
    final now = DateTime.now();
    final doc = _firestore.collection('reports').doc();
    String? photoUrl;
    if (input.photoFile != null) {
      photoUrl = await _storageService.uploadReportPhoto(
        file: input.photoFile!,
        userId: input.userId,
      );
    }
    final report = Report(
      id: doc.id,
      userId: input.userId,
      potholeId: input.potholeId,
      latitude: input.latitude,
      longitude: input.longitude,
      geohash: input.geohash,
      description: input.description,
      photoUrl: photoUrl,
      dangerLevel: input.dangerLevel,
      aiValidationStatus: AiValidationStatus.pending,
      aiDangerScore: 0,
      status: 'open',
      duplicateGroupId: input.potholeId,
      createdAt: now,
      updatedAt: now,
      city: input.city,
    );
    await doc.set(report.toMap());
    return report;
  }
}
