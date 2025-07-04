import 'package:checkgrid/game/board.dart';
import 'package:checkgrid/game/dialogs/game_over/gameover_dialog.dart';
import 'package:checkgrid/game/game_ui.dart';
import 'package:checkgrid/pages/statistics_page.dart';
import 'package:checkgrid/pages/splash_screen.dart';
import 'package:checkgrid/pages/menu_page.dart';
import 'package:checkgrid/providers/wrapper.dart';
import 'package:checkgrid/settings/privacy_policy.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:checkgrid/pages/store/store_page.dart';
import 'package:checkgrid/pages/feedback_page.dart';
import 'package:checkgrid/pages/settings_page.dart';

final GoRouter router = GoRouter(
  initialLocation: "/splash",
  routes: [
    GoRoute(
      name: '/home',
      path: '/home',
      builder: (context, state) => const HomeWrapper(),
    ),

    GoRoute(
      name: '/menu',
      path: '/menu',
      pageBuilder:
          (context, state) =>
              CupertinoPage(key: state.pageKey, child: GameMenu()),
    ),
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
      name: '/play',
      path: '/play',
      pageBuilder:
          (context, state) => CupertinoPage(key: state.pageKey, child: Game()),
    ),
    GoRoute(
      name: '/gameover',
      path: '/gameover',
      pageBuilder:
          (context, state) => CupertinoPage(
            key: state.pageKey,
            child: GameOverPage(board: state.extra as Board),
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
      name: '/privacy_policy',
      path: '/privacy_policy',
      pageBuilder:
          (context, state) =>
              CupertinoPage(key: state.pageKey, child: PrivacyPolicyPage()),
    ),
  ],
);
