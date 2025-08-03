import 'package:checkgrid/game/board.dart';
import 'package:checkgrid/pages/gameover_page.dart';
import 'package:checkgrid/game/game_ui.dart';
import 'package:checkgrid/pages/settings/socials.dart';
import 'package:checkgrid/pages/statistics_page.dart';
import 'package:checkgrid/pages/splash_screen.dart';
import 'package:checkgrid/pages/menu_page.dart';
import 'package:checkgrid/pages/tutorial_page.dart';
import 'package:checkgrid/providers/wrapper.dart';
import 'package:checkgrid/pages/settings/privacy_policy.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:checkgrid/pages/store/store_page.dart';
import 'package:checkgrid/pages/settings/feedback_page.dart';
import 'package:checkgrid/pages/settings/settings_page.dart';

final GoRouter router = GoRouter(
  initialLocation: "/splash",
  routes: [
    GoRoute(
      name: '/splash',
      path: '/splash',
      pageBuilder:
          (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const SplashScreen(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
    ),
    GoRoute(
      name: '/tutorial',
      path: '/tutorial',
      pageBuilder:
          (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const TutorialPage(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
    ),
    GoRoute(
      name: '/home',
      path: '/home',
      pageBuilder:
          (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const HomeWrapper(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
    ),
    // Not in use
    GoRoute(
      name: '/menu',
      path: '/menu',
      pageBuilder:
          (context, state) =>
              CupertinoPage(key: state.pageKey, child: GameMenu()),
    ),
    GoRoute(
      name: '/play',
      path: '/play',
      pageBuilder:
          (context, state) => CupertinoPage(key: state.pageKey, child: Game()),
    ),
    GoRoute(
      name: '/gameover',
      path: '/gameover',
      pageBuilder:
          (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: GameOverPage(board: state.extra as Board),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
    ),
    GoRoute(
      name: '/store',
      path: '/store',
      pageBuilder:
          (context, state) =>
              CupertinoPage(key: state.pageKey, child: StorePage()),
    ),
    GoRoute(
      name: '/settings',
      path: '/settings',
      pageBuilder:
          (context, state) =>
              CupertinoPage(key: state.pageKey, child: SettingsPage()),
    ),
    GoRoute(
      name: '/statistics',
      path: '/statistics',
      pageBuilder:
          (context, state) =>
              CupertinoPage(key: state.pageKey, child: StatisticsPage()),
    ),
    GoRoute(
      name: '/feedback',
      path: '/feedback',
      pageBuilder:
          (context, state) =>
              CupertinoPage(key: state.pageKey, child: FeedbackPage()),
    ),
    GoRoute(
      name: '/socials',
      path: '/socials',
      pageBuilder:
          (context, state) =>
              CupertinoPage(key: state.pageKey, child: SocialsPage()),
    ),
    GoRoute(
      name: '/privacy_policy',
      path: '/privacy_policy',
      pageBuilder:
          (context, state) =>
              CupertinoPage(key: state.pageKey, child: PrivacyPolicyPage()),
    ),
  ],
);
