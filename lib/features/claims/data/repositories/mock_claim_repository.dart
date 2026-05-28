import 'package:niddepoule/features/claims/data/models/claim_dossier.dart';
import 'package:niddepoule/features/claims/data/repositories/claim_repository.dart';

class MockClaimRepository implements ClaimRepository {
  @override
  Future<ClaimDossier> buildDossier({required String reportId}) async {
    return ClaimDossier(
      reportId: reportId,
      generatedAt: DateTime.now(),
      latitude: 46.8139,
      longitude: -71.2080,
      historyCount: 4,
      photoUrls: const [],
      claimStrengthScore: 62,
    );
  }
}
