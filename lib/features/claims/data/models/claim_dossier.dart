class ClaimDossier {
  ClaimDossier({
    required this.reportId,
    required this.generatedAt,
    required this.latitude,
    required this.longitude,
    required this.historyCount,
    required this.photoUrls,
    required this.claimStrengthScore,
  });

  final String reportId;
  final DateTime generatedAt;
  final double latitude;
  final double longitude;
  final int historyCount;
  final List<String> photoUrls;
  final int claimStrengthScore;
}
