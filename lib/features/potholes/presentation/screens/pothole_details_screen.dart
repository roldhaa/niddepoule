import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:niddepoule/app/design_system/app_spacing.dart';
import 'package:niddepoule/core/utils/date_formatter.dart';
import 'package:niddepoule/core/widgets/civic_button.dart';
import 'package:niddepoule/core/widgets/civic_card.dart';
import 'package:niddepoule/core/widgets/civic_danger_tag.dart';
import 'package:niddepoule/core/widgets/civic_empty_state.dart';
import 'package:niddepoule/core/widgets/civic_loader.dart';
import 'package:niddepoule/core/widgets/civic_scaffold.dart';
import 'package:niddepoule/core/widgets/civic_section_title.dart';
import 'package:niddepoule/core/utils/danger_colors.dart';
import 'package:niddepoule/features/potholes/presentation/providers/pothole_providers.dart';
import 'package:niddepoule/features/reports/data/models/report.dart';

class PotholeDetailsScreen extends ConsumerWidget {
  const PotholeDetailsScreen({super.key, required this.potholeId});

  final String potholeId;

  String _statusLabel(String status) {
    return switch (status) {
      'repaired' => 'Réparé',
      'verification' => 'En vérification',
      _ => 'Actif',
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final potholeAsync = ref.watch(potholeByIdProvider(potholeId));
    final reportsAsync = ref.watch(potholeReportsProvider(potholeId));

    return CivicScaffold(
      title: 'Détail du nid',
      body: potholeAsync.when(
        data: (pothole) {
          if (pothole == null) {
            return const CivicEmptyState(
              title: 'Nid-de-poule introuvable',
              icon: Icons.error_outline,
            );
          }
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              if (pothole.photoUrls.isNotEmpty)
                SizedBox(
                  height: 200,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: pothole.photoUrls.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) => ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        pothole.photoUrls[i],
                        width: 280,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              AppSpacing.vMd,
              CivicDangerTag(level: pothole.dangerLevel),
              AppSpacing.vSm,
              Text('Statut: ${_statusLabel(pothole.status)}'),
              Text('Signalements: ${pothole.reportCount}'),
              Text(
                'Localisation: ${pothole.city ?? "Québec"} '
                '(${pothole.latitude.toStringAsFixed(4)}, '
                '${pothole.longitude.toStringAsFixed(4)})',
              ),
              Text(
                'Premier: ${DateFormatter.shortDate(pothole.firstReportedAt)}',
              ),
              Text(
                'Dernier: ${DateFormatter.shortDate(pothole.lastReportedAt)}',
              ),
              AppSpacing.vLg,
              const CivicSectionTitle(title: 'Historique'),
              reportsAsync.when(
                data: (reports) {
                  if (reports.isEmpty) {
                    return Text(
                      'Aucun signalement lié.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    );
                  }
                  return Column(
                    children: reports
                        .map((r) => _ReportHistoryTile(report: r))
                        .toList(),
                  );
                },
                loading: () => const CivicLoader(),
                error: (e, _) => Text('Erreur: $e'),
              ),
              AppSpacing.vXl,
              CivicButton(
                label: 'Ajouter un signalement',
                icon: Icons.add_a_photo_outlined,
                onPressed: () => context.push(
                  '/home/report?potholeId=$potholeId&redirect=/pothole/$potholeId',
                ),
              ),
              AppSpacing.vSm,
              CivicButton(
                label: 'Dossier de preuve',
                variant: CivicButtonVariant.secondary,
                icon: Icons.folder_open_outlined,
                onPressed: () => context.push('/pothole/$potholeId/proof'),
              ),
            ],
          );
        },
        loading: () => const Center(child: CivicLoader()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}

class _ReportHistoryTile extends StatelessWidget {
  const _ReportHistoryTile({required this.report});

  final Report report;

  @override
  Widget build(BuildContext context) {
    return CivicCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(report.description ?? 'Sans description'),
        subtitle: Text(
          '${DangerColors.label(report.dangerLevel)} · '
          '${DateFormatter.shortDate(report.createdAt)}',
        ),
      ),
    );
  }
}
