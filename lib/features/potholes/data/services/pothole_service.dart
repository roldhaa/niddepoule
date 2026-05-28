import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:niddepoule/core/utils/geo_utils.dart';
import 'package:niddepoule/features/potholes/data/models/pothole.dart';
import 'package:niddepoule/features/reports/domain/services/pothole_merge_service.dart';

/// Operations Firestore sur la collection potholes.
class PotholeService {
  PotholeService(
    this._firestore, {
    PotholeMergeService mergeService = const PotholeMergeService(),
  }) : _mergeService = mergeService;

  final FirebaseFirestore _firestore;
  final PotholeMergeService _mergeService;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('potholes');

  Stream<List<Pothole>> watchPotholes() {
    return _collection.snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Pothole.fromMap(doc.data(), id: doc.id))
              .toList(),
        );
  }

  Future<List<Pothole>> fetchNearby({
    required double latitude,
    required double longitude,
    required double radiusMeters,
  }) async {
    final snapshot = await _collection.get();
    return snapshot.docs
        .map((doc) => Pothole.fromMap(doc.data(), id: doc.id))
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

  Future<Pothole?> getById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return Pothole.fromMap(doc.data()!, id: doc.id);
  }

  Future<void> confirmStillPresent(String potholeId) async {
    await _collection.doc(potholeId).update({
      'lastReportedAt': Timestamp.now(),
      'status': 'active',
    });
  }

  Pothole? findDuplicateWithin20m(
    List<Pothole> candidates, {
    required double latitude,
    required double longitude,
  }) {
    return _mergeService.findDuplicate(
      candidates,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
