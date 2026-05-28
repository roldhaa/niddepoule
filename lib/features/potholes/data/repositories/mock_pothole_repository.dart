import 'dart:async';

import 'package:niddepoule/core/utils/geo_utils.dart';
import 'package:niddepoule/features/potholes/data/models/pothole.dart';
import 'package:niddepoule/features/potholes/data/repositories/pothole_repository.dart';
import 'package:niddepoule/features/reports/data/models/report.dart';

class MockPotholeRepository implements PotholeRepository {
  final _controller = StreamController<List<Pothole>>.broadcast();
  final List<Pothole> _potholes = [];

  MockPotholeRepository() {
    _controller.add(_potholes);
  }

  @override
  Stream<List<Pothole>> watchPotholes() => _controller.stream;

  @override
  Future<List<Pothole>> fetchNearby({
    required double latitude,
    required double longitude,
    required double radiusMeters,
  }) async {
    return _potholes
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
    final index = _potholes.indexWhere((p) => p.id == pothole.id);
    if (index == -1) {
      _potholes.add(pothole);
    } else {
      _potholes[index] = pothole;
    }
    _controller.add(List<Pothole>.from(_potholes));
  }

  Pothole createFromReport({
    required String id,
    required double latitude,
    required double longitude,
    required String geohash,
    required DangerLevel level,
    required String? photoUrl,
    required String? city,
  }) {
    final now = DateTime.now();
    return Pothole(
      id: id,
      latitude: latitude,
      longitude: longitude,
      geohash: geohash,
      dangerLevel: level,
      reportCount: 1,
      status: 'open',
      firstReportedAt: now,
      lastReportedAt: now,
      photoUrls: photoUrl == null ? [] : [photoUrl],
      city: city,
    );
  }
}
