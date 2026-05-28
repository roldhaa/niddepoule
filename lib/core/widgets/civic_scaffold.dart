import 'package:flutter/material.dart';
import 'package:niddepoule/app/design_system/app_colors.dart';
import 'package:niddepoule/core/widgets/civic_app_bar.dart';

class CivicScaffold extends StatelessWidget {
  const CivicScaffold({
    super.key,
    this.appBar,
    this.title,
    this.actions,
    this.leading,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.backgroundColor,
    this.extendBody = false,
  });

  final CivicAppBar? appBar;
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final bool extendBody;

  @override
  Widget build(BuildContext context) {
    PreferredSizeWidget? bar = appBar;
    if (bar == null && title != null) {
      bar = CivicAppBar(
        title: title!,
        actions: actions,
        leading: leading,
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.surfaceMuted,
      appBar: bar,
      body: body,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      extendBody: extendBody,
    );
  }
}
