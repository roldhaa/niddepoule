import 'package:flutter/material.dart';
import 'package:niddepoule/app/design_system/app_colors.dart';

class CivicAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CivicAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = false,
  });

  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: actions,
      leading: leading,
      centerTitle: centerTitle,
      backgroundColor: AppColors.brandBlack,
      foregroundColor: AppColors.textOnDark,
      elevation: 0,
    );
  }
}
