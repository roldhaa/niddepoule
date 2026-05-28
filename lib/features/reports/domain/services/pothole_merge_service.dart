import 'package:niddepoule/core/constants/app_constants.dart';
import 'package:niddepoule/core/utils/geo_utils.dart';
import 'package:niddepoule/features/potholes/data/models/pothole.dart';

class PotholeMergeService {
  const PotholeMergeService();

  Pothole? findDuplicate(
    List<Pothole> candidates, {
    required double latitude,
    required double longitude,
    double thresholdMeters = AppConstants.duplicateRadiusMeters,
  }) {
    for (final pothole in candidates) {
      final distance = GeoUtils.distanceInMeters(
        latitude,
        longitude,
        pothole.latitude,
        pothole.longitude,
      );
      if (distance <= thresholdMeters) return pothole;
    }
    return null;
  }
}
