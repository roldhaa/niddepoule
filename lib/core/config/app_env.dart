class AppEnv {
  /// Firebase reel uniquement.
  static const bool useMockBackend = false;

  static const String mapboxAccessToken =
      String.fromEnvironment('MAPBOX_ACCESS_TOKEN', defaultValue: '');
}
