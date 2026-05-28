import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:niddepoule/app/design_system/app_durations.dart';
import 'package:niddepoule/features/auth/presentation/providers/auth_providers.dart';
import 'package:niddepoule/features/auth/presentation/screens/login_screen.dart';
import 'package:niddepoule/features/auth/presentation/screens/register_screen.dart';
import 'package:niddepoule/features/auth/presentation/screens/welcome_screen.dart';
import 'package:niddepoule/features/feed/presentation/screens/feed_screen.dart';
import 'package:niddepoule/features/map/presentation/screens/map_screen.dart';
import 'package:niddepoule/features/potholes/presentation/screens/pothole_details_screen.dart';
import 'package:niddepoule/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:niddepoule/features/profile/presentation/screens/profile_screen.dart';
import 'package:niddepoule/features/proof/presentation/screens/proof_preview_screen.dart';
import 'package:niddepoule/features/reports/presentation/screens/report_pothole_screen.dart';
import 'package:niddepoule/features/shared/navigation/main_navigation_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

CustomTransitionPage<void> _fadeSlidePage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: AppDurations.normal,
    reverseTransitionDuration: AppDurations.fast,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: AppDurations.easeOut,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/welcome',
    redirect: (context, state) {
      final user = ref.read(authStateProvider).valueOrNull;
      final path = state.fullPath ?? '';
      final isAuthRoute =
          path == '/welcome' || path == '/login' || path == '/register';
      if (user == null && !isAuthRoute) return '/welcome';
      if (user != null && isAuthRoute) return '/home/map';
      return null;
    },
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navShell) =>
            MainNavigationScreen(navShell: navShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/map',
                builder: (context, state) => const MapScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/report',
                builder: (context, state) => ReportPotholeScreen(
                  potholeId: state.uri.queryParameters['potholeId'],
                  redirectPath: state.uri.queryParameters['redirect'],
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/feed',
                builder: (context, state) => const FeedScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/pothole/:id',
        pageBuilder: (context, state) => _fadeSlidePage(
          key: state.pageKey,
          child: PotholeDetailsScreen(
            potholeId: state.pathParameters['id']!,
          ),
        ),
        routes: [
          GoRoute(
            path: 'proof',
            pageBuilder: (context, state) => _fadeSlidePage(
              key: state.pageKey,
              child: ProofPreviewScreen(
                potholeId: state.pathParameters['id']!,
              ),
            ),
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/profile/edit',
        pageBuilder: (context, state) => _fadeSlidePage(
          key: state.pageKey,
          child: const EditProfileScreen(),
        ),
      ),
    ],
  );
});
