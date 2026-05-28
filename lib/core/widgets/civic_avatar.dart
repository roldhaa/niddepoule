import 'package:flutter/material.dart';
import 'package:niddepoule/app/design_system/app_colors.dart';

class CivicAvatar extends StatelessWidget {
  const CivicAvatar({
    super.key,
    this.photoUrl,
    this.name,
    this.radius = 24,
    this.showRing = false,
  });

  final String? photoUrl;
  final String? name;
  final double radius;
  final bool showRing;

  @override
  Widget build(BuildContext context) {
    final initial = (name != null && name!.isNotEmpty) ? name![0].toUpperCase() : '?';

    Widget avatar = CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.surfaceSection,
      backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
      child: photoUrl == null
          ? Text(
              initial,
              style: TextStyle(
                fontSize: radius * 0.7,
                fontWeight: FontWeight.w700,
                color: AppColors.brandBlack,
              ),
            )
          : null,
    );

    if (showRing) {
      avatar = Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.brandYellow, width: 2),
        ),
        child: avatar,
      );
    }

    return avatar;
  }
}
