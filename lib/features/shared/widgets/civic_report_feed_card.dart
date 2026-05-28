import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:niddepoule/app/design_system/app_colors.dart';
import 'package:niddepoule/app/design_system/app_radius.dart';
import 'package:niddepoule/app/design_system/app_spacing.dart';
import 'package:niddepoule/core/config/app_env.dart';
import 'package:niddepoule/core/providers/core_providers.dart';
import 'package:niddepoule/core/utils/date_formatter.dart';
import 'package:niddepoule/core/widgets/civic_avatar.dart';
import 'package:niddepoule/core/widgets/civic_card.dart';
import 'package:niddepoule/core/widgets/civic_danger_tag.dart';
import 'package:niddepoule/features/comments/presentation/widgets/comments_bottom_sheet.dart';
import 'package:niddepoule/features/reports/data/models/report.dart';
import 'package:niddepoule/core/widgets/civic_bottom_sheet.dart';

class CivicReportFeedCard extends ConsumerWidget {
  const CivicReportFeedCard({super.key, required this.report});

  final Report report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(_userNameProvider(report.userId));

    return CivicCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (report.photoUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.lg),
              ),
              child: Stack(
                children: [
                  Image.network(
                    report.photoUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 200,
                      color: AppColors.surfaceSection,
                      child: const Icon(Icons.broken_image_outlined, size: 48),
                    ),
                  ),
                  Positioned(
                    left: AppSpacing.md,
                    bottom: AppSpacing.md,
                    child: CivicDangerTag(level: report.dangerLevel),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (report.photoUrl == null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: CivicDangerTag(level: report.dangerLevel),
                  ),
                Row(
                  children: [
                    userAsync.when(
                      data: (name) => CivicAvatar(name: name, radius: 20),
                      loading: () => const CivicAvatar(radius: 20),
                      error: (_, __) => CivicAvatar(
                        name: report.userId,
                        radius: 20,
                      ),
                    ),
                    AppSpacing.gapH(AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          userAsync.when(
                            data: (name) => Text(
                              name,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            loading: () => const Text('Chargement...'),
                            error: (_, __) => Text('Citoyen'),
                          ),
                          Text(
                            '${report.city ?? "Québec"} · '
                            '${DateFormatter.shortDate(report.createdAt)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                AppSpacing.vMd,
                Text(
                  report.description ?? 'Sans description',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                AppSpacing.vMd,
                Row(
                  children: [
                    _ActionChip(
                      icon: Icons.chat_bubble_outline,
                      label: 'Commenter',
                      onTap: () => showCivicBottomSheet(
                        context: context,
                        child: CommentsBottomSheet(reportId: report.id),
                      ),
                    ),
                    _ActionChip(
                      icon: Icons.share_outlined,
                      label: 'Partager',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Partage: ${report.city ?? "Québec"}',
                            ),
                          ),
                        );
                      },
                    ),
                    _ActionChip(
                      icon: Icons.map_outlined,
                      label: 'Carte',
                      onTap: () {
                        if (report.duplicateGroupId != null) {
                          context.push('/pothole/${report.duplicateGroupId}');
                        } else {
                          context.go('/home/map');
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontSize: 12)),
      ),
    );
  }
}

final _userNameProvider = FutureProvider.family<String, String>((ref, uid) async {
  if (AppEnv.useMockBackend) return 'Citoyen CivicRoad';
  final profile = await ref.read(userServiceProvider).getById(uid);
  return profile?.fullName ?? 'Citoyen';
});
