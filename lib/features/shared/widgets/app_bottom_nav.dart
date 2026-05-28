import 'package:flutter/material.dart';
import 'package:niddepoule/app/design_system/app_colors.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    (Icons.map_outlined, Icons.map_rounded, 'Carte'),
    (Icons.add_location_alt_outlined, Icons.add_location_alt, 'Signaler'),
    (Icons.dynamic_feed_outlined, Icons.dynamic_feed, 'Feed'),
    (Icons.person_outline, Icons.person, 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.navIndicator,
      elevation: 8,
      shadowColor: AppColors.brandBlack.withValues(alpha: 0.08),
      destinations: [
        for (final item in _items)
          NavigationDestination(
            icon: Icon(item.$1),
            selectedIcon: Icon(item.$2, color: AppColors.brandBlack),
            label: item.$3,
          ),
      ],
    );
  }
}
