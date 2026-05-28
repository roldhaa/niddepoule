import 'package:niddepoule/features/claims/data/models/claim_dossier.dart';

abstract class ClaimRepository {
  Future<ClaimDossier> buildDossier({
    required String reportId,
  });
}
