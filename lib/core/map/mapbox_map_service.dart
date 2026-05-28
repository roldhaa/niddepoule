import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:niddepoule/core/config/app_env.dart';
import 'package:niddepoule/core/map/map_service.dart';

class MapboxMapService implements MapService {
  @override
  Future<void> initialize() async {
    if (AppEnv.mapboxAccessToken.isNotEmpty) {
      MapboxOptions.setAccessToken(AppEnv.mapboxAccessToken);
    }
  }
}
