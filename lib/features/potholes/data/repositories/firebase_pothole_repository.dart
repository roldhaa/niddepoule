import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:niddepoule/core/utils/geo_utils.dart';
import 'package:niddepoule/features/potholes/data/models/pothole.dart';
import 'package:niddepoule/features/potholes/data/repositories/pothole_repository.dart';
import 'package:niddepoule/features/reports/data/models/report.dart';

class FirebasePotholeRepository implements PotholeRepository {
  FirebasePotholeRepository(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Stream<List<Pothole>> watchPotholes() {
    return _firestore.collection('potholes').snapshots().map(
      (snapshot) => snapshot.docs.map(_fromDoc).toList(),
    );
  }

  @override
  Future<List<Pothole>> fetchNearby({
    required double latitude,
    required double longitude,
    required double radiusMeters,
  }) async {
    final snapshot = await _firestore.collection('potholes').get();
    return snapshot.docs
        .map(_fromDoc)
        .where(
          (p) => GeoUtils.distanceInMeters(
            latitude,
            longitude,
            p.latitude,
            p.longitude,
          ) <=
              radiusMeters,
        )
        .toList();
  }

  @override
  Future<void> upsert(Pothole pothole) async {
    await _firestore.collection('potholes').doc(pothole.id).set({
      'id': pothole.id,
      'latitude': pothole.latitude,
      'longitude': pothole.longitude,
      'geohash': pothole.geohash,
      'dangerLevel': pothole.dangerLevel.name,
      'reportCount': pothole.reportCount,
      'status': pothole.status,
      'firstReportedAt': Timestamp.fromDate(pothole.firstReportedAt),
      'lastReportedAt': Timestamp.fromDate(pothole.lastReportedAt),
      'photoUrls': pothole.photoUrls,
      'city': pothole.city,
      'repairedAt': pothole.repairedAt == null
          ? null
          : Timestamp.fromDate(pothole.repairedAt!),
    });
  }

  Pothole _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    return _fromMap(doc.id, doc.data());
  }

  Pothole _fromMap(String id, Map<String, dynamic> data) {
    return Pothole(
      id: id,
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0,
      geohash: data['geohash'] as String? ?? '',
      dangerLevel: DangerLevel.values.firstWhere(
        (level) => level.name == data['dangerLevel'],
        orElse: () => DangerLevel.medium,
      ),
      reportCount: data['reportCount'] as int? ?? 1,
      status: data['status'] as String? ?? 'open',
      firstReportedAt:
          (data['firstReportedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastReportedAt:
          (data['lastReportedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      photoUrls: (data['photoUrls'] as List<dynamic>? ?? []).cast<String>(),
      city: data['city'] as String?,
      repairedAt: (data['repairedAt'] as Timestamp?)?.toDate(),
    );
  }
}
