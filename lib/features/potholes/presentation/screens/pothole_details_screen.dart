import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mb;
import 'package:niddepoule/app/design_system/app_colors.dart';
import 'package:niddepoule/app/design_system/app_spacing.dart';
import 'package:niddepoule/core/config/app_env.dart';
import 'package:niddepoule/core/utils/date_formatter.dart';
import 'package:niddepoule/core/widgets/civic_button.dart';
import 'package:niddepoule/core/widgets/civic_card.dart';
import 'package:niddepoule/core/widgets/civic_empty_state.dart';
import 'package:niddepoule/core/widgets/civic_loader.dart';
import 'package:niddepoule/core/widgets/civic_scaffold.dart';
import 'package:niddepoule/core/utils/danger_colors.dart';
import 'package:niddepoule/features/potholes/presentation/providers/pothole_providers.dart';
import 'package:niddepoule/features/reports/data/models/report.dart';

class PotholeDetailsScreen extends ConsumerStatefulWidget {
  const PotholeDetailsScreen({super.key, required this.potholeId});

  final String potholeId;

  @override
  ConsumerState<PotholeDetailsScreen> createState() => _PotholeDetailsScreenState();
}

class _PotholeDetailsScreenState extends ConsumerState<PotholeDetailsScreen> {
  String _selectedTab = 'aperçu'; // 'aperçu', 'signalements', 'photos', 'impact'

  String _formatFrenchDate(DateTime date) {
    final List<String> months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatFrenchTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    final String timeStr = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    
    if (difference == 0 && now.day == date.day) {
      return "Aujourd'hui, $timeStr";
    } else if (difference == 1 || (now.day - date.day == 1)) {
      return "Hier, $timeStr";
    }
    return '${_formatFrenchDate(date)}, $timeStr';
  }

