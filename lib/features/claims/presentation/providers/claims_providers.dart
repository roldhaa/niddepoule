import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:niddepoule/core/providers/core_providers.dart';
import 'package:niddepoule/features/claims/data/models/claim_dossier.dart';

final claimDossierProvider =
    FutureProvider.family<ClaimDossier, String>((ref, reportId) {
  return ref.read(claimRepositoryProvider).buildDossier(reportId: reportId);
});
