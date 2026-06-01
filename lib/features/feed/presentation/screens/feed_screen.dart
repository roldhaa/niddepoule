import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:niddepoule/app/design_system/app_colors.dart';
import 'package:niddepoule/app/design_system/app_spacing.dart';
import 'package:niddepoule/core/widgets/civic_scaffold.dart';
import 'package:niddepoule/core/widgets/civic_app_bar.dart';
import 'package:niddepoule/features/feed/presentation/widgets/civic_before_after_slider.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Interactive likes state
  final Map<int, bool> _likedPosts = {
    0: true, // Marquize.7 liked by default
    1: false,
    2: false,
  };
  final Map<int, int> _likesCount = {
    0: 214,
    1: 45,
    2: 12,
  };

  // Interactive bookmarks state
  final Map<int, bool> _bookmarkedPosts = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleLike(int postId) {
    setState(() {
      final isLiked = _likedPosts[postId] ?? false;
      _likedPosts[postId] = !isLiked;
      _likesCount[postId] = (_likesCount[postId] ?? 0) + (isLiked ? -1 : 1);
    });
  }

  void _toggleBookmark(int postId) {
    setState(() {
      final isBookmarked = _bookmarkedPosts[postId] ?? false;
      _bookmarkedPosts[postId] = !isBookmarked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CivicScaffold(
      backgroundColor: const Color(0xFF0B0C0F), // Sleek pitch black base matching the mockup
      appBar: CivicAppBar(
        title: 'Feed',
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Badge(
              smallSize: 8,
              backgroundColor: const Color(0xFFFF3B30),
              alignment: const Alignment(0.4, -0.4),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Navigation tabs "Pour vous", "Abonnements", "Local"
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 8, bottom: 12),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorSize: TabBarIndicatorSize.label,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                fontFamily: 'Outfit',
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                fontFamily: 'Outfit',
              ),
              dividerColor: Colors.transparent,
              indicator: const UnderlineTabIndicator(
                borderSide: BorderSide(width: 3.0, color: Colors.white),
                insets: EdgeInsets.symmetric(horizontal: 16.0),
              ),
              tabs: const [
                Tab(text: 'Pour vous'),
                Tab(text: 'Abonnements'),
                Tab(text: 'Local'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFeedList(),
                _buildMockEmptyFeed('Abonnements'),
                _buildMockEmptyFeed('Local'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedList() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      children: [
        // Post 1: Marquize.7
        _buildFlatPostCard(
          postId: 0,
          userAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=150',
          userName: 'Marquize.7',
          timeAgo: '2 h · Shawinigan',
          content: 'Réparé ce matin 💪\nAvant / Après!',
          isBeforeAfter: true,
          beforeImg: 'https://images.unsplash.com/photo-1515162305285-0293e4767cc2?q=80&w=600&auto=format&fit=crop',
          afterImg: 'https://images.unsplash.com/photo-1584467541268-b040f83be3fd?q=80&w=600&auto=format&fit=crop',
          commentsCount: 38,
          sharesCount: 17,
        ),

        const Divider(color: Colors.white10, height: 1, thickness: 0.5),

        // Post 2: Cassandra D.
        _buildFlatPostCard(
          postId: 1,
          userAvatar: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=150',
          userName: 'Cassandra D.',
          timeAgo: '4 h · Trois-Rivières',
          content: 'Pneu éclaté à cause de ce nid!',
          locationTag: 'Rue Radisson',
          commentsCount: 12,
          sharesCount: 5,
          multipleImages: const [
            'https://images.unsplash.com/photo-1515162305285-0293e4767cc2?q=80&w=600&auto=format&fit=crop',
            'https://images.unsplash.com/photo-1584467541268-b040f83be3fd?q=80&w=600&auto=format&fit=crop',
          ],
        ),

        const Divider(color: Colors.white10, height: 1, thickness: 0.5),

        // Post 3: Jean-Marc L.
        _buildFlatPostCard(
          postId: 2,
          userAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=150',
          userName: 'Jean-Marc L.',
          timeAgo: '1 j · Grand-Mère',
          content: 'Nouveau nid-de-poule très profond signalé près du pont de la 50e Avenue.',
          locationTag: 'Pont de la 50e Avenue',
          commentsCount: 3,
          sharesCount: 1,
        ),
      ],
    );
  }

  Widget _buildFlatPostCard({
    required int postId,
    required String userAvatar,
    required String userName,
    required String timeAgo,
    required String content,
    bool isBeforeAfter = false,
    String? beforeImg,
    String? afterImg,
    String? locationTag,
    List<String>? multipleImages,
    required int commentsCount,
    required int sharesCount,
  }) {
    final isLiked = _likedPosts[postId] ?? false;
    final likes = _likesCount[postId] ?? 0;
    final isBookmarked = _bookmarkedPosts[postId] ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (Avatar + Name + TimeAgo/Location + More options button)
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(userAvatar),
                backgroundColor: Colors.grey[900],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      timeAgo,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.more_horiz_rounded,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Content Text
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              content,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                height: 1.4,
                fontFamily: 'Outfit',
              ),
            ),
          ),

          // Location Tag (Capsule Button)
          if (locationTag != null) ...[
            GestureDetector(
              onTap: () {},
              child: Container(
                margin: const EdgeInsets.only(bottom: 12.0),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF007AFF).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF007AFF).withValues(alpha: 0.3),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      color: Color(0xFF007AFF),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      locationTag,
                      style: const TextStyle(
                        color: Color(0xFF007AFF),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Media block
          if (isBeforeAfter && beforeImg != null && afterImg != null) ...[
            CivicBeforeAfterSlider(
              beforeImageUrl: beforeImg,
              afterImageUrl: afterImg,
              height: 220,
              borderRadius: 24,
            ),
            const SizedBox(height: 14),
          ] else if (multipleImages != null && multipleImages.isNotEmpty) ...[
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      bottomLeft: Radius.circular(24),
                    ),
                    child: Image.network(
                      multipleImages[0],
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                    child: Image.network(
                      multipleImages[1],
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
          ],

          // Actions Row
          Row(
            children: [
              // Like
              GestureDetector(
                onTap: () => _toggleLike(postId),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    Icon(
                      isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: isLiked ? const Color(0xFFFF3B30) : AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$likes',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),

              // Comment
              GestureDetector(
                onTap: () {},
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$commentsCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),

              // Repost / Trend
              GestureDetector(
                onTap: () {},
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    const Icon(
                      Icons.trending_up_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$sharesCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Bookmark
              IconButton(
                onPressed: () => _toggleBookmark(postId),
                icon: Icon(
                  isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  color: isBookmarked ? AppColors.brandOrange : AppColors.textSecondary,
                  size: 22,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMockEmptyFeed(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.dynamic_feed_rounded,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'Pas de contenu dans $title',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
              fontFamily: 'Outfit',
            ),
          ),
        ],
      ),
    );
  }
}
