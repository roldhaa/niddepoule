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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.brandBlack, // Dynamic app background color
        border: Border(
          top: BorderSide(
            color: AppColors.border.withValues(alpha: 0.3), // Dynamic border color
            width: 0.5,
          ),
        ),
      ),
          child: SafeArea(
            child: Container(
              height: 75,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildNavItem(0, Icons.home_outlined, Icons.home_rounded, 'Carte'),
                  _buildNavItem(1, Icons.feed_outlined, Icons.feed_rounded, 'Feed'),
                  _buildCenterButton(),
                  _buildNavItem(3, Icons.notifications_outlined, Icons.notifications_rounded, 'Alertes'),
                  _buildNavItem(4, Icons.person_outline_rounded, Icons.person_rounded, 'Profil'),
                ],
              ),
            ),
          ),
        );
      }

  Widget _buildNavItem(int index, IconData outlineIcon, IconData solidIcon, String label) {
    final isSelected = currentIndex == index;
    final color = isSelected ? AppColors.brandOrange : AppColors.textSecondary;
    final icon = isSelected ? solidIcon : outlineIcon;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            index == 3
                ? Badge(
                    label: const Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: const Color(0xFFFF3B30),
                    child: Icon(icon, color: color, size: 24),
                  )
                : Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterButton() {
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(2),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.brandOrange,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.brandOrange.withValues(alpha: 0.45),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
}