  String _formatStreet(String? rawStreet) {
    if (rawStreet == null || rawStreet.trim().isEmpty) {
      return 'Rue Dalphond';
    }
    final clean = rawStreet.trim();
    return clean.split(' ').map((word) {
      if (word.isEmpty) return '';
      if (word.contains('-')) {
        return word.split('-').map((subWord) {
          if (subWord.isEmpty) return '';
          return subWord[0].toUpperCase() + subWord.substring(1).toLowerCase();
        }).join('-');
      }
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final potholeAsync = ref.watch(potholeByIdProvider(widget.potholeId));
    final reportsAsync = ref.watch(potholeReportsProvider(widget.potholeId));

    return CivicScaffold(
      // Keep AppBar title empty and handle custom overlay header
      body: potholeAsync.when(
        data: (pothole) {
          if (pothole == null) {
            return const CivicEmptyState(
              title: 'Nid-de-poule introuvable',
              icon: Icons.error_outline,
            );
          }

          final streetName = _formatStreet(pothole.street);
          final dangerLabel = switch (pothole.dangerLevel) {
            DangerLevel.high => 'Danger élevé',
            DangerLevel.medium => 'Danger moyen',
            DangerLevel.low => 'Danger faible',
          };
          final dangerColor = switch (pothole.dangerLevel) {
            DangerLevel.high => const Color(0xFFFF3B30),
            DangerLevel.medium => const Color(0xFFFF9500),
            DangerLevel.low => const Color(0xFF34C759),
          };

          // Primary images list
          final List<String> potholeImages = pothole.photoUrls.isNotEmpty 
              ? pothole.photoUrls 
              : [
                  'https://images.unsplash.com/photo-1619537901462-a6292f2e41fc?q=80&w=300',
                  'https://images.unsplash.com/photo-1596489370830-dfa053c9f2be?q=80&w=300',
                  'https://images.unsplash.com/photo-1621293954908-907141448d37?q=80&w=300',
                  'https://images.unsplash.com/photo-1584467541268-b029fb34de4e?q=80&w=300',
                ];

          return Column(
            children: [
              // 1. Perspective Map Header Section
              Stack(
                children: [
                  SizedBox(
                    height: 250,
                    child: _MiniMap(
                      latitude: pothole.latitude,
                      longitude: pothole.longitude,
                    ),
                  ),
                  // Gradient shadow at the bottom of the map
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColors.brandBlack.withValues(alpha: 0.8),
                            AppColors.brandBlack,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Back button (left overlay)
                  Positioned(
                    top: 50,
                    left: 16,
                    child: _buildHeaderCircleButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => context.pop(),
                    ),
                  ),
                  // Share & Options buttons (right overlay)
                  Positioned(
                    top: 50,
                    right: 16,
                    child: Row(
                      children: [
                        _buildHeaderCircleButton(
                          icon: Icons.share_rounded,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Lien partagé avec succès !')),
                            );
                          },
                        ),
                        const SizedBox(width: 10),
                        _buildHeaderCircleButton(
                          icon: Icons.more_horiz_rounded,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // 2. Main Details Section
              Expanded(
                child: Container(
                  color: AppColors.brandBlack,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    physics: const ClampingScrollPhysics(),
                    children: [
                      // Pothole Title, Location & Avatar
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  streetName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.alt_route_rounded,
                                      color: Color(0xFF34C759),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${pothole.city ?? "Shawinigan"}, QC',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Gold bordered avatar thumbnail of the pothole
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFFF9500), width: 2),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(32),
                              child: Image.network(
                                potholeImages.first,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(color: Colors.white.withValues(alpha: 0.05));
                                },
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  child: const Icon(Icons.image_outlined, color: Colors.white30, size: 24),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Badges: Danger Level & Score Badge
                      Row(
                        children: [
                          // Danger level tag
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: dangerColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: dangerColor.withValues(alpha: 0.4), width: 1.2),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.warning_amber_rounded, color: dangerColor, size: 14),
                                const SizedBox(width: 6),
                                Text(
                                  dangerLabel,
                                  style: TextStyle(
                                    color: dangerColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Danger score out of 10 badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F1015),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1),
                            ),
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: pothole.dangerScore.toStringAsFixed(1),
                                    style: TextStyle(
                                      color: dangerColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: '/10',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // 3. custom Tab bar row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildTabButton('Aperçu', 'aperçu'),
                          _buildTabButton('Signalements (${pothole.reportCount})', 'signalements'),
                          _buildTabButton('Photos', 'photos'),
                          _buildTabButton('Impact', 'impact'),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Tab Contents
                      if (_selectedTab == 'aperçu') ...[
                        // Stat Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F1015),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                          ),
                          child: Column(
                            children: [
                              _buildStatRow(
                                label: 'Premier signalement',
                                value: _formatFrenchDate(pothole.firstReportedAt),
                              ),
                              const Divider(color: Colors.white12, height: 24),
                              _buildStatRow(
                                label: 'Dernier signalement',
                                value: _formatFrenchTime(pothole.lastReportedAt),
                              ),
                              const Divider(color: Colors.white12, height: 24),
                              _buildStatRow(
                                label: 'Statut',
                                widgetValue: Row(
                                  children: [
                                    Icon(
                                      pothole.status == 'repaired'
                                          ? Icons.check_circle_rounded
                                          : Icons.error_rounded,
                                      color: pothole.status == 'repaired'
                                          ? const Color(0xFF34C759)
                                          : const Color(0xFFFF3B30),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      pothole.status == 'repaired' ? 'Réparé' : 'Non réparé',
                                      style: TextStyle(
                                        color: pothole.status == 'repaired'
                                            ? const Color(0xFF34C759)
                                            : const Color(0xFFFF3B30),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Section 2: Photos récentes
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Photos récentes',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedTab = 'photos';
                                });
                              },
                              child: const Row(
                                children: [
                                  Text(
                                    'Voir tout',
                                    style: TextStyle(
                                      color: Color(0xFF007AFF),
                                      fontSize: 13,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    color: Color(0xFF007AFF),
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Horiz photos list
                        SizedBox(
                          height: 76,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: potholeImages.length,
                            itemBuilder: (context, idx) {
                              return Container(
                                width: 105,
                                margin: const EdgeInsets.only(right: 8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    potholeImages[idx],
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(color: Colors.white.withValues(alpha: 0.05));
                                    },
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      color: Colors.white.withValues(alpha: 0.05),
                                      child: const Icon(Icons.image_outlined, color: Colors.white30, size: 20),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Section 3: Activité des utilisateurs
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Activité des utilisateurs',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(
                              Icons.close_rounded,
                              color: Colors.white30,
                              size: 18,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // User activity comment tile
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F1015),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  // Mock Avatar
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white12,
                                    ),
                                    child: const Icon(Icons.person_rounded, color: Colors.white54, size: 20),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Marquize.7',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          '${pothole.city ?? "Shawinigan"}, QC',
                                          style: const TextStyle(
                                            color: Colors.white54,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    _formatFrenchTime(pothole.lastReportedAt),
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Encore pire ce matin... prudence tout le monde!',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.favorite_rounded, color: Color(0xFFFF3B30), size: 16),
                                  const SizedBox(width: 4),
                                  const Text('54', style: TextStyle(color: Colors.white54, fontSize: 12)),
                                  const SizedBox(width: 16),
                                  const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white54, size: 16),
                                  const SizedBox(width: 4),
                                  const Text('12', style: TextStyle(color: Colors.white54, fontSize: 12)),
                                  const SizedBox(width: 16),
                                  const Icon(Icons.trending_up_rounded, color: Colors.white54, size: 16),
                                  const Spacer(),
                                  const Icon(Icons.ios_share_rounded, color: Colors.white54, size: 16),
                                  const SizedBox(width: 16),
                                  const Icon(Icons.bookmark_border_rounded, color: Colors.white54, size: 16),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ] else if (_selectedTab == 'signalements') ...[
                        // Signalements complete list
                        reportsAsync.when(
                          data: (reports) {
                            if (reports.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.all(24.0),
                                child: Center(
                                  child: Text(
                                    'Aucun signalement lié.',
                                    style: TextStyle(color: Colors.white54),
                                  ),
                                ),
                              );
                            }
                            return Column(
                              children: reports.map((r) {
                                return CivicCard(
                                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(r.description ?? 'Sans description', style: const TextStyle(color: Colors.white)),
                                    subtitle: Text(
                                      '${DangerColors.label(r.dangerLevel)} · '
                                      '${DateFormatter.shortDate(r.createdAt)}',
                                      style: const TextStyle(color: Colors.white54),
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                          loading: () => const CivicLoader(),
                          error: (e, _) => Text('Erreur: $e', style: const TextStyle(color: Colors.red)),
                        ),
                        const SizedBox(height: 24),
                      ] else if (_selectedTab == 'photos') ...[
                        // Photos complete Grid
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: potholeImages.length,
                          itemBuilder: (context, idx) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                potholeImages[idx],
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(color: Colors.white.withValues(alpha: 0.05));
                                },
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  child: const Icon(Icons.image_outlined, color: Colors.white30),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                      ] else if (_selectedTab == 'impact') ...[
                        // Impact info
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F1015),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Dossier d\'indemnisation',
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Le Québec permet d\'obtenir des dédommagements sous certaines conditions si votre véhicule a été endommagé.',
                                style: TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                              const SizedBox(height: 16),
                              CivicButton(
                                label: 'Créer un dossier de preuve',
                                icon: Icons.folder_open_outlined,
                                onPressed: () => context.push('/pothole/${widget.potholeId}/proof'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
                ),
              ),

              // 3. Sticky Action Buttons at bottom
              Container(
                padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.paddingOf(context).bottom + 12),
                decoration: const BoxDecoration(
                  color: Color(0xFF0D0E12),
                  border: Border(top: BorderSide(color: Colors.white12, width: 0.5)),
                ),
                child: Row(
                  children: [
                    // Avoid Route Button
                    Expanded(
                      flex: 11,
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Calcul de l\'itinéraire de contournement...'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1.2),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.near_me_outlined, color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Itinéraire évitant',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Report Button
                    Expanded(
                      flex: 12,
                      child: InkWell(
                        onTap: () => context.push(
                          '/report?potholeId=${widget.potholeId}&redirect=/pothole/${widget.potholeId}',
                        ),
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF4F18), // Vibrant orange-red
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Signaler ici',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CivicLoader()),
        error: (e, _) => Center(child: Text('$e', style: const TextStyle(color: Colors.red))),
      ),
    );
  }

  Widget _buildHeaderCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _buildTabButton(String title, String tabId) {
    final isSelected = _selectedTab == tabId;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedTab = tabId;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white54,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 32,
            height: 2.5,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFF3B30) : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required String label,
    String? value,
    Widget? widgetValue,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 14,
          ),
        ),
        if (value != null)
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          )
        else
          ?widgetValue,
      ],
    );
  }
}

// Map Component
class _MiniMap extends StatefulWidget {
  const _MiniMap({required this.latitude, required this.longitude});
  final double latitude;
  final double longitude;

  @override
  State<_MiniMap> createState() => _MiniMapState();
}

class _MiniMapState extends State<_MiniMap> {
  mb.MapboxMap? _mapboxMap;
  mb.PointAnnotationManager? _annotationManager;
  Uint8List? _markerImage;

  @override
  void initState() {
    super.initState();
    _initMarker();
  }

  Future<void> _initMarker() async {
    _markerImage = await _createMarkerImage(color: const Color(0xFFFF3B30), size: 50);
    if (mounted) setState(() {});
  }

  Future<Uint8List> _createMarkerImage({required Color color, required double size}) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final double r = size / 2;
    final Paint glowPaint = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(Offset(r, r), r * 0.95, glowPaint);
    final Paint borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(r, r), r * 0.5, borderPaint);
    final Paint mainPaint = Paint()..color = color;
    canvas.drawCircle(Offset(r, r), r * 0.45, mainPaint);
    final Paint innerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(r, r), r * 0.18, innerPaint);
    final ui.Image image = await pictureRecorder.endRecording().toImage(size.toInt(), size.toInt());
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  void _onMapCreated(mb.MapboxMap controller) async {
    _mapboxMap = controller;
    controller.setCamera(mb.CameraOptions(
      center: mb.Point(coordinates: mb.Position(widget.longitude, widget.latitude)),
      zoom: 15.0,
      pitch: 45.0, // Perspective 3D
    ));
    _annotationManager = await controller.annotations.createPointAnnotationManager();
    _updateMarker();
  }

  void _updateMarker() async {
    final manager = _annotationManager;
    if (manager == null || _markerImage == null) return;
    await manager.deleteAll();
    await manager.create(mb.PointAnnotationOptions(
      geometry: mb.Point(coordinates: mb.Position(widget.longitude, widget.latitude)),
      image: _markerImage,
      iconSize: 1.0,
    ));
  }

  @override
  void didUpdateWidget(covariant _MiniMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.latitude != widget.latitude || oldWidget.longitude != widget.longitude) {
      _mapboxMap?.setCamera(mb.CameraOptions(
        center: mb.Point(coordinates: mb.Position(widget.longitude, widget.latitude)),
        zoom: 15.0,
      ));
      _updateMarker();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (AppEnv.mapboxAccessToken.isNotEmpty) {
      return mb.MapWidget(
        key: ValueKey('minimap_${widget.latitude}_${widget.longitude}'),
        onMapCreated: _onMapCreated,
        styleUri: 'mapbox://styles/mapbox/dark-v11',
      );
    }
    // Mock map fallback when token is empty
    return Container(
      color: const Color(0xFF0F111A),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _GridPainter(),
            ),
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.redAccent.withValues(alpha: 0.15),
            ),
            child: Center(
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.redAccent.withValues(alpha: 0.3),
                ),
                child: Center(
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1.0;
    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
