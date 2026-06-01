import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:niddepoule/app/design_system/app_colors.dart';
import 'package:niddepoule/app/design_system/app_spacing.dart';
import 'package:niddepoule/app/design_system/app_radius.dart';
import 'package:niddepoule/core/widgets/civic_scaffold.dart';
import 'package:niddepoule/core/widgets/civic_button.dart';
import 'package:niddepoule/core/widgets/civic_bottom_sheet.dart';
import 'package:niddepoule/core/providers/core_providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // Navigation inside profile tab: 'profile', 'achievements', 'leaderboard', 'claim'
  String _currentSubView = 'profile';

  // State for Claim Wizard
  int _claimStep = 1; // 1: Select parts, 2: Estimation & evidence checklist, 3: Success PDF
  final Set<String> _damagedParts = {};
  double _damageEstimateMin = 580;
  double _damageEstimateMax = 1250;
  int _selectedCategoryIndex = 0;

  // State for Open Data Ingestion
  double _openDataImportLimit = 150.0;
  bool _openDataImporting = false;
  int? _openDataImportedCount;

  @override
  Widget build(BuildContext context) {
    if (_currentSubView == 'achievements') {
      return _buildAchievementsView();
    } else if (_currentSubView == 'leaderboard') {
      return _buildLeaderboardView();
    } else if (_currentSubView == 'claim') {
      return _buildClaimWizardView();
    } else if (_currentSubView == 'open_data') {
      return _buildOpenDataView();
    }

    return CivicScaffold(
      backgroundColor: AppColors.brandBlack, // Premium dynamic dark/light background
      extendBody: true,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // 1. Orange Header Background (Discord-style)
            Container(
              height: 160,
              width: double.infinity,
              color: const Color(0xFFFAA61A), // Discord Yellow/Orange
            ),

            // 2. Top Right Buttons (Compass, Shop, Nitro, Settings)
            Positioned(
              top: 50,
              right: 16,
              child: Row(
                children: [
                  _buildHeaderIconButton(
                    Icons.explore,
                    onTap: () => setState(() => _currentSubView = 'leaderboard'),
                  ),
                  const SizedBox(width: 8),
                  _buildHeaderIconButton(
                    Icons.storefront_rounded,
                    onTap: () {},
                  ),
                  const SizedBox(width: 8),
                  // Nitro Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.rocket_launch_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Nitro',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildHeaderIconButton(
                    Icons.settings_rounded,
                    onTap: () {
                      showCivicBottomSheet(
                        context: context,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Outils & Paramètres',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                fontFamily: 'Outfit',
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ListTile(
                              leading: const Icon(Icons.picture_as_pdf_outlined, color: AppColors.brandOrange),
                              title: const Text(
                                'Dossier de sinistre (311)',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              subtitle: const Text(
                                'Générer un PDF de réclamation pré-rempli pour la ville.',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                setState(() {
                                  _currentSubView = 'claim';
                                  _claimStep = 1;
                                  _damagedParts.clear();
                                });
                              },
                            ),
                            const Divider(color: Colors.white10),
                            ListTile(
                              leading: const Icon(Icons.cloud_download_outlined, color: Colors.green),
                              title: const Text(
                                'Données Ouvertes (Open Data)',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              subtitle: const Text(
                                'Pré-remplir la carte avec des nids-de-poule réels de Montréal.',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                setState(() {
                                  _currentSubView = 'open_data';
                                  _openDataImportLimit = 150.0;
                                  _openDataImporting = false;
                                  _openDataImportedCount = null;
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // 3. Scrollable Content Column
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 90), // Push the avatar/status section to overlap the header
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.brandBlack, // Same background color as the app
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      // Avatar & Custom Status Row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Avatar with status indicator
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              color: AppColors.brandBlack, // Black border frame matching page background
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(4), // Thickness of the black frame
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Color(0xFFFAA61A),
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(18),
                              child: Image.network(
                                'https://assets-global.website-files.com/6257adef93867e50d84d30e2/636e0a6a49cf127bf92de1e2_icon_clyde_blurple_RGB.png', // Discord logo
                                color: Colors.white,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.discord_rounded,
                                    color: Colors.white,
                                    size: 44,
                                  );
                                },
                              ),
                            ),
                          ),
                          // Discord status dot (Idle moon shape)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: AppColors.brandBlack,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFAA61A), // Status color (orange/yellow)
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.mode_night_rounded,
                                  color: AppColors.brandBlack,
                                  size: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      // Custom Status bubble
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(width: 8),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: AppColors.brandBlackSoft,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: AppColors.brandBlackSoft,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: AppColors.brandBlackSoft, // Lighter background bubble
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.add_circle_rounded,
                                        color: AppColors.textPrimary.withValues(alpha: 0.6),
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          "Qu'est-ce que tu as regardé récemment ?",
                                          style: TextStyle(
                                            color: AppColors.textPrimary.withValues(alpha: 0.8),
                                            fontSize: 12,
                                            fontStyle: FontStyle.italic,
                                            fontFamily: 'Outfit',
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Profile info and Stats row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Left side: Name & Tag
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Spryto',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                  fontFamily: 'Outfit',
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: AppColors.textSecondary,
                                size: 20,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.brandBlackSoft,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'eyeg0d',
                                  style: TextStyle(
                                    color: AppColors.textPrimary.withValues(alpha: 0.8),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Outfit',
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF23A55A), // Green indicator
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.tag_rounded,
                                    color: Colors.white,
                                    size: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      // Right side: Stats Card (Discord-style dark card)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.brandBlackSoft,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border.withValues(alpha: 0.1)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildQuickStat('🔥', '478', 'Signalements'),
                            const SizedBox(width: 16),
                            _buildQuickStat('⭐', '12.4K', 'XP'),
                            const SizedBox(width: 16),
                            _buildQuickStat('🏆', '24', 'Badges'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Niveau indicator card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildNiveauCard(),
                ),

                const SizedBox(height: 12),

                // Action Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brandBlackSoft,
                            foregroundColor: AppColors.textPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {},
                          child: const Text(
                            'Modifier le profil',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              fontFamily: 'Outfit',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brandBlackSoft,
                            foregroundColor: AppColors.textPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {},
                          child: const Text(
                            'Partager le profil',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              fontFamily: 'Outfit',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Category selector tabs with divider lines
                const Divider(color: Colors.white10, height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCategoryTab(0, Icons.home_outlined, Icons.home_rounded),
                    _buildCategoryTab(1, Icons.favorite_border_rounded, Icons.favorite_rounded),
                    _buildCategoryTab(2, Icons.construction_outlined, Icons.construction_rounded),
                    _buildCategoryTab(3, Icons.add_box_outlined, Icons.add_box_rounded),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: Colors.white10, height: 1),

                const SizedBox(height: 20),

                // Category Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildSelectedCategoryContent(),
                ),

                const SizedBox(height: 100), // Bottom navigation padding
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderIconButton(IconData icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildNiveauCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.brandBlackSoft, // Lighter card background
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Circular progress indicator around star
          Stack(
            alignment: Alignment.center,
            children: [
              const SizedBox(
                width: 38,
                height: 38,
                child: CircularProgressIndicator(
                  value: 12480 / 15000,
                  strokeWidth: 2.5,
                  backgroundColor: Colors.white10,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF8C00)),
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF4500),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Niveau 12',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    Text(
                      '12 480 / 15 000 XP',
                      style: TextStyle(
                        color: AppColors.textPrimary.withValues(alpha: 0.5),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: 12480 / 15000,
                        minHeight: 6,
                        backgroundColor: AppColors.brandBlack, // Dark progress track
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF4500)),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: 12480 / 15000,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Transform.translate(
                          offset: const Offset(4, 0),
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF2D55),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFFFF2D55),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                )
                              ],
                            ),
                            child: Center(
                              child: Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
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

  Widget _buildQuickStat(String icon, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 15,
                fontFamily: 'Outfit',
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 9,
            fontWeight: FontWeight.w500,
            fontFamily: 'Outfit',
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryTab(int index, IconData outlineIcon, IconData solidIcon) {
    final isSelected = _selectedCategoryIndex == index;
    final color = isSelected ? AppColors.textPrimary : AppColors.textSecondary;
    final icon = isSelected ? solidIcon : outlineIcon;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategoryIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Container(
            width: 24,
            height: 3,
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedCategoryContent() {
    switch (_selectedCategoryIndex) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mes derniers signalements',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'Outfit',
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: const Text(
                    'Voir tout',
                    style: TextStyle(
                      color: Color(0xFFFF9500),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      fontFamily: 'Outfit',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _buildReportCard(
              street: 'Rue Dalphond',
              status: 'Élevé',
              statusColor: const Color(0xFFFF2D55),
              time: '2 h',
              mapImageUrl: 'https://images.unsplash.com/photo-1524661135-423995f22d0b?q=80&w=150',
              potholeImageUrl: 'https://images.unsplash.com/photo-1515162305285-0293e4767cc2?q=80&w=150',
            ),
            const SizedBox(height: 10),
            _buildReportCard(
              street: 'Rue Des Érables',
              status: 'Moyen',
              statusColor: const Color(0xFFFF9500),
              time: '5 h',
              mapImageUrl: 'https://images.unsplash.com/photo-1524661135-423995f22d0b?q=80&w=150',
              potholeImageUrl: 'https://images.unsplash.com/photo-1618083707368-b3823daa2726?q=80&w=150',
            ),
            const SizedBox(height: 10),
            _buildReportCard(
              street: 'Boul. des Forges',
              status: 'Faible',
              statusColor: const Color(0xFF34C759),
              time: '1 j',
              mapImageUrl: 'https://images.unsplash.com/photo-1524661135-423995f22d0b?q=80&w=150',
              potholeImageUrl: 'https://images.unsplash.com/photo-1584467541268-b040f83be3fd?q=80&w=150',
            ),
            const SizedBox(height: 20),
          ],
        );
      case 1:
        return _buildEmptyStateTab(
          icon: Icons.favorite_border_rounded,
          title: 'Aucun favori pour le moment',
          subtitle: 'Enregistrez les rues que vous empruntez souvent pour suivre leur état.',
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Réparations suivies',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                fontFamily: 'Outfit',
              ),
            ),
            const SizedBox(height: 14),
            _buildRepairCard(
              street: 'Autoroute 55 Nord',
              status: 'En cours',
              statusColor: const Color(0xFFFF9500),
              date: 'Prévu le 3 juin',
            ),
            const SizedBox(height: 10),
            _buildRepairCard(
              street: 'Rue Saint-Maurice',
              status: 'Terminé',
              statusColor: const Color(0xFF34C759),
              date: 'Réparé hier',
            ),
            const SizedBox(height: 20),
          ],
        );
      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activité récente',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                fontFamily: 'Outfit',
              ),
            ),
            const SizedBox(height: 14),
            _buildActivityItem('Signalement validé par l\'administration • 2h', 'Rue Dalphond'),
            _buildActivityItem('Vous avez gagné 200 XP • 5h', 'Signalement Rue Des Érables'),
            _buildActivityItem('Nouveau badge débloqué : Chasseur • 1j', 'Niveau 12 atteint'),
            const SizedBox(height: 20),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildReportCard({
    required String street,
    required String status,
    required Color statusColor,
    required String time,
    required String mapImageUrl,
    required String potholeImageUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.brandBlackSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(mapImageUrl),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withValues(alpha: 0.3),
                  BlendMode.darken,
                ),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: statusColor,
                        blurRadius: 4,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  street,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    fontFamily: 'Outfit',
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '•',
                      style: TextStyle(color: Colors.white30, fontSize: 12),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      time,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 80,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(potholeImageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepairCard({
    required String street,
    required String status,
    required Color statusColor,
    required String date,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.brandBlackSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.construction_rounded, color: statusColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  street,
                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Outfit'),
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontFamily: 'Outfit'),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status,
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11, fontFamily: 'Outfit'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String meta, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.brandBlackSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.history_rounded, color: AppColors.textSecondary.withValues(alpha: 0.8), size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Outfit'),
                ),
                const SizedBox(height: 2),
                Text(
                  meta,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontFamily: 'Outfit'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateTab({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
      child: Column(
        children: [
          Icon(icon, color: AppColors.textSecondary.withValues(alpha: 0.5), size: 48),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(color: AppColors.textPrimary.withValues(alpha: 0.7), fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Outfit'),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontFamily: 'Outfit'),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 1. ACHIEVEMENTS VIEW
  Widget _buildAchievementsView() {
    return CivicScaffold(
      title: 'Héros de la route',
      leading: IconButton(
        onPressed: () => setState(() => _currentSubView = 'profile'),
        icon: const Icon(Icons.arrow_back),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.lgAll,
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Niveau 18', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text('18 450 / 25 000 XP', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: 18450 / 25000,
                    minHeight: 8,
                    backgroundColor: AppColors.brandBlackSoft,
                    color: AppColors.brandOrange,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildAchievementCard('Chasseur de nids', 'Signaler 100 nids-de-poule', '100 / 100', Colors.amber, Icons.emoji_events),
          _buildAchievementCard('Protecteur urbain', 'Aider à éviter 1 000 accidents', '780 / 1 000', Colors.grey, Icons.shield),
          _buildAchievementCard('Vision IA', '10 photos validées par l\'IA', '10 / 10', Colors.orange, Icons.psychology),
          _buildAchievementCard('Roi de Shawinigan', 'Top 1 de la ville cette semaine', 'Débloqué', Colors.amberAccent, Icons.workspace_premium),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(String title, String desc, String progress, Color color, IconData icon) {
    final isDone = progress == 'Débloqué' || progress.startsWith('100') || progress.startsWith('10');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: isDone ? color.withValues(alpha: 0.3) : AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 2),
                Text(desc, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Text(
            progress,
            style: TextStyle(
              color: isDone ? Colors.green : AppColors.textSecondary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          )
        ],
      ),
    );
  }

  // 2. LEADERBOARD VIEW
  Widget _buildLeaderboardView() {
    return CivicScaffold(
      title: 'Classement',
      leading: IconButton(
        onPressed: () => setState(() => _currentSubView = 'profile'),
        icon: const Icon(Icons.arrow_back),
      ),
      body: Column(
        children: [
          // Filter Row
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _buildLeaderboardTab('Ville', false),
                _buildLeaderboardTab('Québec', true),
                _buildLeaderboardTab('Canada', false),
                _buildLeaderboardTab('Monde', false),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildLeaderboardRow(1, 'Marquize.7', '3 245 XP', true, 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=100'),
                _buildLeaderboardRow(2, 'Alex D.', '2 760 XP', false, 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?q=80&w=100'),
                _buildLeaderboardRow(3, 'Julie M.', '2 145 XP', false, 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=100'),
                _buildLeaderboardRow(4, 'Étienne P.', '1 980 XP', false, 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=100'),
                _buildLeaderboardRow(5, 'Simon L.', '1 675 XP', false, 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=100'),
                _buildLeaderboardRow(6, 'Karine R.', '1 520 XP', false, 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=100'),
              ],
            ),
          ),

          // User sticky footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0xFF1D150B),
              border: Border(top: BorderSide(color: AppColors.brandOrange, width: 1.5)),
            ),
            child: Row(
              children: [
                const Text(
                  '18',
                  style: TextStyle(color: AppColors.brandOrange, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(width: 16),
                const CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=100'),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Moi (Alexandre B.)',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  '850 XP',
                  style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right, color: AppColors.brandOrange)
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTab(String text, bool active) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.brandBlackSoft : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: active ? Colors.white : AppColors.textSecondary,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardRow(int rank, String name, String xp, bool isFirst, String avatar) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isFirst ? const Color(0xFF1D150B) : AppColors.surface,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: isFirst ? AppColors.brandOrange.withValues(alpha: 0.3) : AppColors.border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '$rank',
              style: TextStyle(
                color: isFirst ? AppColors.brandOrange : Colors.white60,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(avatar),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            xp,
            style: TextStyle(
              color: isFirst ? AppColors.brandOrange : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // 3. CLAIM VEHICLE DAMAGE WIZARD
  Widget _buildClaimWizardView() {
    return CivicScaffold(
      title: 'Dommage à votre véhicule',
      leading: IconButton(
        onPressed: () {
          setState(() {
            _currentSubView = 'profile';
          });
        },
        icon: const Icon(Icons.arrow_back),
      ),
      body: _buildClaimStepContent(),
    );
  }

  Widget _buildClaimStepContent() {
    if (_claimStep == 3) {
      return _buildClaimSuccessView();
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // Steps Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildClaimIndicator(1, 'Dommages', _claimStep >= 1),
            _buildClaimLine(_claimStep >= 2),
            _buildClaimIndicator(2, 'Estimation', _claimStep >= 2),
          ],
        ),
        const SizedBox(height: 28),

        if (_claimStep == 1) ...[
          const Text(
            'Qu\'est-ce qui a été endommagé ?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildDamagePartButton('Pneu', Icons.tire_repair),
              _buildDamagePartButton('Jante', Icons.circle_outlined),
              _buildDamagePartButton('Suspension', Icons.build_outlined),
              _buildDamagePartButton('Autre', Icons.more_horiz),
            ],
          ),
          const SizedBox(height: 40),
          CivicButton(
            label: 'Suivant',
            onPressed: _damagedParts.isEmpty
                ? null
                : () {
                    setState(() {
                      _claimStep = 2;
                    });
                  },
          )
        ] else if (_claimStep == 2) ...[
          const Text(
            'Estimation des dommages',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            '${_damageEstimateMin.toInt()} \$ - ${_damageEstimateMax.toInt()} \$',
            style: TextStyle(color: AppColors.brandOrange, fontWeight: FontWeight.bold, fontSize: 28),
          ),
          SliderRange(
            values: RangeValues(_damageEstimateMin, _damageEstimateMax),
            onChanged: (values) {
              setState(() {
                _damageEstimateMin = values.start;
                _damageEstimateMax = values.end;
              });
            },
          ),
          const SizedBox(height: 24),

          // Automatic evidence lists
          const Text(
            'Preuves automatiquement ajoutées',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 12),
          _buildEvidenceCheckRow('Localisation exacte GPS'),
          _buildEvidenceCheckRow('Photos historiques du nid-de-poule'),
          _buildEvidenceCheckRow('15 signalements antérieurs de la communauté'),
          _buildEvidenceCheckRow('Niveau de danger : ÉLEVÉ'),
          const SizedBox(height: 40),

          CivicButton(
            label: 'Générer mon dossier (PDF)',
            icon: Icons.picture_as_pdf_outlined,
            onPressed: () {
              setState(() {
                _claimStep = 3;
              });
            },
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () {
                setState(() {
                  _claimStep = 1;
                });
              },
              child: const Text('Retour', style: TextStyle(color: Colors.white70)),
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildClaimIndicator(int step, String label, bool active) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: active ? AppColors.brandOrange : AppColors.brandBlackSoft,
            shape: BoxShape.circle,
            border: Border.all(color: active ? AppColors.brandOrange : AppColors.border),
          ),
          child: Center(
            child: Text(
              '$step',
              style: TextStyle(
                color: active ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : AppColors.textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildClaimLine(bool active) {
    return Container(
      width: 60,
      height: 2,
      margin: const EdgeInsets.only(bottom: 16, left: 8, right: 8),
      color: active ? AppColors.brandOrange : AppColors.border,
    );
  }

  Widget _buildDamagePartButton(String name, IconData icon) {
    final isSelected = _damagedParts.contains(name);
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (isSelected) {
              _damagedParts.remove(name);
            } else {
              _damagedParts.add(name);
            }
          });
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.brandOrange.withValues(alpha: 0.15) : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? AppColors.brandOrange : AppColors.border, width: 1.5),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? AppColors.brandOrange : AppColors.textSecondary, size: 28),
              const SizedBox(height: 8),
              Text(
                name,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEvidenceCheckRow(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 13.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClaimSuccessView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green, width: 2),
              ),
              child: const Icon(Icons.check, color: Colors.green, size: 40),
            ),
            const SizedBox(height: 24),
            const Text(
              'Dossier de sinistre généré !',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 12),
            const Text(
              'Votre dossier PDF contenant les photos géolocalisées et les signalements historiques de la ville de Shawinigan a été sauvegardé avec succès.',
              style: TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandOrange,
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 48),
              ),
              onPressed: () {
                setState(() {
                  _currentSubView = 'profile';
                });
              },
              child: const Text('Fermer', style: TextStyle(fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  // 4. OPEN DATA PORTAL VIEW
  Widget _buildOpenDataView() {
    return CivicScaffold(
      title: 'Données Ouvertes 311',
      leading: IconButton(
        onPressed: () {
          setState(() {
            _currentSubView = 'profile';
          });
        },
        icon: const Icon(Icons.arrow_back),
      ),
      body: _buildOpenDataContent(),
    );
  }

  Widget _buildOpenDataContent() {
    if (_openDataImportedCount != null) {
      return _buildOpenDataSuccessView();
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        const Text(
          'Pré-remplir la carte avec des données réelles',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            fontFamily: 'Outfit',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Aspirez les requêtes citoyennes 311 de nids-de-poule enregistrées en temps réel par les municipalités.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontFamily: 'Outfit',
          ),
        ),
        const SizedBox(height: 24),

        // Portal Info Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.brandBlackSoft,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.cloud_queue_rounded, color: Colors.green, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Source : Données Québec (Montréal)',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Jeu de données officiel : Requêtes 311 (2022 à ce jour)',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white10, height: 1),
              const SizedBox(height: 16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total disponible', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  Text(
                    '61 981 nids-de-poule',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Format de l\'API', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  Text(
                    'CKAN DataStore API',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Slider for count to import
        Text(
          'Nombre de nids-de-poule à importer : ${_openDataImportLimit.toInt()}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),
        Slider(
          value: _openDataImportLimit,
          min: 50,
          max: 1000,
          divisions: 19, // Division steps of 50
          activeColor: AppColors.brandOrange,
          inactiveColor: AppColors.brandBlackSoft,
          onChanged: _openDataImporting
              ? null
              : (value) {
                  setState(() {
                    _openDataImportLimit = value;
                  });
                },
        ),
        const SizedBox(height: 40),

        // Action Button
        _openDataImporting
            ? const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: AppColors.brandOrange),
                    SizedBox(height: 16),
                    Text(
                      'Connexion au portail de la ville et importation...',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              )
            : CivicButton(
                label: 'Lancer l\'importation (API)',
                icon: Icons.api_rounded,
                onPressed: () async {
                  setState(() {
                    _openDataImporting = true;
                  });
                  try {
                    final count = await ref
                        .read(openDataServiceProvider)
                        .ingestMontrealPotholes(_openDataImportLimit.toInt());
                    setState(() {
                      _openDataImportedCount = count;
                    });
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur d\'importation : $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } finally {
                    setState(() {
                      _openDataImporting = false;
                    });
                  }
                },
              ),
      ],
    );
  }

  Widget _buildOpenDataSuccessView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green, width: 2),
              ),
              child: const Icon(Icons.check, color: Colors.green, size: 40),
            ),
            const SizedBox(height: 24),
            const Text(
              'Importation réussie !',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '$_openDataImportedCount nids-de-poule réels de la Ville de Montréal ont été importés avec succès par API et enregistrés sur la carte.',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandOrange,
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 48),
              ),
              onPressed: () {
                setState(() {
                  _openDataImportedCount = null;
                  _currentSubView = 'profile';
                });
              },
              child: const Text('Fermer', style: TextStyle(fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}

// Custom Slider component with Range support
class SliderRange extends StatelessWidget {
  const SliderRange({
    super.key,
    required this.values,
    required this.onChanged,
  });

  final RangeValues values;
  final ValueChanged<RangeValues> onChanged;

  @override
  Widget build(BuildContext context) {
    return RangeSlider(
      values: values,
      min: 100,
      max: 5000,
      activeColor: AppColors.brandOrange,
      inactiveColor: AppColors.brandBlackSoft,
      onChanged: onChanged,
    );
  }
}

class TrianglePainter extends CustomPainter {
  final Color color;
  TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path();
    path.moveTo(size.width, 0);
    path.lineTo(0, size.height / 2);
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
