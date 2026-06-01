import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:niddepoule/features/shared/widgets/app_bottom_nav.dart';

/// Navigation principale MVP : Carte, Signaler, Feed, Profil.
class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key, required this.navShell});

  final StatefulNavigationShell navShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navShell,
      bottomNavigationBar: AppBottomNav(
        currentIndex: navShell.currentIndex,
        onTap: (index) {
          if (index == 2) {
            context.push('/report');
          } else {
            navShell.goBranch(
              index,
              initialLocation: index == navShell.currentIndex,
            );
          }
        },
      ),
    );
  }
}
