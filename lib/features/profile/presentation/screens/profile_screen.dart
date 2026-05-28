import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:niddepoule/app/design_system/app_colors.dart';
import 'package:niddepoule/app/design_system/app_radius.dart';
import 'package:niddepoule/app/design_system/app_spacing.dart';
import 'package:niddepoule/core/utils/danger_colors.dart';
import 'package:niddepoule/core/utils/date_formatter.dart';
import 'package:niddepoule/core/widgets/civic_avatar.dart';
import 'package:niddepoule/core/widgets/civic_badge.dart';
import 'package:niddepoule/core/widgets/civic_card.dart';
import 'package:niddepoule/core/widgets/civic_empty_state.dart';
import 'package:niddepoule/core/widgets/civic_scaffold.dart';
import 'package:niddepoule/core/widgets/civic_section_title.dart';
import 'package:niddepoule/features/auth/presentation/providers/auth_providers.dart';
import 'package:niddepoule/features/feed/presentation/providers/feed_providers.dart';
import 'package:niddepoule/features/gamification/domain/badge_definitions.dart';
import 'package:niddepoule/features/profile/presentation/providers/profile_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProfileProvider);
    final feed = ref.watch(feedReportsProvider);

    if (user == null) {
      return const CivicScaffold(
        body: CivicEmptyState(
          title: 'Connectez-vous',
          subtitle: 'Accédez à votre profil et vos badges.',
          icon: Icons.person_outline,
        ),
      );
    }

    final myReports = feed.valueOrNull
            ?.where((r) => r.userId == user.uid)
            .take(10)
            .toList() ??
        [];

    final badges = user.badges.isEmpty
        ? BadgeDefinitions.badgesForReportsCount(user.reportsCount)
        : user.badges;

    final xpProgress = (user.xp % 100) / 100;

    return CivicScaffold(
      title: 'Profil',
      actions: [
        IconButton(
          onPressed: () => context.push('/profile/edit'),
          icon: const Icon(Icons.edit_outlined),
        ),
        IconButton(
          onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          icon: const Icon(Icons.logout),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              gradient: AppColors.profileHeroGradient,
              borderRadius: AppRadius.lgAll,
            ),
            child: Column(
              children: [
                CivicAvatar(
                  photoUrl: user.photoUrl,
                  name: user.fullName,
                  radius: 40,
                  showRing: true,
                ),
                AppSpacing.vMd,
                Text(
                  user.fullName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.textOnDark,
                      ),
                ),
                Text(
                  user.email,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textOnDarkMuted,
                      ),
                ),
                AppSpacing.vSm,
                Text(
                  user.bio.isEmpty ? 'Bio à compléter' : user.bio,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textOnDark.withValues(alpha: 0.85),
                      ),
                ),
              ],
            ),
          ),
          AppSpacing.vLg,
          Row(
            children: [
              Expanded(
                child: _StatCard(label: 'XP', value: '${user.xp}'),
              ),
              AppSpacing.gapH(AppSpacing.sm),
              Expanded(
                child: _StatCard(
                  label: 'Signalements',
                  value: '${user.reportsCount}',
                ),
              ),
              AppSpacing.gapH(AppSpacing.sm),
              Expanded(
                child: _StatCard(
                  label: 'Rang',
                  value: '#${(500 - user.xp).clamp(1, 500)}',
                ),
              ),
            ],
          ),
          AppSpacing.vLg,
          CivicCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progression XP',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                AppSpacing.vSm,
                ClipRRect(
                  borderRadius: AppRadius.smAll,
                  child: LinearProgressIndicator(
                    value: xpProgress.clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: AppColors.surfaceSection,
                    color: AppColors.brandYellow,
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.vLg,
          const CivicSectionTitle(title: 'Badges'),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.sm,
              mainAxisSpacing: AppSpacing.sm,
              childAspectRatio: 2.2,
            ),
            itemCount: badges.isEmpty ? 1 : badges.length,
            itemBuilder: (context, index) {
              if (badges.isEmpty) {
                return const CivicBadge(
                  label: 'Aucun badge',
                  icon: Icons.military_tech_outlined,
                );
              }
              return CivicBadge(
                label: badges[index],
                icon: Icons.military_tech,
                highlight: index == 0,
              );
            },
          ),
          AppSpacing.vLg,
          CivicSectionTitle(title: 'Mes signalements (${myReports.length})'),
          ...myReports.map(
            (r) => CivicCard(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.md),
              onTap: r.duplicateGroupId != null
                  ? () => context.push('/pothole/${r.duplicateGroupId}')
                  : null,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.description ?? 'Sans description',
                          style: Theme.of(context).textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${DangerColors.label(r.dangerLevel)} · '
                          '${DateFormatter.shortDate(r.createdAt)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return CivicCard(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
