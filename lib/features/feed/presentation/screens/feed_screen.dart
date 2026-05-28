import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:niddepoule/app/design_system/app_spacing.dart';
import 'package:niddepoule/core/widgets/civic_empty_state.dart';
import 'package:niddepoule/core/widgets/civic_scaffold.dart';
import 'package:niddepoule/core/widgets/civic_shimmer.dart';
import 'package:niddepoule/features/feed/presentation/providers/feed_providers.dart';
import 'package:niddepoule/features/shared/widgets/civic_report_feed_card.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reports = ref.watch(feedReportsProvider);

    return CivicScaffold(
      title: 'Feed civique',
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(feedReportsProvider);
          await ref.read(feedReportsProvider.future);
        },
        child: reports.when(
          data: (items) {
            if (items.isEmpty) {
              return const CivicEmptyState(
                title: 'Aucun signalement récent',
                subtitle: 'Les signalements de la communauté apparaîtront ici.',
                icon: Icons.dynamic_feed,
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: items.length,
              itemBuilder: (context, index) =>
                  CivicReportFeedCard(report: items[index]),
            );
          },
          loading: () => const CivicListShimmer(),
          error: (e, _) => CivicEmptyState(
            title: 'Erreur de chargement',
            subtitle: '$e',
            icon: Icons.error_outline,
          ),
        ),
      ),
    );
  }
}
