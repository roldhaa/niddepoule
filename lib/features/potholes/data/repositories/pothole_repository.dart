import 'package:niddepoule/features/potholes/data/models/pothole.dart';

abstract class PotholeRepository {
  Stream<List<Pothole>> watchPotholes();
  Future<List<Pothole>> fetchNearby({
    required double latitude,
    required double longitude,
    required double radiusMeters,
  });
  Future<void> upsert(Pothole pothole);
}
