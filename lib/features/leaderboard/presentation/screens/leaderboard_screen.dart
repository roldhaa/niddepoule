import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:niddepoule/core/widgets/civic_scaffold.dart';
import 'package:niddepoule/core/widgets/civic_app_bar.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  String _selectedFilter = 'Ville'; // 'Ville', 'Province', 'Canada', 'Tous'

  final List<Map<String, dynamic>> _mockLeaderboard = [
    {
      'rank': 4,
      'name': 'Oli G.',
      'xp': '9.1K XP',
      'avatar': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=150',
    },
    {
      'rank': 5,
      'name': 'Kevin R.',
      'xp': '7.2K XP',
      'avatar': 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?q=80&w=150',
    },
    {
      'rank': 6,
      'name': 'Julie B.',
      'xp': '6.8K XP',
      'avatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=150',
    },
    {
      'rank': 7,
      'name': 'Alex T.',
      'xp': '6.3K XP',
      'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=150',
    },
    {
      'rank': 8,
      'name': 'Simon P.',
      'xp': '5.7K XP',
      'avatar': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=150',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return CivicScaffold(
      backgroundColor: const Color(0xFF0B0C0F), // Premium dark theme matching details screen
      appBar: const CivicAppBar(
        title: 'Classement',
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        children: [
          const SizedBox(height: 12),

          // 1. Horizontal Scrollable Filter Pills
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFilterPill('Ville'),
              _buildFilterPill('Province'),
              _buildFilterPill('Canada'),
              _buildFilterPill('Tous'),
            ],
          ),
          const SizedBox(height: 28),

          // 2. Podium (Top 3)
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 2nd Place
              Expanded(
                child: _buildPodiumCard(
                  rank: 2,
                  name: 'Cassandra D.',
                  xp: '16.2K XP',
                  avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=150',
                  cardHeight: 140,
                ),
              ),
              const SizedBox(width: 12),
              // 1st Place (Center)
              Expanded(
                child: _buildPodiumCard(
                  rank: 1,
                  name: 'Marquize.7',
                  xp: '19.8K XP',
                  avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=150',
                  cardHeight: 175,
                ),
              ),
              const SizedBox(width: 12),
              // 3rd Place
              Expanded(
                child: _buildPodiumCard(
                  rank: 3,
                  name: 'Maxime L.',
                  xp: '12.4K XP',
                  avatarUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=150',
                  cardHeight: 135,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 3. Ranked List (4th to 8th)
          ..._mockLeaderboard.map((user) => _buildLeaderboardRow(user)),

          const SizedBox(height: 20),

          // 4. Weekly Challenge Card ("Défi hebdo")
          _buildWeeklyChallengeCard(),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildFilterPill(String title) {
    final isSelected = _selectedFilter == title;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedFilter = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFF15161E),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.05),
            width: 0.5,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white60,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 13,
            fontFamily: 'Outfit',
          ),
        ),
      ),
    );
  }

  Widget _buildPodiumCard({
    required int rank,
    required String name,
    required String xp,
    required String avatarUrl,
    required double cardHeight,
  }) {
    final isFirst = rank == 1;

    // Badge styling on top of the card
    Widget badge;
    if (isFirst) {
      badge = const Padding(
        padding: EdgeInsets.only(bottom: 6.0),
        child: Text(
          '👑',
          style: TextStyle(fontSize: 24),
        ),
      );
    } else {
      final badgeColor = rank == 2 ? const Color(0xFFB0B0B0) : const Color(0xFFCD7F32);
      badge = Container(
        width: 20,
        height: 20,
        margin: const EdgeInsets.only(bottom: 8.0),
        decoration: BoxDecoration(
          color: badgeColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: badgeColor.withValues(alpha: 0.3),
              blurRadius: 4,
            ),
          ],
        ),
        child: Center(
          child: Text(
            '$rank',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        badge,
        Container(
          height: cardHeight,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: isFirst
                ? const LinearGradient(
                    colors: [Color(0xFFFF9500), Color(0xFFFF5E00)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                : const LinearGradient(
                    colors: [Color(0xFF13151D), Color(0xFF0F1015)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isFirst
                  ? const Color(0xFFFFD700).withValues(alpha: 0.6)
                  : Colors.white.withValues(alpha: 0.05),
              width: isFirst ? 1.5 : 0.8,
            ),
            boxShadow: isFirst
                ? [
                    BoxShadow(
                      color: const Color(0xFFFF9500).withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isFirst ? Colors.white : const Color(0xFFFF9500).withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.network(
                    avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.white12,
                      child: const Icon(Icons.person, color: Colors.white30, size: 24),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Name
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                  fontFamily: 'Outfit',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 3),
              // XP
              Text(
                xp,
                style: TextStyle(
                  color: isFirst ? Colors.white.withValues(alpha: 0.9) : Colors.white60,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Outfit',
                ),
                textAlign: TextAlign.center,
              ),
              if (isFirst) ...[
                const SizedBox(height: 6),
                const Icon(
                  Icons.star_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardRow(Map<String, dynamic> user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF13151D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04), width: 0.5),
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 24,
            child: Text(
              '${user['rank']}',
              style: const TextStyle(
                color: Colors.white54,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                fontFamily: 'Outfit',
              ),
            ),
          ),
          // Avatar
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white12,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.network(
                user['avatar'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.person, color: Colors.white30, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name
          Expanded(
            child: Text(
              user['name'],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                fontFamily: 'Outfit',
              ),
            ),
          ),
          // XP
          Text(
            user['xp'],
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 13.5,
              fontFamily: 'Outfit',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChallengeCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF13151D),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFFF9500).withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF9500).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left side: Challenge info & progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Défi hebdo',
                  style: TextStyle(
                    color: Color(0xFFFF9500),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    fontFamily: 'Outfit',
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Signale 5 nids cette semaine',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontFamily: 'Outfit',
                  ),
                ),
                const SizedBox(height: 16),
                // Progress Bar
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: const SizedBox(
                          height: 8,
                          child: LinearProgressIndicator(
                            value: 3 / 5,
                            backgroundColor: Colors.white10,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFFF9500),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      '3/5',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Right side: Gift circle
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.4),
                  border: Border.all(
                    color: const Color(0xFFFF9500).withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: const Center(
                  child: Text(
                    '🎁',
                    style: TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                '+200 XP',
                style: TextStyle(
                  color: Color(0xFFFF9500),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  fontFamily: 'Outfit',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
