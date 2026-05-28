import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:niddepoule/features/claims/presentation/providers/claims_providers.dart';

class CreateClaimDossierScreen extends ConsumerWidget {
  const CreateClaimDossierScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const reportId = 'sample-report';
    final dossier = ref.watch(claimDossierProvider(reportId));
    return Scaffold(
      appBar: AppBar(title: const Text('Creer un dossier de preuve')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: dossier.when(
          data: (d) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Outil de documentation seulement. Aucune promesse '
                'de compensation ou de victoire juridique.',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Text('Rapport: ${d.reportId}'),
              Text('Date: ${d.generatedAt}'),
              Text('GPS: ${d.latitude}, ${d.longitude}'),
              Text('Historique: ${d.historyCount} signalements'),
              Text('Score de force: ${d.claimStrengthScore}/100'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: null,
                child: const Text('Exporter en PDF (bientot)'),
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text(e.toString()),
        ),
      ),
    );
  }
}
